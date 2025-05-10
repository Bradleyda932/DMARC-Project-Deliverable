# (run after clean_acs)
library(mapview)
library(webshot)

household <- all %>%
  group_by(afn) %>%
  summarise(
    n_household = n_distinct(individual_id), 
    zip = first(zip),
    income = first(annual_income),
    num_visits = n_distinct(served_date)
  )
repeat_visitors <- all %>%
  group_by(individual_id) %>%
  summarise(
    num_visits = n_distinct(served_date),
    at_risk = if_else(any(homeless == 'Imminently Homeless' | homeless == 'Unstably Housed'), 1, 0),
    zip = first(zip)
  ) %>%
  filter(num_visits == 2)


zip_counts <- repeat_visitors %>%
  group_by(zip) %>%
  summarise(
    total_individuals = n(),
    .groups = "drop"
  )

# Keep only the most recent year for each ZIP code
latest_zip_population <- dm_subset_df %>%
  group_by(ZIP) %>%
  filter(year == max(year)) %>%
  ungroup()

# Convert ZIP codes to character type for consistency
latest_zip_population$ZIP <- as.character(latest_zip_population$ZIP)
zip_counts$zip <- as.character(zip_counts$zip)

########## Iowa Map Data Download & Merge ------

# Zip code map creation

library(sf)
library(ggplot2)
library(tigris)
library(dplyr)

# Load libraries
iowa_zips <- zctas(cb = FALSE, year = 2010, state = "IA") %>%
  select(ZCTA5CE10) %>%  # Keep only the ZIP code column
  rename(zip = ZCTA5CE10) %>% 
  mutate(zip = as.character(zip))  # Ensure ZIP codes are characters

iowa_map_data <- iowa_zips %>%
  left_join(zip_counts, by = "zip")  # Merge with your data


########## Leaflet -----
library(leaflet)
library(sf)
library(dplyr)

# Ensure correct projection (only transform once)
iowa_map_data <- st_transform(iowa_map_data, crs = 4326)
locations <- locations %>%
  filter(!is.na(Longitude) & !is.na(Latitude))

# Ensure locations are converted to an sf object with Longitude and Latitude as coordinates
locations_sf <- st_as_sf(locations, coords = c("Longitude", "Latitude"), crs = 4326)

# Now that locations is an sf object, you can use it directly in leaflet
library(dplyr)

# Remove rows with NA or infinite values in 'individual_density'
iowa_map_data <- iowa_map_data %>%
  filter(is.finite(individual_density))

# Now you can proceed with your leaflet code
library(leaflet)
library(sf)
library(dplyr)
library(mapview)  # For mapshot()

# Define the color palette for "YlOrRd"
pal <- colorNumeric(palette = "YlOrRd", 
                    domain = iowa_map_data$individual_density * 100, # Scale to percentage
                    na.color = "grey80")

# Create the Leaflet map
leaflet_map <- leaflet(iowa_map_data) %>%
  
  # Add zip code polygons FIRST for background colors
  addPolygons(
    fillColor = ~pal(individual_density * 100),  # Scale to percentage
    color = "grey80",
    weight = 0.4,
    opacity = 1,
    fillOpacity = 0.3,
    label = ~paste0(
      ifelse(individual_density > 0,
             sprintf("%.1f%%", individual_density * 100),
             "No Data")
    ),
    highlightOptions = highlightOptions(
      weight = 2,
      color = "#666",
      fillOpacity = 0.9,
      bringToFront = TRUE
    ),
    group = "Polygons"
  ) %>%
  
  # Add street tiles AFTER polygons (on top)
  addProviderTiles(providers$CartoDB.Positron, group = "Street Map") %>%
  
  # Add circle markers for food pantry locations
  addCircleMarkers(
    data = locations_sf,
    radius = 6,
    color = "white",
    fillOpacity = 0.3,
    label = ~"DMARC Food Pantry",
    popup = ~paste("Location:", st_coordinates(locations_sf)[, 1], st_coordinates(locations_sf)[, 2]),
    group = "Food Pantry Locations"
  ) %>%
  
  # Add numeric labels on the map for individual_density
  addLabelOnlyMarkers(
    data = iowa_map_data,
    lng = ~st_coordinates(st_centroid(geometry))[, 1],  # Centroid X
    lat = ~st_coordinates(st_centroid(geometry))[, 2],  # Centroid Y
    label = ~sprintf("%.1f%%", individual_density * 100),  # Format as percentage
    labelOptions = labelOptions(
      noHide = TRUE,
      textOnly = TRUE,
      style = list(
        "color" = "black",
        "font-family" = "Arial",
        "font-size" = "12px",
        "font-weight" = "bold"
      )
    ),
    group = "Labels"
  ) %>%
  
  addLegend(
    pal = pal,
    values = iowa_map_data$individual_density * 100,  # Scale to percentage
    title = "% Population Visitng",
    opacity = 0.7,
    position = "bottomright",
    labFormat = labelFormat(suffix = "%", digits = 1)
  ) %>%
  

  addControl(
    html = "<strong>% of Repeat Visitors to DMARC by Zip Code in Central Iowa </strong><br><em>Data Source: DMARC Food Pantries / American Community Census </em>",
    position = "topright"
  )

# View the map
leaflet_map



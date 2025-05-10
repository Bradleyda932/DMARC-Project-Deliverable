library(dplyr)
library(sf)
library(tigris)
library(leaflet)
library(RColorBrewer)
head(acs)
options(tigris_use_cache = TRUE)

library(leaflet)
library(dplyr)
library(scales)
library(sf)
library(tigris)

# 1. Proportion + count calculations
acs <- acs %>%
  mutate(
    young_adult_prop = ifelse(total_pop > 0, young_adult / total_pop, NA_real_),
    adult_prop = ifelse(total_pop > 0, adult / total_pop, NA_real_),  # Add this if you have `adult` column
    combined_adult_prop = ifelse(!is.na(young_adult_prop) & !is.na(adult_prop),
                                 (young_adult_prop + adult_prop), NA_real_),
    
    hispanic_prop = ifelse(total_pop > 0, hispanic / total_pop, NA_real_),
    poverty_rate = ifelse(total_pop > 0, poverty_count / total_pop, NA_real_),
    
    target_group_count = round(
      total_pop * combined_adult_prop * hispanic_prop * (1 - snap_rate) * poverty_rate
    ),
    target_group_density = target_group_count / total_pop
  )


# 2. ZIP shapefiles
iowa_zips <- zctas(cb = FALSE, year = 2010, state = "IA") %>%
  select(ZCTA5CE10) %>%
  rename(zip = ZCTA5CE10) %>%
  mutate(zip = as.character(zip))

# 3. Join and filter data
iowa_map_data <- iowa_zips %>%
  left_join(acs, by = c("zip" = "ZIP")) %>%
  filter(!is.na(target_group_density)) %>%
  st_transform(crs = 4326)

# 4. Clean pantry locations
locations_clean <- locations %>%
  filter(!is.na(Longitude) & !is.na(Latitude))

locations_sf <- st_as_sf(locations_clean, coords = c("Longitude", "Latitude"), crs = 4326)

# Cap density at 2.8%
iowa_map_data <- iowa_map_data %>%
  mutate(
    target_group_density = pmin(target_group_density, 0.028)
  )

# 5. Color palettes
pal_density <- colorNumeric(
  palette = "BuPu",
  domain = c(0, 0.028),
  na.color = "grey80"
)

pal_count <- colorNumeric(
  palette = "BuPu",
  domain = c(0, 532),
  na.color = "grey80"
)

# Compute centroids for labeling
zip_centroids <- st_centroid(iowa_map_data)

# Extract coordinates from centroids
coords <- st_coordinates(zip_centroids)

# Add coordinates and label strings
zip_centroids <- zip_centroids %>%
  mutate(
    lng = coords[, 1],
    lat = coords[, 2],
    label_density = paste0(round(100 * target_group_density, 1), "%"),
    label_count = scales::comma(target_group_count)
  )

# Add labels to density map (percent values)
map_density <- map_density %>%
  addLabelOnlyMarkers(
    data = zip_centroids,
    lng = ~lng,
    lat = ~lat,
    label = ~label_density,
    labelOptions = labelOptions(
      noHide = TRUE,
      direction = "center",
      textOnly = TRUE,
      style = list(
        "font-size" = "11px",
        "color" = "white",
        "text-shadow" = "1px 1px 2px black"
      )
    )
  )

# Add labels to count map (raw number values)
map_count <- map_count %>%
  addLabelOnlyMarkers(
    data = zip_centroids,
    lng = ~lng,
    lat = ~lat,
    label = ~label_count,
    labelOptions = labelOptions(
      noHide = TRUE,
      direction = "center",
      textOnly = TRUE,
      style = list(
        "font-size" = "11px",
        "color" = "black",
        "text-shadow" = "1px 1px 2px white"
      )
    )
  )

map_density
map_count
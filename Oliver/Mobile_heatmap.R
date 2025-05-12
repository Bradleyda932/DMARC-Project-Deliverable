library(leaflet)
library(dplyr)
library(leaflet.extras)



unique(all$location_groups)


locations <- tibble(
  Location = c(
    "River Place", "North Side", "WDM Human Services", "IMPACT CAP - Drake", 
    "Johnston Partnership", "Salvation Army Clive", "Urbandale", "IMPACT CAP - Ankeny", 
    "Affiliate", "Families Forward - Bidwell", "Central Iowa Shelter", "Catholic Charities", 
    "Other", "Clive CS", "DMARC Mobile", "DMARC-ket", "Caring Hands Eastview"
  ),
  Latitude = as.numeric(c(
    "41.627827", "41.6226097", "41.5869188", "41.5999927", 
    "41.6670689", "41.6030722", "41.6298643", "41.7241041", 
    NA, "41.5694615", "41.5823008", "41.5959705", 
    NA, "41.6137961", NA, "41.5255685", "41.6350469"
  )),
  Longitude = as.numeric(c(
    "-93.6366188", "-93.625142", "-93.6085167", "-93.6615703", 
    "-93.6997697", "-93.755201", "-93.7232284", "-93.5996844", 
    NA, "-93.5981624", "-93.6344773", "-93.5856851", 
    NA, "-93.7322726", NA, "-93.6166655", "-93.5314193"
  ))
)




updated_all <- current

# Make sure coordinates are numeric
updated_all <- updated_all %>%
  mutate(locationLat = as.numeric(latitude),
         locationLng = as.numeric(longitude))

# Remove rows with missing or NA coordinates
updated_all_clean <- updated_all %>%
  filter(!is.na(locationLat), !is.na(locationLng))

# Ensure coordinates are numeric
updated_all <- updated_all %>%
  mutate(locationLat = as.numeric(locationLat),
         locationLng = as.numeric(locationLng))

# Count frequency of each coordinate pair
location_counts <- updated_all %>%
  group_by(locationLat, locationLng) %>%
  summarise(count = n(), .groups = 'drop')


# Normalize intensity
location_counts <- location_counts %>%
  mutate(scaled_count = count / max(count, na.rm = TRUE))



max_intensity <- quantile(location_counts$scaled_count, 0.95, na.rm = TRUE)

# Build heat map

leaflet(location_counts) %>%
  addTiles() %>%
  addHeatmap(
    lng = ~locationLng,
    lat = ~locationLat,
    intensity = ~scaled_count,
    blur = 20,          
    max = max_intensity,  
    radius = 15            
  )

library(leaflet)
library(dplyr)
library(leaflet.extras)

# Filter for Mobile locations and clean coordinates
mobile_only <- current %>%
  filter(fp_location == "DMARC Mobile") %>%
  mutate(
    locationLat = as.numeric(latitude),
    locationLng = as.numeric(longitude)
  ) %>%
  filter(!is.na(locationLat), !is.na(locationLng))  # Remove NAs

# Check if any data remains
if (nrow(mobile_only) == 0) {
  warning("No data available for fp_location == 'Mobile' with valid coordinates.")
} else {
  # Count frequency of each coordinate pair
  location_counts <- mobile_only %>%
    group_by(locationLat, locationLng) %>%
    summarise(count = n(), .groups = 'drop')
  
  # Check if count has valid values
  if (all(is.na(location_counts$count)) || nrow(location_counts) == 0) {
    warning("No valid location counts to display.")
  } else {
    # Normalize and cap intensity
    location_counts <- location_counts %>%
      mutate(scaled_count = count / max(count, na.rm = TRUE))
    
    max_intensity <- quantile(location_counts$scaled_count, 0.95, na.rm = TRUE)
    
    leaflet(location_counts) %>%
      addTiles() %>%
      addHeatmap(
        lng = ~locationLng,
        lat = ~locationLat,
        intensity = ~scaled_count,
        blur = 20,
        max = max_intensity,
        radius = 15
      )
  }
}


library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)

BASE_URL <- "https://api.census.gov/data"
VARIABLE <- "B01003_001E"  # Total population

results <- data.frame()

for (year in 2012:2023) {
  
  url <- paste0(BASE_URL, "/", year, "/acs/acs5")
  
  if (year < 2020) {
    params <- list(
      get = paste("NAME", VARIABLE, sep = ","),
      `for` = "zip code tabulation area:*",
      `in` = "state:19"  # Iowa (FIPS code 19)
    )
  } else {
    params <- list(
      get = paste("NAME", VARIABLE, sep = ","),
      `for` = "zip code tabulation area:*"
    )
  }
  
  response <- GET(url, query = params)
  
  if (status_code(response) == 200) {
    data <- content(response, as = "text", encoding = "UTF-8")
    json_data <- fromJSON(data)
    curr_year <- as.data.frame(json_data)
    colnames(curr_year) <- curr_year[1, ] 
    curr_year <- curr_year[-1, ]
    curr_year$year <- year 
    curr_year[[VARIABLE]] <- as.numeric(curr_year[[VARIABLE]]) 
    results <- bind_rows(results, curr_year) 
    
  } else {
    print(paste("Error fetching data for", year, ":", status_code(response)))
  }
}

# Rename column for clarity
colnames(results)[colnames(results) == "zip code tabulation area"] <- "ZIP"

# Get Iowa ZIP codes from 2019 data
iowa_zips <- unique(results$ZIP[results$year == 2019])

# Filter Iowa ZIP codes
iowa_df <- results %>% filter(ZIP %in% iowa_zips)

# Ensure `all$zip` exists and matches format
all_zips <- unique(all$zip)

# Check for mismatches in ZIP formats
print(setdiff(all_zips, iowa_df$ZIP))

# Filter for ZIP codes in `all_zips`
dm_subset_df <- iowa_df %>% 
  filter(ZIP %in% all_zips) %>% 
  select(ZIP, year, B01003_001E)

print(head(dm_subset_df))

dm_subset_df <- dm_subset_df %>%
  rename(total_population = B01003_001E)


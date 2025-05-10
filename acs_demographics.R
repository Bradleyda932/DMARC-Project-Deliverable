library(httr)
library(jsonlite)
library(dplyr)

BASE_URL <- "https://api.census.gov/data"
YEAR <- 2023

VARS <- c(
  # Core demographics
  "B01003_001E",  # Total population
  "B19013_001E",  # Median household income
  "B17001_002E",  # Poverty count
  "B02001_002E",  # White
  "B02001_003E",  # Black
  "B02001_005E",  # Asian
  "B03003_003E",  # Hispanic
  "B25010_001E",  # Avg household size
  "B22001_001E",  # Total households
  "B22001_002E",  # SNAP households
  
  # Age: Young Adults (18–24)
  "B01001_008E", "B01001_009E",  # Male
  "B01001_025E", "B01001_026E",  # Female
  
  # Age: Adults (25–64)
  "B01001_010E", "B01001_011E",  # Male
  "B01001_027E", "B01001_028E",  # Female
  
  # Age: Elderly (65+)
  "B01001_012E", "B01001_013E", "B01001_014E", "B01001_015E",  # Male
  "B01001_029E", "B01001_030E", "B01001_031E", "B01001_032E"   # Female
)

url <- paste0(BASE_URL, "/", YEAR, "/acs/acs5")
params <- list(
  get = paste("NAME", paste(VARS, collapse = ","), sep = ","),
  `for` = "zip code tabulation area:*"
)

response <- GET(url, query = params)
stopifnot(status_code(response) == 200)

data <- content(response, as = "text", encoding = "UTF-8")
json_data <- fromJSON(data)
df <- as.data.frame(json_data)
colnames(df) <- df[1, ]
df <- df[-1, ]
colnames(df)[colnames(df) == "zip code tabulation area"] <- "ZIP"

# Convert numerics and compute custom age groups
df <- df %>%
  mutate(across(all_of(VARS), as.numeric)) %>%
  mutate(
    young_adult = B01001_008E + B01001_009E + B01001_025E + B01001_026E,
    adult = B01001_010E + B01001_011E + B01001_027E + B01001_028E,
    elderly = B01001_012E + B01001_013E + B01001_014E + B01001_015E +
      B01001_029E + B01001_030E + B01001_031E + B01001_032E,
    snap_rate = ifelse(B22001_001E > 0, B22001_002E / B22001_001E, NA)
  ) %>%
  select(ZIP, B01003_001E, B19013_001E, B17001_002E,
         B02001_002E, B02001_003E, B02001_005E, B03003_003E,
         B25010_001E, B22001_001E, B22001_002E, snap_rate,
         young_adult, adult, elderly) %>%
  rename(
    total_pop = B01003_001E,
    median_income = B19013_001E,
    poverty_count = B17001_002E,
    white = B02001_002E,
    black = B02001_003E,
    asian = B02001_005E,
    hispanic = B03003_003E,
    avg_household_size = B25010_001E,
    total_households = B22001_001E,
    snap_households = B22001_002E
  )

acs <- df
head(acs)

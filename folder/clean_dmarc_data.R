# Step 1: Load the data and libraries
rm(list = ls())
library(tidyverse)
library(dplyr)
library(data.table)
library(ggplot2)
library(haven)
library(nnet)
library(RColorBrewer)
library(lubridate)
library(patchwork)
library(gridExtra)

data <- read.csv("/Users/bradley/Desktop/Sem 4/CS 190/dmarc project/drake_export_v8_2024-02-13_100754_rev2_nolatlong.csv")

# Step 2: Rename columns 
colnames(data) <- c("fp_number", "house_id", "served_date", "annual_income", "poverty_level",
                    "person_id", "lnm", "dob", "gender", "race", "ethnicity", 
                    "education", "family_type", "snap_house", "zip_code", "fp_location", 
                    "housing_status", "housing_type", "homelessness", "income_source")

# Step 3: Begin cleaning the data
data <- data %>%
  select(-lnm, -housing_type)

# 3a: Drop rows with multiple missing values using keywords
data[data == ""] <- NA
data[data == "NULL"] <- NA

data <- data %>%
  filter(rowSums(across(everything(), ~ . %in% c("Unknown", "Other", "Not Selected")) | is.na(.)) <= 3) %>%
  drop_na(-income_source)

colSums(is.na(data))

# 3a: round annual_income
data$annual_income <- round(data$annual_income) 

# 3b: Cleaning zip codes/homelessness
data$zip_code <- substr(data$zip_code, 1, 5) 
zip_count <- data %>% count(zip_code) %>% arrange(zip_code)
#lapply(zip_count, table)

data <- data %>%
  mutate(homelessness = case_when(
    zip_code == 50301 & housing_status == "Homeless" & homelessness != "Literally Homeless" ~ "Literally Homeless",
    TRUE ~ homelessness
  ))

head(data)

data <- data %>%
  mutate(housing_status = case_when(
    zip_code == 50301 & homelessness == "Literally Homeless" & housing_status != "Homeless" ~ "Homeless",
    TRUE ~ housing_status
  ))

# 3c: Fixing age
data <- data %>% 
  mutate(
    dob = ymd(dob),
    served_date = ymd(served_date),  
    age = round(as.numeric(difftime(served_date, dob, units = "days")) / 365.25)
  ) %>%
  filter(age > -0.1, age <= 102, dob >= ymd("1923-01-01"))

# Step 4a: Putting numeric vars into groups
data$annual_income[data$annual_income < 0] <- 0

data <- data %>%
  mutate(
    income_bracket = case_when(
      annual_income == 0 ~ "No Income",
      annual_income <= 5000 ~ "$0 - $5,000",
      annual_income <= 10000 ~ "$5,000 - $10,000",
      annual_income <= 20000 ~ "$10,000 - $20,000",
      annual_income <= 50000 ~ "$20,000 - $50,000",
      annual_income <= 100000 ~ "$50,000 - $100,000",
      TRUE ~ "Over $100,000"
    ),
    fed_bracket = case_when(
      poverty_level == 0 ~ "0",
      poverty_level <= 25 ~ "0 - 25",
      poverty_level <= 50 ~ "25 - 50",
      poverty_level <= 100 ~ "50 - 100",
      poverty_level <= 200 ~ "100 - 200",
      poverty_level <= 500 ~ "200 - 500",
      TRUE ~ "Over 500"
    ),
    age_group = case_when(
      age <= 1 ~ "Infant",
      age <= 4 ~ "Toddler",
      age <= 12 ~ "Child",
      age <= 17 ~ "Teenager",
      age <= 24 ~ "Young Adult",
      age <= 64 ~ "Adult",
      TRUE ~ "Elderly"
    )
  )

data$income_bracket <- factor(data$income_bracket, 
                              levels = c("No Income", "$0 - $5,000", "$5,000 - $10,000", 
                                         "$10,000 - $20,000", "$20,000 - $50,000", 
                                         "$50,000 - $100,000", "Over $100,000"))

data <- data %>%
  filter(fp_location != "Unknown", fp_location != "all") %>%
  mutate(fp_location_groups = case_when(
    grepl("Ankeny", fp_location, fixed = TRUE) ~ "IMPACT CAP - Ankeny",
    grepl("Bidwell", fp_location, fixed = TRUE) ~ "Families Forward - Bidwell",
    grepl("Catholic Charities", fp_location, fixed = TRUE) ~ "Catholic Charities",
    grepl("Central Iowa", fp_location, fixed = TRUE) ~ "Central Iowa Shelter",
    grepl("Clive", fp_location, fixed = TRUE) ~ "Clive CS",
    grepl("DMARC-ket", fp_location, fixed = TRUE) ~ "DMARC-ket",
    grepl("DRAKE", fp_location, fixed = TRUE) ~ "IMPACT CAP - Drake",
    grepl("Eastview", fp_location, fixed = TRUE) ~ "Caring Hands Eastview",
    grepl("Mobile", fp_location, fixed = TRUE) | grepl("MOBILE", fp_location, fixed = TRUE) ~ "DMARC Mobile",
    grepl("North Side", fp_location, fixed = TRUE) ~ "North Side",
    grepl("PARTNERSHIP", fp_location, fixed = TRUE) ~ "Johnston Partnership",
    grepl("River Place", fp_location, fixed = TRUE) ~ "River Place",
    grepl("Salvation", fp_location, fixed = TRUE) | grepl("S.A. TEMPLE", fp_location, fixed = TRUE) ~ "Salvation Army Clive",
    grepl("URBANDALE", fp_location, fixed = TRUE) ~ "Urbandale",
    grepl("WDM", fp_location, fixed = TRUE) ~ "WDM Human Services",
    grepl("Affiliate", fp_location, fixed = TRUE) ~ "Affiliate",
    TRUE ~ "Other"
  ))

unique(data$fp_location_groups)

# Step 4b: fixing niche cases
income_source_nulls <- data %>%
  filter(is.na(income_source))

data <- data %>%
  mutate(income_source = case_when(
    income_bracket == "No Income" ~ "None",
    TRUE ~ income_source
  ))

data <- data %>%
  group_by(house_id) %>%
  mutate(
    flag_parents_income = any(age_group %in% c("Adult", "Elderly")) & 
      any(age_group %in% c("Teenager", "Child", "Infant", "Toddler")) &
      any(family_type %in% c("Male Adult with Children", "Female Adult with Children"))
  ) %>%
  ungroup()

data <- data %>%
  mutate(
    income_source = if_else(
      flag_parents_income, 
      "Parents income", 
      income_source
    )
  )

data <- data %>%
  select(-flag_parents_income)

# Count initial number of infants

single_infant_households <- data %>%
  group_by(house_id) %>%
  filter(age_group == "Infant") %>%
  summarise(infants_in_house = n()) %>%
  filter(infants_in_house == 1) %>%
  pull(house_id)

data <- data %>%
  filter(!(house_id %in% single_infant_households & age_group == "Infant"))


income_counts <- data %>%
  group_by(fp_location_groups, income_bracket) %>%
  summarise(count = n(), .groups = 'drop')

top_locations <- income_counts %>%
  group_by(fp_location_groups) %>%
  summarise(total_count = sum(count)) %>%
  arrange(desc(total_count)) %>%
  slice_head(n = 8) %>%
  pull(fp_location_groups)


# Step 6: Pull descriptive statistics
stats <- data %>%
  select_if(is.numeric) %>%
  summarise_all(list(
    mean = ~mean(.x, na.rm = TRUE),
    min = ~min(.x, na.rm = TRUE),
    max = ~max(.x, na.rm = TRUE),
    sd = ~sd(.x, na.rm = TRUE),
    n = ~sum(!is.na(.x))  
  ))

# Get all data needed in console
print(stats)
glimpse(data)
summary(data)
head(data)

# Step 5: segment years
data <- data %>%
  mutate(segmented_years = case_when(
    served_date >= "2018-01-01" & served_date <= "2019-12-31" ~ "2018-2019",
    served_date >= "2020-01-01" & served_date <= "2022-12-31" ~ "2020-2022",
    served_date >= "2023-01-01" ~ "2023-Present",
    TRUE ~ "Other"
  ))

data_2018_2019 <- data %>% filter(segmented_years == "2018-2019")
data_2020_2022 <- data %>% filter(segmented_years == "2020-2022")
data_2023_present <- data %>% filter(segmented_years == "2023-Present")

# Step 6: plot vars with segmented years
create_line_plot <- function(df, var, title) {
  df <- df %>%
    filter(!(!!sym(var) %in% c("Prefer Not to Respond", "Unknown", "Not Selected")))
  
  plot <- df %>%
    filter(fp_location_groups %in% top_locations) %>%
    group_by(fp_location_groups, !!sym(var)) %>%
    summarise(unique_count = n_distinct(person_id), .groups = 'drop') %>%
    ggplot(aes(x = !!sym(var), y = unique_count, group = fp_location_groups, color = fp_location_groups)) +
    geom_line(linewidth = 1) +
    labs(title = title, x = var, y = "Unique Individuals", color = "Location") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
    scale_color_manual(values = c("red", "blue", "green", "purple", "brown", "black", "orange", "pink")) +
    scale_y_continuous(
      breaks = scales::pretty_breaks(n = 7)  
    )
  
  return(plot)
}

variables <- c("gender", "race", "ethnicity", "education", "family_type", "housing_status", 
               "homelessness", "income_source", "income_bracket", "age_group")

for (var in variables) {
  p1 <- create_line_plot(data_2018_2019, var, paste("2018-2019:", var))
  p2 <- create_line_plot(data_2020_2022, var, paste("2020-2022:", var))
  p3 <- create_line_plot(data_2023_present, var, paste("2023-Present:", var))
  
  final_plot <- p1 / p2 / p3
  
  ggsave(paste0(var, "_segmented_years.png"), final_plot, width = 12, height = 9, dpi = 300)
}

lapply(data, table)



###
visit <- data
visit_daily <- visit %>%
  mutate(
    served_day = day(served_date),
    served_month = month(served_date),
    served_year = year(served_date),
    day_label = paste0(served_year, "-", sprintf("%02d", served_month), "-", sprintf("%02d", served_day))
  ) %>%
  distinct(house_id, day_label, .keep_all = TRUE) %>%
  count(day_label, name = "num_unique_visitors")

head(visit_daily)

visitor_count_person <- visit %>%
  count(person_id, served_date) %>%  
  group_by(person_id) %>%
  summarise(total_visits = n()) %>%
  mutate(visit_category = case_when(
    total_visits == 1 ~ "1",
    total_visits == 2 ~ "2",
    total_visits <= 5 ~ "3-5",
    total_visits <= 10 ~ "6-10",
    total_visits <= 25 ~ "11-25",
    total_visits <= 100 ~ "26-100",
    TRUE ~ "101+"
  )) %>%
  left_join(
    visit %>%
      select(house_id, person_id, age, race, gender, zip_code, family_type,
             housing_status, snap_house, fp_location_groups, served_date, income_bracket, income_source) %>%
      distinct(person_id, .keep_all = TRUE),
    by = "person_id"
  )


visitor_count_house <- visit %>%
  count(house_id, served_date) %>%
  group_by(house_id) %>%
  summarise(total_visits = n()) %>%
  mutate(visit_category = case_when(
    total_visits == 1 ~ "1",
    total_visits == 2 ~ "2",
    total_visits <= 5 ~ "3-5",
    total_visits <= 10 ~ "6-10",
    total_visits <= 25 ~ "11-25",
    total_visits <= 100 ~ "26-100",
    TRUE ~ "101+"
  )) %>%
  left_join(
    visit %>%
      select(house_id, person_id, race, family_type, zip_code,
             snap_house, housing_status, fp_location_groups, annual_income, income_source) %>%
      distinct(house_id, .keep_all = TRUE),
    by = "house_id"
  )

lapply(visitor_count_house, table)
lapply(visitor_count_person, table)

statshou <- visitor_count_house %>%
  select_if(is.numeric) %>%
  summarise_all(list(
    mean = ~mean(.x, na.rm = TRUE),
    min = ~min(.x, na.rm = TRUE),
    max = ~max(.x, na.rm = TRUE),
    sd = ~sd(.x, na.rm = TRUE),
    n = ~sum(!is.na(.x))  
  ))

statsper <- visitor_count_person %>%
  select_if(is.numeric) %>%
  summarise_all(list(
    mean = ~mean(.x, na.rm = TRUE),
    min = ~min(.x, na.rm = TRUE),
    max = ~max(.x, na.rm = TRUE),
    sd = ~sd(.x, na.rm = TRUE),
    n = ~sum(!is.na(.x))  
  ))




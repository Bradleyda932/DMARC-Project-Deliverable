# Step 1: Load the data and libraries
rm(list = ls())
library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
library(patchwork)

zip_code_data <- read.csv("/Users/bradley/Desktop/Sem 4/CS 190/dmarc project/zip_code_data.csv")

zip_code_data <- zip_code_data %>%
  select(-fp_number)

# pulling basic data - see html file
zip_code_data$zip_code <- substr(zip_code_data$zip_code, 1, 5) 
zip_count <- zip_code_data %>% count(zip_code) %>% arrange(zip_code)
print(zip_count)

unique_persons_by_zip <- zip_code_data %>%
  group_by(zip_code) %>%
  summarise(unique_person_count = n_distinct(person_id), .groups = 'drop')

unique_persons_by_zip

# d stats
stats <- zip_code_data %>%
  group_by(zip_code, person_id) %>%
  summarise(across(where(is.numeric), first, .names = "{.col}"), .groups = "drop") %>%
  group_by(zip_code) %>%
  summarise(across(where(is.numeric), list(
    mean = ~mean(.x, na.rm = TRUE),
    min = ~min(.x, na.rm = TRUE),
    max = ~max(.x, na.rm = TRUE),
    sd = ~sd(.x, na.rm = TRUE),
    n = ~n()  
  ), .names = "{.col}_{.fn}"), .groups = "drop")

print(stats)








# graph

# Create the family_type variable based on house_id
zip_code_data <- zip_code_data %>%
  mutate(family_type = ifelse(duplicated(house_id) | duplicated(house_id, fromLast = TRUE), "Family", "Individual"))

# Now calculate the statistics as requested
zip_code_stats <- zip_code_data %>%
  group_by(zip_code) %>%
  summarise(
    # Descriptive statistics for numerical variables - Families
    median_annual_income_families = median(annual_income[family_type == "Family"], na.rm = TRUE),
    mean_annual_income_families = mean(annual_income[family_type == "Family"], na.rm = TRUE),
    
    # Descriptive statistics for numerical variables - Individuals
    median_annual_income_individuals = median(annual_income[family_type == "Individual"], na.rm = TRUE),
    mean_annual_income_individuals = mean(annual_income[family_type == "Individual"], na.rm = TRUE),
    
    # Descriptive statistics for Age and Poverty Level
    avg_age = mean(age, na.rm = TRUE),
    sd_age = sd(age, na.rm = TRUE),
    
    avg_poverty_level = mean(poverty_level, na.rm = TRUE),
    sd_poverty_level = sd(poverty_level, na.rm = TRUE),
    
    # Gender, Ethnicity, and Race percentages, with NA handling
    percent_gender_female = sum(gender == "Female", na.rm = TRUE) / sum(!is.na(gender)) * 100,
    percent_gender_male = sum(gender == "Male", na.rm = TRUE) / sum(!is.na(gender)) * 100,
    percent_gender_other = sum(gender == "Other", na.rm = TRUE) / sum(!is.na(gender)) * 100,
    
    percent_ethnicity_hispanic = sum(ethnicity == "Hispanic", na.rm = TRUE) / sum(!is.na(ethnicity)) * 100,
    percent_ethnicity_non_hispanic = sum(ethnicity == "Non-Hispanic", na.rm = TRUE) / sum(!is.na(ethnicity)) * 100,
    
    percent_race_white = sum(race == "White", na.rm = TRUE) / sum(!is.na(race)) * 100,
    percent_race_black = sum(race == "Black", na.rm = TRUE) / sum(!is.na(race)) * 100,
    percent_race_asian = sum(race == "Asian", na.rm = TRUE) / sum(!is.na(race)) * 100,
    percent_race_other = sum(race == "Other", na.rm = TRUE) / sum(!is.na(race)) * 100
  ) %>%
  ungroup()

# View the resulting statistics for each zip code
head(zip_code_stats)

# Function to capitalize first letter of each word
capitalize_first <- function(x) {
  sapply(x, function(word) { paste0(toupper(substring(word, 1, 1)), substring(word, 2)) })
}

create_bar_plot <- function(df, var, zip_code) {
  df <- df %>%
    filter(!(!!sym(var) %in% c("Prefer Not to Respond", "Unknown", "Not Selected")), !is.na(!!sym(var)))
  
  # Identify the top 5 locations for this zip code
  top_locations <- df %>%
    filter(zip_code == !!zip_code) %>%
    group_by(fp_location_groups) %>%
    summarise(total_count = n_distinct(person_id), .groups = 'drop') %>%
    arrange(desc(total_count)) %>%
    slice_head(n = 5) %>%
    pull(fp_location_groups)
  
  # Ensure all factor levels are retained
  all_levels <- unique(df[[var]])
  
  # Capitalize variable name
  var_label <- capitalize_first(var)
  
  plot <- df %>%
    filter(zip_code == !!zip_code, fp_location_groups %in% top_locations) %>%
    group_by(fp_location_groups, !!sym(var)) %>%
    summarise(unique_count = n_distinct(person_id), .groups = 'drop') %>%
    complete(fp_location_groups, !!sym(var), fill = list(unique_count = 0)) %>%
    mutate(!!sym(var) := factor(!!sym(var), levels = all_levels)) %>%
    ggplot(aes(x = !!sym(var), y = unique_count, fill = fp_location_groups)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = paste(zip_code, "Plotted by", var_label), x = var_label, y = "Number of People", fill = "Location") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
    scale_fill_manual(values = c("red", "blue", "green", "purple", "brown", "black", "orange", "pink")) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 7))
  
  return(plot)
}

variables <- c("gender", "race", "ethnicity", "education", "family_type", "housing_status", 
               "homelessness", "income_source", "income_bracket", "age_group")

zip_codes <- unique(zip_code_data$zip_code)

for (zip in zip_codes) {
  for (var in variables) {
    plot <- create_bar_plot(zip_code_data, var, zip)
    ggsave(paste0(zip, "_", var, ".png"), plot, width = 12, height = 9, dpi = 300)
  }
}

lapply(zip_code_data, table)

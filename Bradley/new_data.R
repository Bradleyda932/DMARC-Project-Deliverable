#rm(list = ls())
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

# load & clean
current <- read.csv("/Users/bradley/Desktop/Sem 4/CS 190/dmarc project/dmarc_current_data.csv")

colnames(current) <- c("p_key", "person_id", "house_id", "middlename", "dob",
                    "gender", "race", "education", "recieved_stamp", "health_issues", "veteran_status", 
                    "pantry_type", "visit_date", "fp_location", "latitude", "longitude", 
                    "year_visited", "num_in_house", "fed_poverty_level", "annual_income", "removeme", "income_source")

current <- current %>%
  select(-middlename, -removeme)

colSums(is.na(current)) # 68 null values in dob
current$annual_income <- round(current$annual_income) 


# cleaning whole columns
# visit_date
current$visit_date <- substr(current$visit_date, 1, 10) 

# dob - age is based off dob when they attended a pantry, not as of the last data entry.
current <- current %>% 
  mutate(
    dob = ymd(dob),
    visit_date = ymd(visit_date),  
    age = round(as.numeric(difftime(visit_date, dob, units = "days")) / 365.25)
  ) %>%
  filter(age > -0.1, age <= 102, dob >= ymd("1923-01-01"))

# brackets
current$annual_income[current$annual_income < 0] <- 0

current <- current %>%
  mutate(
    income_bracket = case_when(
      annual_income == 0 ~ "No Income",
      annual_income <= 4999 ~ "$1 - $4,999",
      annual_income <= 9999 ~ "$5,000 - $9,999",
      annual_income <= 19999 ~ "$10,000 - $19,999",
      annual_income <= 49999 ~ "$20,000 - $49,999",
      annual_income <= 99999 ~ "$50,000 - $99,999",
      TRUE ~ "Over $100,000"
    ),
    fed_bracket = case_when(
      fed_poverty_level == 0 ~ "0",
      fed_poverty_level <= 24 ~ "1 - 24",
      fed_poverty_level <= 49 ~ "25 - 49",
      fed_poverty_level <= 99 ~ "50 - 99",
      fed_poverty_level <= 349 ~ "100 - 349",
      TRUE ~ "Over 350"
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

current$income_bracket <- factor(current$income_bracket, 
                              levels = c("No Income", "$1 - $4,999", "$5,000 - $9,999", 
                                         "$10,000 - $19,999", "$20,000 - $49,999", 
                                         "$50,000 - $99,999", "Over $100,000"))

current <- current %>%
  mutate(fp_location_groups = case_when(
    grepl("Families Forward Bidwell Pantry", fp_location, fixed = TRUE) ~ "Families Forward: Bidwell",
    grepl("Catholic Charities Food Pantry", fp_location, fixed = TRUE) ~ "Catholic Charities",
    grepl("Clive Community Services", fp_location, fixed = TRUE) ~ "Clive Community Services",
    grepl("DMARC-ket", fp_location, fixed = TRUE) ~ "DMARC-ket",
    grepl("Eastview", fp_location, fixed = TRUE) ~ "Caring Hands Eastview",
    grepl("Mobile", fp_location, fixed = TRUE) | grepl("MOBILE", fp_location, fixed = TRUE) ~ "DMARC Mobile",
    grepl("Polk County River Place Food Pantry", fp_location, fixed = TRUE) ~ "River Place",
    grepl("Salvation Army Clive Food Pantry", fp_location, fixed = TRUE) | grepl("S.A. TEMPLE (WEST)", fp_location, fixed = TRUE) | grepl("S.A. CITADEL (EAST)", fp_location, fixed = TRUE) ~ "Salvation Army Location",
    grepl("West Des Moines Human Services", fp_location, fixed = TRUE) ~ "WDM Human Services",
    grepl("Affiliate", fp_location, fixed = TRUE) ~ "Affiliate",
    grepl("Impact CAP - Ankeny", fp_location, fixed = TRUE) ~ "Impact CAP: Ankeny",
    grepl("IMPACT Community Action Partnership - Drake Neighborhood", fp_location, fixed = TRUE) ~ "Impact CAP: Drake",
    grepl("Johnston Partnership Food Pantry", fp_location, fixed = TRUE) ~ "Johnston Partnership",
    grepl("Polk County Northside Food Pantry", fp_location, fixed = TRUE) ~ "Northside",
    grepl("Adel Good Samaritan Food Pantry", fp_location, fixed = TRUE) ~ "Adel Good Samaritan",
    grepl("Helping Hand of Warren County", fp_location, fixed = TRUE) ~ "Helping Hand: Warren County",
    grepl("Urbandale Food Pantry", fp_location, fixed = TRUE) ~ "Urbandale",
    grepl("WayPoint Resources", fp_location, fixed = TRUE) ~ "WayPoint",
    grepl("St. Vincent de Paul 6th Avenue Food Pantry", fp_location, fixed = TRUE) | grepl("St. Vincent de Paul Army Post Food Pantry", fp_location, fixed = TRUE) ~ "St. Vincent Location",
    TRUE ~ "Other"
  ))

current <- current %>%
  mutate(income_source_groups = case_when(
    grepl("Child Support", income_source, fixed = TRUE) ~ "Child Support",
    grepl("Disability/Pending Disability", income_source, fixed = TRUE) ~ "Disability Benefits",
    grepl("Don't Know/Unknown", income_source, fixed = TRUE) ~ "Not Provided",
    grepl("FIP (Family Investment Program)", income_source, fixed = TRUE) ~ "FIP (Family Investment Program)",
    grepl("Full Time", income_source, fixed = TRUE) ~ "Employed Full-Time",
    grepl("Other (Self Employed, Seasonal, etc.)", income_source, fixed = TRUE) ~ "Other",
    grepl("Part Time", income_source, fixed = TRUE) ~ "Employed Part-Time",
    grepl("Retired/Social Security", income_source, fixed = TRUE) ~ "Retirement Benefits",
    grepl("Stay at Home Parent/Caregiver", income_source, fixed = TRUE) ~ "Caregiver",
    grepl("Student/Work Training", income_source, fixed = TRUE) ~ "In Training",
    grepl("Unemployment Benefits", income_source, fixed = TRUE) ~ "Unemployment Benefits",
    grepl("Unemployed No Income", income_source, fixed = TRUE) ~ "No Income",
    TRUE ~ "Other"
  ))

# Step 5: segment years
current <- current %>%
  mutate(segmented_years = case_when(
    visit_date >= "2018-01-01" & visit_date <= "2019-12-31" ~ "2018-2019",
    visit_date >= "2020-01-01" & visit_date <= "2022-12-31" ~ "2020-2022",
    visit_date >= "2023-01-01" ~ "2023-Present",
    TRUE ~ "Other"
  ))

data_2018_2019 <- current %>% filter(segmented_years == "2018-2019")
data_2020_2022 <- current %>% filter(segmented_years == "2020-2022")
data_2023_present <- current %>% filter(segmented_years == "2023-Present")
library(tidyverse)
library(RColorBrewer)

# Variables to plot
vars <- c("gender", "race", "education", "income_source_groups", 
          "fp_location_groups", "income_bracket", "age_group")

# Output folder
output_dir <- "segmented_bar_plots"
if (!dir.exists(output_dir)) dir.create(output_dir)

# Manual levels for ordered categorical vars
ordered_levels_list <- list(
  income_bracket = c("No Income", "$1 - $4,999", "$5,000 - $9,999", 
                     "$10,000 - $19,999", "$20,000 - $49,999", 
                     "$50,000 - $99,999", "Over $100,000"),
  age_group = c("Infant", "Toddler", "Child", "Teenager", 
                "Young Adult", "Adult", "Elderly")
)

# Helper function
clean_group <- function(x) {
  str_trim(x) %>%
    str_replace_all("\\s*\\(.*?\\)", "") %>%
    str_trim()
}

# Loop through each variable
for (var in vars) {
  
  df <- current %>%
    filter(segmented_years != "Other") %>%
    filter(!str_detect(!!sym(var), regex("Other|Unknown|Not Selected", ignore_case = TRUE))) %>%
    group_by_at(c("segmented_years", var)) %>%
    summarise(unique_people = n_distinct(person_id), .groups = "drop") %>%
    rename(group = all_of(var)) %>%
    mutate(group = clean_group(group)) %>%
    mutate(group = sapply(str_split(group, "\\s+"), function(words) paste(head(words, 4), collapse = " ")))
  
  # Filter out groups with < 50 total across years
  group_totals <- df %>%
    group_by(group) %>%
    summarise(total = sum(unique_people), .groups = "drop") %>%
    filter(total >= 50)
  
  df <- df %>% filter(group %in% group_totals$group)
  
  if (nrow(df) == 0) next
  
  # Apply manual factor levels if applicable
  if (var %in% names(ordered_levels_list)) {
    valid_levels <- intersect(ordered_levels_list[[var]], unique(df$group))
    df$group <- factor(df$group, levels = valid_levels)
  } else {
    df$group <- factor(df$group)  # fallback: categorical
  }
  
  # BuPu palette
  year_groups <- unique(df$segmented_years)
  n_colors <- length(year_groups)
  fill_colors <- brewer.pal(max(3, n_colors), "BuPu")[1:n_colors]
  
  # Plot
  p <- ggplot(df, aes(x = group, y = unique_people, fill = segmented_years)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = fill_colors, name = "Year Group") +
    scale_y_continuous(labels = scales::comma) +
    labs(
      title = paste("Unique Visitors by", str_to_title(gsub("_", " ", var))),
      x = str_to_title(gsub("_", " ", var)),
      y = "Unique People"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
      axis.text.x = element_text(angle = 30, hjust = 1),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      legend.background = element_rect(fill = "white", color = NA)
    )
  
  ggsave(filename = paste0(output_dir, "/", var, "_by_year_ordered_final.png"),
         plot = p, width = 14, height = 7, dpi = 300)
}

lapply(current, table)

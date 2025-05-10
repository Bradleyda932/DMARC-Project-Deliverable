library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(lubridate)
library(RColorBrewer)

# Recode demographics from `current`
current_recode <- current %>%
  mutate(
    visit_year = year(ymd(visit_date)),
    
    acs_age_group = case_when(
      age <= 18 ~ "Minor",
      age <= 24 ~ "Young Adult",
      age <= 64 ~ "Adult",
      TRUE ~ "Elderly"
    ),
    
    acs_race = case_when(
      grepl("white", race, ignore.case = TRUE) ~ "White",
      grepl("black|african", race, ignore.case = TRUE) ~ "Black",
      grepl("asian", race, ignore.case = TRUE) ~ "Asian",
      grepl("hispanic|latino", race, ignore.case = TRUE) ~ "Hispanic",
      TRUE ~ "Other"
    ),
    
    acs_snap = ifelse(recieved_stamp == 1, "SNAP", "No SNAP"),
    
    acs_poverty = case_when(
      fed_bracket %in% c("Over 200") ~ "Above Current Poverty Line",
      fed_bracket %in% c("Below 50", "50 - 99", "100 - 200") ~ "Below Current Poverty Line",
      TRUE ~ "Unknown"
    ),
    

    acs_household_structure = ifelse(num_in_house >= 3, "3+ Person Household", "1–2 Person Household"),
    
    # Add this to the demographic string
    acs_demo_ext = paste(acs_age_group, acs_race, acs_snap, acs_poverty, acs_household_structure, sep = " | ")
  ) %>%
  filter(
    !grepl("Other", acs_race),
    !grepl("Unknown", acs_poverty)
  )
# Count visits per group
yearly_counts <- current_recode %>%
  group_by(visit_year, acs_demo_ext) %>%
  summarise(n_visits = n(), .groups = "drop")

#  Normalize shares
yearly_shares <- yearly_counts %>%
  group_by(visit_year) %>%
  mutate(share = n_visits / sum(n_visits)) %>%
  ungroup()

# Compare two years of interest
first_year <- 2018
last_year <- 2024

# Collapse to one row per year
yearly_collapsed <- yearly_shares %>%
  group_by(acs_demo_ext, visit_year) %>%
  summarise(share = sum(share), .groups = "drop")

#pivot
type_changes <- yearly_collapsed %>%
  filter(visit_year %in% c(2018, 2024)) %>%
  pivot_wider(
    names_from = visit_year,
    values_from = share,
    values_fill = NA
  ) %>%
  mutate(
    change = `2024` - `2018`
  ) %>%
  arrange(desc(change))

# Plot top 5 growing visitor types
top_growth <- type_changes %>%
  slice_max(order_by = change, n = 5)

ggplot(top_growth, aes(x = reorder(acs_demo_ext, change), y = change, fill = change)) +
  geom_col() +
  geom_text(aes(label = percent(change, accuracy = 0.1)), 
            hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.1))) +
  scale_fill_distiller(palette = "BuPu", direction = 1) +
  labs(
    title = paste("Top 5 Growing Demographic Groups (", first_year, " to ", last_year, ")", sep = ""),
    x = "Demographic Group",
    y = "Change in Visit Share",
    fill = "Visit Share\nChange"
  ) +
  theme_minimal()


# Get top 5 most declining groups
bottom_decline <- type_changes %>%
  slice_min(order_by = change, n = 5)


library(ggplot2)
library(scales)

ggplot(bottom_decline, aes(x = reorder(acs_demo_ext, change), y = change)) +
  geom_col(fill = "orange") +
  geom_text(
    aes(label = percent(change, accuracy = 0.1)),
    hjust = -0.1, size = 3.5, color = "black"
  ) +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Top 5 Declining Demographic Groups (2018 to 2024)",
    x = "Demographic Group",
    y = "Change in Visit Share"
  ) +
  theme_minimal()




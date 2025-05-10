rm(list = ls())

library(tidyverse)
library(lubridate)
library(mgcv) # for GAMs

# Aggregate and clean monthly data
monthly_data <- current %>%
  mutate(year_month = floor_date(visit_date, "month")) %>%
  group_by(year_month) %>%
  summarise(
    total_visits = n(),
    avg_age = mean(age, na.rm = TRUE),
    avg_household = mean(num_in_house, na.rm = TRUE),
    avg_fpl = mean(fed_poverty_level, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  filter(year(year_month) < 2020 | year(year_month) > 2021) %>% #Removing covid era data
  mutate(
    time_index = as.numeric(difftime(year_month, min(year_month), units = "days")) / 30.44,
    month = lubridate::month(year_month, label = TRUE)
  )


# Fit GLM for visits
glm_fit <- glm(
  total_visits ~ time_index + factor(month) + avg_age + avg_household + avg_fpl,
  data = monthly_data,
  family = poisson()
)

# GAMs for pred variables
age_model <- gam(avg_age ~ s(time_index), data = monthly_data)
hh_model  <- gam(avg_household ~ s(time_index), data = monthly_data)
fpl_model <- gam(avg_fpl ~ s(time_index), data = monthly_data)


# Build 2025 forecast
# Create base future data frame
future_df <- tibble(
  year_month = future_dates,
  time_index = as.numeric(difftime(future_dates, min(monthly_data$year_month), units = "days")) / 30.44,
  month = lubridate::month(future_dates, label = TRUE)
)

# Add predictions from GAMs
future_df <- future_df %>%
  mutate(
    avg_age = predict(age_model, newdata = .),
    avg_household = predict(hh_model, newdata = .),
    avg_fpl = predict(fpl_model, newdata = .)
  )

# Generate forecast with confidence interval
pred <- predict(glm_fit, newdata = future_df, type = "link", se.fit = TRUE)
future_df <- future_df %>%
  mutate(
    fit_link = pred$fit,
    se_link = pred$se.fit,
    predicted_visits = exp(fit_link),
    lower = exp(fit_link - 1.96 * se_link),
    upper = exp(fit_link + 1.96 * se_link),
    type = "Forecast"
  ) %>%
  select(year_month, predicted_visits, lower, upper, type)

# Combine actual and forecast
plot_df <- bind_rows(
  monthly_data %>%
    select(year_month, total_visits) %>%
    mutate(type = "Actual"),
  
  future_df %>%
    rename(total_visits = predicted_visits)
) %>%
  filter(year(year_month) >= 2023)

# Plot results
ggplot() +
  geom_line(data = filter(plot_df, type == "Actual"), aes(x = year_month, y = total_visits), color = "blue") +
  geom_ribbon(data = filter(plot_df, type == "Forecast"), aes(x = year_month, ymin = lower, ymax = upper), fill = "red", alpha = 0.1) +
  geom_line(data = filter(plot_df, type == "Forecast"), aes(x = year_month, y = total_visits), color = "red") +
  labs(
    title = "Predicting Future Monthly Pantry Visits w/ Poisson Model & a 95% Confidence Interval",
    x = "Month",
    y = "Visits"
  ) +
  theme_minimal()





summary(glm_fit)

# Chi-square test
pchisq(60383 - 2932, df = 59 - 44, lower.tail = FALSE)

# p value nearly = 0



before <- current %>% select(visit_date, age, num_in_house, fed_poverty_level)


head(monthly_data)






























rm(list = ls())

# Load libraries
library(tidyverse)
library(lubridate)
library(mgcv) # for GAMs

# Aggregate and clean monthly data
monthly_data <- current %>%
  mutate(year_month = floor_date(visit_date, "month")) %>%
  group_by(year_month) %>%
  summarise(
    total_visits = n(),
    avg_age = mean(age, na.rm = TRUE),
    avg_household = mean(num_in_house, na.rm = TRUE),
    avg_fpl = mean(fed_poverty_level, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  filter(year(year_month) < 2020 | year(year_month) > 2021) %>% #Removing covid era data
  mutate(
    time_index = as.numeric(difftime(year_month, min(year_month), units = "days")) / 30.44,
    month = lubridate::month(year_month, label = TRUE)
  )

# Fit GAMs for covariates
age_model <- gam(avg_age ~ s(time_index), data = monthly_data)
hh_model  <- gam(avg_household ~ s(time_index), data = monthly_data)
fpl_model <- gam(avg_fpl ~ s(time_index), data = monthly_data)

# Fit GLM for visits
glm_fit <- glm(
  total_visits ~ time_index + factor(month) + avg_age + avg_household + avg_fpl,
  data = monthly_data,
  family = poisson()
)

# Build forecast frame for 2025
future_dates <- seq.Date(from = as.Date("2025-01-01"), to = as.Date("2025-12-01"), by = "month")
future_df <- tibble(
  year_month = future_dates,
  time_index = as.numeric(difftime(future_dates, min(monthly_data$year_month), units = "days")) / 30.44,
  month = lubridate::month(future_dates, label = TRUE)
) %>%
  mutate(
    avg_age = predict(age_model, newdata = .),
    avg_household = predict(hh_model, newdata = .),
    avg_fpl = predict(fpl_model, newdata = .)
  )

# Generate forecast with CI
pred <- predict(glm_fit, newdata = future_df, type = "link", se.fit = TRUE)
future_df <- future_df %>%
  mutate(
    fit_link = pred$fit,
    se_link = pred$se.fit,
    predicted_visits = exp(fit_link),
    lower = exp(fit_link - 1.96 * se_link),
    upper = exp(fit_link + 1.96 * se_link),
    type = "Forecast"
  ) %>%
  select(year_month, predicted_visits, lower, upper, type)

# Combine actual and forecast
plot_df <- bind_rows(
  monthly_data %>%
    select(year_month, total_visits) %>%
    mutate(type = "Actual"),
  
  future_df %>%
    rename(total_visits = predicted_visits)
) %>%
  filter(year(year_month) >= 2023)

# Plot results
ggplot() +
  geom_line(data = filter(plot_df, type == "Actual"), aes(x = year_month, y = total_visits), color = "blue") +
  geom_ribbon(data = filter(plot_df, type == "Forecast"), aes(x = year_month, ymin = lower, ymax = upper), fill = "red", alpha = 0.1) +
  geom_line(data = filter(plot_df, type == "Forecast"), aes(x = year_month, y = total_visits), color = "red") +
  labs(
    title = "Predicting Future Monthly Pantry Visits w/ Poisson Model & a 95% Confidence Interval",
    x = "Year",
    y = "Visits"
  ) +
  theme_minimal()



#CLEANING

#Drop the "lnm" column
all <- all %>% select(-lnm)

#Change all Blanks or "Not Selected" to "Unknown"
all[all == ""] <- "Unknown"
all[all == "Not Selected"] <- "Unknown"

#Clean ZIP
all$zip <- substr(all$zip, 1, 5)

#Clean Ethnicity
unique(all$ethnicity)
all$ethnicity[all$ethnicity == "Other"] <- "Unknown"
unique(all$ethnicity)

#Clean Annual Income
all$annual_income[all$annual_income < 0] <- 0
summary(all$annual_income)

all$income_bracket <- ""
all <- all %>% mutate(income_bracket = case_when(annual_income == 0 ~ "No Income",
                                                 annual_income > 0 & annual_income <= 10000 ~ "$0 - $10,000",
                                                 annual_income > 10000 & annual_income <= 20000 ~ "$10,000 - $20,000",
                                                 annual_income > 20000 & annual_income <= 50000 ~ "$20,000 - $50,000",
                                                 annual_income > 50000 & annual_income <= 100000 ~ "$50,000 - $100,000",
                                                 annual_income > 100000 ~ "Over $100,000"))

income_counts <- all %>%
  group_by(income_bracket) %>%
  summarise(count = n(), .groups = 'drop')


#Clean Fed. Poverty Level
all$fed_poverty_level[all$fed_poverty_level < 0] <- 0

all$fed_bracket <- ""
all <- all %>% mutate(fed_bracket = case_when(fed_poverty_level == 0 ~ "0",
                                              fed_poverty_level > 0 & fed_poverty_level <= 50 ~ "0 - 50",
                                              fed_poverty_level > 50 & fed_poverty_level <= 100 ~ "50 - 100",
                                              fed_poverty_level > 100 & fed_poverty_level <= 200 ~ "100 - 200",
                                              fed_poverty_level > 200 & fed_poverty_level <= 500 ~ "200 - 500",
                                              fed_poverty_level > 500 ~ "Over 500"))

fed_counts <- all %>%
  group_by(fed_bracket) %>%
  summarise(count = n(), .groups = 'drop')

#Add Age Variable
all <- all %>% 
  mutate(served_date = ymd(served_date),
         dob = ymd(dob)
  )

all$age <- as.numeric(difftime(all$served_date, all$dob, units = "days")) / 365.25

#Clean DOB and Age

all <- all %>% filter(!(all$age < 0))
all <- all %>% filter(!(all$age > 120))

all <- all %>% 
  mutate(served_date = ymd(served_date),
         dob = ymd(dob)
  )

all$age <- as.numeric(difftime(all$served_date, all$dob, units = "days")) / 365.25
summary(all)

#Add Age Group
all$age_group <- ""

all <- all %>% mutate(age_group = case_when(age <= 1 ~ "Infant",
                                            age <= 4 ~ "Toddler",
                                            age <= 12 ~ "Child",
                                            age <= 17 ~ "Teenager",
                                            age <= 24 ~ "Young Adult",
                                            age <= 64 ~ "Adult",
                                            age > 64 ~ "Elderly"))

age_counts <- all %>%
  group_by(age_group) %>%
  summarise(count = n(), .groups = 'drop')

#Clean Location
all <- all %>% filter(all$location != "Unknown")
all <- all %>% filter(all$location != "all")

all$location_groups <- ""
all <- all %>% mutate(location_groups = case_when(grepl("Bidwell", all$location, fixed = TRUE) == TRUE ~ "Families Forward - Bidwell",
                                                  grepl("Eastview", all$location, fixed = TRUE) == TRUE ~ "Caring Hands Eastview",
                                                  grepl("Catholic Charities", all$location, fixed = TRUE) == TRUE ~ "Catholic Charities",
                                                  grepl("Central Iowa", all$location, fixed = TRUE) == TRUE ~ "Central Iowa Shelter",
                                                  grepl("Clive", all$location, fixed = TRUE) == TRUE ~ "Clive CS",
                                                  grepl("DMARC-ket", all$location, fixed = TRUE) == TRUE ~ "DMARC-ket",
                                                  grepl("DRAKE", all$location, fixed = TRUE) == TRUE ~ "IMPACT CAP - Drake",
                                                  grepl("Ankeny", all$location, fixed = TRUE) == TRUE ~ "IMPACT CAP - Ankeny",
                                                  grepl("PARTNERSHIP", all$location, fixed = TRUE) == TRUE ~ "Johnston Partnership",
                                                  grepl("North Side", all$location, fixed = TRUE) == TRUE ~ "North Side",
                                                  grepl("River Place", all$location, fixed = TRUE) == TRUE ~ "River Place",
                                                  grepl("Salvation", all$location, fixed = TRUE) == TRUE ~ "Salvation Army Clive",
                                                  grepl("S.A. TEMPLE", all$location, fixed = TRUE) == TRUE ~ "Salvation Army Clive",
                                                  grepl("WDM", all$location, fixed = TRUE) == TRUE ~ "WDM Human Services",
                                                  grepl("URBANDALE", all$location, fixed = TRUE) == TRUE ~ "Urbandale",
                                                  grepl("Mobile", all$location, fixed = TRUE) == TRUE ~ "DMARC Mobile",
                                                  grepl("MOBILE", all$location, fixed = TRUE) == TRUE ~ "DMARC Mobile",
                                                  grepl("Affiliate", all$location, fixed = TRUE) == TRUE ~ "Affiliate",
                                                  TRUE ~ "Other"))

unique(all$location_groups)

#Add Served Year and Month
all <- all %>% mutate(served_year = year(served_date))
all <- all %>% mutate(served_month = month(served_date))


#As of now, all other columns do not require any cleaning. If cleaning were needed in the future,
#run the following code to locate the unwanted values for each variable.

unique(all$service_name)
unique(all$gender)
unique(all$race)
unique(all$education)
unique(all$family_type)
unique(all$snap_household)
unique(all$housing)
unique(all$housing_type)
unique(all$homeless)

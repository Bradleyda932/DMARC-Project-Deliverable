#DISCLAIMER - The following code works only on the dataset provided on 2/13/2024.

#YEARLY COMPARISONS

selected_year1 <- 2022
selected_year2 <- 2023
selected_zip <- 50314

#Gender
year_comp_gen <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, gender) %>% mutate(gender = recode(gender, "Man (boy)" = "Male", "Woman (girl)" = "Female"))


year_comp_gen$gender <- factor(year_comp_gen$gender, 
                               levels = c("Male", "Female"))

year_comp_gen <- year_comp_gen %>% filter(!is.na(gender))

ggplot(year_comp_gen, aes(x = factor(served_year), y = n, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Gender of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Gender") +
  theme_minimal()

#Race
year_comp_race <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, race)

year_comp_race$race <- factor(year_comp_race$race, 
                              levels = c("White", "Black/African American", "Asian", "Other"))

year_comp_race <- year_comp_race %>% filter(!is.na(race))

ggplot(year_comp_race, aes(x = factor(served_year), y = n, fill = race)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Race of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Race") +
  theme_minimal()

#Ethnicity
year_comp_eth <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, ethnicity)

year_comp_eth$ethnicity <- factor(year_comp_eth$ethnicity, 
                                  levels = c("Hispanic or Latino", "Not Hispanic or Latino"))

year_comp_eth <- year_comp_eth %>% filter(!is.na(ethnicity))

ggplot(year_comp_eth, aes(x = factor(served_year), y = n, fill = ethnicity)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Ethnicity of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Ethnicity") +
  theme_minimal()

#Education
year_comp_edu <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, education)

year_comp_edu$education <- factor(year_comp_edu$education, 
                                  levels = c("Pre-K and younger (Currently)", "K-8 (Currently)", "K-12 Drop Out", "9-12 (Currently)", "HS Grad", "HS Grad / Some College"))

year_comp_edu <- year_comp_edu %>% filter(!is.na(education))

ggplot(year_comp_edu, aes(x = factor(served_year), y = n, fill = education)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Education of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Education Level") +
  theme_minimal()

#Family Type
year_comp_fam <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, family_type)

year_comp_fam$family_type <- factor(year_comp_fam$family_type, 
                                    levels = c("Single Person", "Female Adult with Children", "Male Adult with Children", "Adults Without Children", "Adults with Children"))

year_comp_fam <- year_comp_fam %>% filter(!is.na(family_type))

ggplot(year_comp_fam, aes(x = factor(served_year), y = n, fill = family_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Family Type of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Family Type") +
  theme_minimal()

#Homeless
year_comp_home <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, homeless)

year_comp_home$homeless <- factor(year_comp_home$homeless, 
                                  levels = c("Unstably Housed", "Imminently Homeless", "Literally Homeless"))

year_comp_home <- year_comp_home %>% filter(!is.na(homeless))

ggplot(year_comp_home, aes(x = factor(served_year), y = n, fill = homeless)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Housing Status of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Housing Status") +
  theme_minimal()

#Income
year_comp_inc <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, income_bracket)

year_comp_inc$income_bracket <- factor(year_comp_inc$income_bracket, 
                                       levels = c("No Income", "$0 - $10,000", "$10,000 - $20,000", "$20,000 - $50,000", "$50,000 - $100,000"))

year_comp_inc <- year_comp_inc %>% filter(!is.na(income_bracket))

ggplot(year_comp_inc, aes(x = factor(served_year), y = n, fill = income_bracket)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Income Bracket of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Income Bracket") +
  theme_minimal()

#Federal Poverty Level
year_comp_fed <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, fed_bracket)

year_comp_fed$fed_bracket <- factor(year_comp_fed$fed_bracket, 
                                    levels = c("0", "0 - 50", "50 - 100", "100 - 200", "200 - 500"))

year_comp_fed <- year_comp_fed %>% filter(!is.na(fed_bracket))

ggplot(year_comp_fed, aes(x = factor(served_year), y = n, fill = fed_bracket)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Federal Poverty Level of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Fed. Poverty Level") +
  theme_minimal()

#Age
year_comp_age <- all %>% filter(selected_zip == zip & (selected_year1 == served_year | selected_year2 == served_year)) %>% 
  count(served_year, age_group)

year_comp_age$age_group <- factor(year_comp_age$age_group, 
                                  levels = c("Infant", "Toddler", "Child", "Teenager", "Young Adult", "Adult", "Elderly"))

year_comp_age <- year_comp_age %>% filter(!is.na(age_group))

ggplot(year_comp_age, aes(x = factor(served_year), y = n, fill = age_group)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  labs(title = paste("Age of Visitors in ZIP:", selected_zip), x = "Year",
       y = "Number of Visitors", fill = "Age Group") +
  theme_minimal()

#MONTHLY COMPARISONS
selected_year1 <- 2023
selected_month1 <- 12
selected_year2 <- 2024
selected_month2 <- 1
selected_zip <- 50314

#Gender
month_comp_gen <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, gender) %>% mutate(gender = recode(gender, "Man (boy)" = "Male", "Woman (girl)" = "Female"))

month_comp_gen$gender <- factor(month_comp_gen$gender, 
                                levels = c("Male", "Female"))

month_comp_gen <- month_comp_gen %>% filter(!is.na(gender))

month_comp_gen$month_year <- paste(month.abb[month_comp_gen$served_month], month_comp_gen$served_year, sep = " ")

ggplot(month_comp_gen, aes(x = factor(month_year), y = n, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_gen$month_year[1], month_comp_gen$month_year[3])) +
  labs(title = paste("Gender of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Gender") +
  theme_minimal()

#Race
month_comp_race <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, race)

month_comp_race$race <- factor(month_comp_race$race, 
                               levels = c("White", "Black/African American", "Asian", "Other"))

month_comp_race <- month_comp_race %>% filter(!is.na(race))

month_comp_race$month_year <- paste(month.abb[month_comp_race$served_month], month_comp_race$served_year, sep = " ")

ggplot(month_comp_race, aes(x = factor(month_year), y = n, fill = race)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_race$month_year[1], month_comp_race$month_year[5])) +
  labs(title = paste("Race of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Race") +
  theme_minimal()

#Ethnicity
month_comp_eth <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, ethnicity)

month_comp_eth$ethnicity <- factor(month_comp_eth$ethnicity, 
                                   levels = c("Hispanic or Latino", "Not Hispanic or Latino"))

month_comp_eth <- month_comp_eth %>% filter(!is.na(ethnicity))

month_comp_eth$month_year <- paste(month.abb[month_comp_eth$served_month], month_comp_eth$served_year, sep = " ")

ggplot(month_comp_eth, aes(x = factor(month_year), y = n, fill = ethnicity)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_eth$month_year[1], month_comp_eth$month_year[3])) +
  labs(title = paste("Ethnicity of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Ethnicity") +
  theme_minimal()

#Education
month_comp_edu <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, education)

month_comp_edu$education <- factor(month_comp_edu$education, 
                                   levels = c("Pre-K and younger (Currently)", "K-8 (Currently)", "K-12 Drop Out", "9-12 (Currently)", "HS Grad", "HS Grad / Some College"))

month_comp_edu <- month_comp_edu %>% filter(!is.na(education))

month_comp_edu$month_year <- paste(month.abb[month_comp_edu$served_month], month_comp_edu$served_year, sep = " ")

ggplot(month_comp_edu, aes(x = factor(month_year), y = n, fill = education)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_edu$month_year[1], month_comp_edu$month_year[8])) +
  labs(title = paste("Education of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Education Level") +
  theme_minimal()

#Family Type
month_comp_fam <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, family_type)

month_comp_fam$family_type <- factor(month_comp_fam$family_type, 
                                     levels = c("Single Person", "Female Adult with Children", "Male Adult with Children", "Adults Without Children", "Adults with Children"))

month_comp_fam <- month_comp_fam %>% filter(!is.na(family_type))

month_comp_fam$month_year <- paste(month.abb[month_comp_fam$served_month], month_comp_fam$served_year, sep = " ")

ggplot(month_comp_fam, aes(x = factor(month_year), y = n, fill = family_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_fam$month_year[1], month_comp_fam$month_year[8])) +
  labs(title = paste("Family Type of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Family Type") +
  theme_minimal()

#Homeless
month_comp_home <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, homeless)

month_comp_home$homeless <- factor(month_comp_home$homeless, 
                                   levels = c("Unstably Housed", "Imminently Homeless", "Literally Homeless"))

month_comp_home <- month_comp_home %>% filter(!is.na(homeless))

month_comp_home$month_year <- paste(month.abb[month_comp_home$served_month], month_comp_home$served_year, sep = " ")

ggplot(month_comp_home, aes(x = factor(month_year), y = n, fill = homeless)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_home$month_year[1], month_comp_home$month_year[5])) +
  labs(title = paste("Housing Status of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Housing Status") +
  theme_minimal()

#Income
month_comp_inc <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, income_bracket)

month_comp_inc$income_bracket <- factor(month_comp_inc$income_bracket, 
                                        levels = c("No Income", "$0 - $10,000", "$10,000 - $20,000", "$20,000 - $50,000", "$50,000 - $100,000"))

month_comp_inc <- month_comp_inc %>% filter(!is.na(income_bracket))

month_comp_inc$month_year <- paste(month.abb[month_comp_inc$served_month], month_comp_inc$served_year, sep = " ")

ggplot(month_comp_inc, aes(x = factor(month_year), y = n, fill = income_bracket)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_inc$month_year[1], month_comp_inc$month_year[7])) +
  labs(title = paste("Income of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Income Bracket") +
  theme_minimal()

#Federal Poverty Level
month_comp_fed <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, fed_bracket)

month_comp_fed$fed_bracket <- factor(month_comp_fed$fed_bracket, 
                                     levels = c("0", "0 - 50", "50 - 100", "100 - 200", "200 - 500"))

month_comp_fed <- month_comp_fed %>% filter(!is.na(fed_bracket))

month_comp_fed$month_year <- paste(month.abb[month_comp_fed$served_month], month_comp_fed$served_year, sep = " ")

ggplot(month_comp_fed, aes(x = factor(month_year), y = n, fill = fed_bracket)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_fed$month_year[1], month_comp_fed$month_year[7])) +
  labs(title = paste("Federal Poverty Level of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Fed. Poverty Level") +
  theme_minimal()

#Age
month_comp_age <- all %>% filter((selected_zip == zip) & ((selected_year1 == served_year & selected_month1 == served_month) | (selected_year2 == served_year & selected_month2 == served_month))) %>% 
  count(served_year, served_month, age_group)

month_comp_age$age_group <- factor(month_comp_age$age_group, 
                                   levels = c("Infant", "Toddler", "Child", "Young Adult", "Adult", "Elderly"))

month_comp_age <- month_comp_age %>% filter(!is.na(age_group))

month_comp_age$month_year <- paste(month.abb[month_comp_age$served_month], month_comp_age$served_year, sep = " ")

ggplot(month_comp_age, aes(x = factor(month_year), y = n, fill = age_group)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_brewer(palette = "BuPu") +
  scale_x_discrete(labels = c(month_comp_age$month_year[1], month_comp_age$month_year[8])) +
  labs(title = paste("Age of Visitors in ZIP:", selected_zip), x = "Month/Year",
       y = "Number of Visitors", fill = "Age Group") +
  theme_minimal()

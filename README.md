# **DMARC Project Deliverable: Team 9**

## **Bradley Antholz, Tim Frantz, Oliver Williams**

## **Project Timeline**

> This is a timeline of our project, from the first week to the final presentations. Each folder found in the repo is our own code, organized by who created each file. They are all mentioned below at some point. 

---

### **Cleaning the Code**  
None of us had dealt with a dataset this large before, so we all agreed that cleaning was the first step. We did this separately,  
then combined our efforts into a Google Doc. This took up the first two weeks. Of course, we never stopped cleaning data when we encountered issues, so all of our files have elements of cleaning in them.

The point of cleaning was to make the data more usable and universal (for example, using age instead of date of birth), but also more understandable to the audience. Some examples of things we changed include: 

* Added age using dob: age works better for trend analysis  
* Added income brackets from annual income: makes it better for graphs  
* Removed lnm and housing type variables: lnm was too revealing and housing_type was repetitive with homelessness and housing_status  
* Grouped pantry locations together: Instead of 90 locations, we grouped them into 17–20

These additions greatly helped our early analysis of the data, and some made it into our final presentation (income_bracket).

##### Related code:
* Tim:
  * final_cleaning_code.R

* Bradley:
  * clean_dmarc_data.R

---

### **Looking Deeper into Zip Codes**  
After cleaning, further analysis pointed out that there was a set of zip codes in the Des Moines area, specifically 50314, 50316, 50265 and the Pleasant Hill area. There was a growing need for basic resources in those areas, and yet there is almost no pantries in any of those areas (50314 and 50265 have 0, 50316 has 1, the zip codes in Pleasant Hill have 1 combined). We wanted to focus on people outside of major population hubs, as these people tend to be closer to the national averages, not contributing much to what we're after. As such, we broke down the areas into three categories, outlined below.

**Des Moines direct:**

* 50311 (Drake)  
* 50314 (River Bend)  
* 50315 (South of downtown)  
* 50316 (Union Park)

**Suburbs:**

* 50265 (West Des Moines)  
* 50327 (Pleasant Hill)

**Around the metro:**

* 50047 (Carlisle, IA)  
* 50069 (De Soto, IA)  
* 50118 (Hartford, IA)  
* 50125 (Indianola, IA)  
* 50233 (Redfield, IA)

##### Related code: 
* Bradley: 
  * zip_code_data.R  
> Other zip_code files are mentioned in the next few sections

---

### **ACS Data Introduced (Heat Map Made)**  
Professor Manley introduced us to the ACS data, and Oliver immediately got to work, creating 4 R files in all. He found the top at-risk zip codes in Des Moines, and I picked the top 12 areas (50137 has no entries in the dataset, so it was removed), sorted into the three categories. This really helped us understand which zip codes we should focus on, and it was *very* clear that 50314 and 50316 need help. 

#### Files used:
* Oliver:
  * atriskzip.png is a screenshot of ACS data after Oliver tinkered with it. 

#### Related Code:
* Oliver:
  * cs_compatible_demographics.R  
  * acs_demographics.R  
  * acs_zipmap.R  
  * clean_acs.R

---

### **First Presentation**  
> Note: we edited this presentation for our final presentation, so we do not have the actual presentation anymore. The rankings of each zip code is their place on the most at-risk list (sorted by visitor percentage), in atriskzip.png.

Our first presentation really leaned into the at-risk data, and focused on the demographics of 50314 (1st), 50316 (2nd), 50265 (15th) and 50047 (17th). Here are some highlights from it:

* Bradley pointed out that, among the 11 zip codes, 50314 was the only predominantly Black community — a great candidate for further analysis  
* Tim did the behind-the-scenes work and made most of the graphs for the presentation  
* Oliver's heat map was a great shock-factor, as it showed 88% of the population of 50314 had been to a food pantry

We got good feedback from the audience, and would take it into consideration heading into the future. 

> No code files are found in this section.

---

### **New Data Introduced**  
The new data was a game changer. Although we didn't have a prediction model (yet), we were very eager to get our hands on the new data. Once we did, we followed a similar pattern to the beginning of the semester. 

Bradley was in charge of cleaning the data. He:  
* Renamed all columns for ease of understanding  
* Recreated age, income bracket, etc. using the same methods as before  

Once this was done, Tim and Oliver got to work performing trend analysis, seeing what they could get from the new data. Unfortunately, we all realized that the zip code variable was removed with the new data, so we needed a new idea going forward. 

#### Related code:
* Bradley: 
  * new_data.R

---

### **Shift in Focus**  
We brainstormed several ideas for how we should proceed, and we landed on the change in demographics from the older data to the newer stuff. This became Tim's niche in the project, going all in on creating graphs and mapping out what we should do with the new data. 

Although we lost data from 50314, we knew that those within the area were coming more recently, but there was a larger group that needed to be addressed: Hispanic/Latino/a. Tim and Oliver found that they were by far the biggest risers from 2018–2019 to 2023–2024, having a significant jump in visitors (Slides 6 and 7 in our presentation). 

The group decided that it was best to focus on the fastest growing demographics for the remainder of the project, answering the question: *Who is coming more recently?*

#### Related code:
* Tim:
  * yearly_and_monthly_comparisons.R

---

### **Final Presentation**  
> The sections from getting the new data until the end all have a slide in the final presentation, so we will discuss them all here.

*Modeling:* Oliver created a model that forecasts expected 2025 visitors, and it shows that the record number of visitors will continue to increase, with new peaks late in the year. Slide 5.  
* Code:
  * Oliver:
    * predictive_modelling.R  
    * zip_map_final.R

*Prediction:* Although we don't have data for each zip code from early 2024 onward, Oliver was able to map out which areas will have repeat visitors, based off the old data and using the same prediction model as above. Slide 8.  
* Code:
  * Oliver:
    * zip_map_final.R

---

## Other areas of interest

### **Roles within the group:**

* Bradley: 
  * Pulling zip code data and putting together *many* graphs to visualize trends (around 118 in all)  
  * Creating this file — thank you to Tim & Oliver for sending me their code  
  * Cleaning the new data
 
* Tim:
  * Focusing heavily on the new data, working with Oliver on his models and heat maps  
  * Cleaning the original data  
  * Making graphs and creating comparisons via R code

* Oliver:
  * Creating the heat maps used in both the first and final presentations  
  * Creating the prediction models using the new data  
  * Putting together the final presentation

> Special thank you to both Professor Manley and Lendie. Your feedback was critical to our progress in the course.

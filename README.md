# **DMARC Project Deliverable: Team 9**

## **Bradley Antholz, Tim Frantz, Oliver Williams**

## **Project Timeline**

> This is a timeline of our project, from the first week to the final presentations. The folders are our own coding files, and each file mentioned

---
### **Cleaning the Code**  
None of us have dealt with this large of a dataset in the past, so we all agreed that cleaning was the first step. We did this separately,  
then combined our efforts into a Google Doc. This took up the first two weeks. Of course, we never stopped cleaning data when we encountered issues, so all of our files have elements of cleaning in it.

The point of cleaning was to make the data more usable to us and universal (for example, using age instead of date of birth), but also more understandable to the audience. Some examples of things we changed include: 

* Added age using dob: age works better for trend analysis
* Added income brackets from annual income: makes it better for graphs
* Remove lnm and housing type variables: lnm was too revealing and housing_type was repeatitive with homelessness and housing_status.
* Grouped pantry locations together: Instead of 90 locations, we grouped it into 17-20.

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
Professor Manley introduced us into the ACS data, and Oliver immediately got to work, creating 4 R files in all. He found the top at-risk zip codes in Des Moines, and I picked the top 12 areas (50137 has no entries in the dataset, so it was removed), sorted into the three categories. This really helped us understand which zip codes we should focus on, and it was *very* clear that 50314 and 50316 need help. 

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
> Note: we edited this presentation for our final presentation, so we do not have the actual presentation anymore. The rankings of each zip code is their place on the most at-risk list (sorted by visior percentage), in atriskzip.png.

Our first presentation really leaned into the at-risk data, and focused on the demographics of 50314 (1st), 50316 (2nd), 50265 (15th) and 50047 (17th). Here are some highlights from it:

* Bradley pointed out that, among the 11 zip codes, 50314 was the only predominately black community, a great candidate for further analysis.
* Tim did the behind the scenes work and made most of the graphs for the presentation. 
* Oliver's heat map was a great shock-factor, as it showed 88% of the population of 50314 had been to a food pantry.

We got good feedback from the audience, and would take it into consideration heading into the future. 

> No code files are found in this section.

---

### **Further Zip Code Analysis & Demographic Targeting**  
Drilled down into specific zip codes to identify distinct visitor demographics and behavior patterns.

---

### **New Data Introduced**  
Incorporated additional DMARC datasets to expand scope and enhance insights.

---

### **Shift in Focus: Zip Codes → Change Over Time**  
Pivoted analysis from location-based to temporal trends in visitor data and pantry services.

---

### **Modeling the Future**  
Began predictive modeling to anticipate future needs and demand.

---

### **How We Can Help DMARC**  
Identified actionable strategies to support DMARC’s mission based on data-driven insights.

---

### **Final Presentation**  
Delivered conclusions and recommendations to DMARC board members and staff.

---

## **Technologies Used**

- R / Python (for data cleaning and analysis)  
- ggplot2, matplotlib, seaborn (for visualizations)  
- GeoJSON, Leaflet, Mapbox (for geographic mapping)  
- GitHub (version control and collaboration)

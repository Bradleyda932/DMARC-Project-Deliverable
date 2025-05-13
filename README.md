# **DMARC Project Deliverable: Team 9**

## **Bradley Antholz, Tim Frantz, Oliver Williams**

## **Project Timeline**

> This is a timeline of our project, from the first week to the final presentations. The folders are our own coding files, and each file mentioned

---
### **Cleaning the Code**  
None of us have dealt with this large of a dataset in the past, so we all agreed that cleaning was the first step. We did this separately,  
then combined our efforts into a Google Doc. This took up the first two weeks. No specific R files are just for this, but some element of cleaning is visible in every file.

The point of cleaning was to make the data more usable to us and universal (for example, using age instead of date of birth), but also more understandable to the audience. Some examples of things we changed include: 

* Added age using dob: age works better for trend analysis
* Added income brackets from annual income: makes it better for graphs
* Remove lnm and housing type variables: lnm was too revealing and housing_type was repeatitive with homelessness and housing_status.
* Grouped pantry locations together: Instead of 90 locations, we grouped it into 17-20.

These additions greatly helped our early analysis of the data, and some made it into our final presentation (income_bracket).

---

### **Looking Deeper into Zip Codes**  
After cleaning, further analysis pointed out that there was a set of zip codes in the Des Moines area, specifically 50314, 50316, 50265 and the Pleasant Hill area. There was a growing need for basic resources in those areas, and yet there is almost no pantries in any of those areas (50314 and 50265 have 0, 50316 has 1, the zip codes in Pleasant Hill have 1 combined. We wanted to focus on people outside of major population hubs (West Des Moines/Urbandale, downtown Des Moines), as these areas tend to be overrepresented in publically available data, as well as in our dataset. Despite this, we did include them in our list of in-need areas, as we wanted three main groups of food pantry visitors for a comparison of demographics. The target areas are:

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


Related code: 
Bradley: zip_code_data.R
> Other zip_code files are mentioned in the next few sections
---

### **ACS Data Introduced (Heat Map Made)**  
Integrated American Community Survey data to layer in socioeconomic context; built initial heat maps.

---

### **First Presentation to Class**  
Summarized findings and methodology for peer and instructor feedback.

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

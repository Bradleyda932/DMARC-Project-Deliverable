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

### **Making Graphs**  
Visualized basic trends to explore patterns and anomalies in the data.

---

### **Looking Deeper into Zip Codes**  
Began geographic analysis to understand neighborhood-level differences in pantry usage.

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

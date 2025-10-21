# Flood Prediction using R

## Overview
This project focuses on predicting the **probability of floods** based on environmental and climatic factors using R.  
By analyzing rainfall, temperature, humidity, monsoon intensity, and water levels, the model identifies patterns indicating flood risk.  
It aims to help in **disaster preparedness and resource management**.

---

## Objectives
- Analyze flood-related data using R.  
- Build predictive models to estimate flood probability.  
- Visualize trends and correlations between weather features.  
- Evaluate model performance using accuracy and ROC metrics.

---

## Project Workflow
1. **Data Import:** Load dataset using `read.csv()`.  
2. **Preprocessing:** Handle missing values, normalize data.  
3. **EDA:** Visualize relationships using `ggplot2`.  
4. **Modeling:** Use Logistic Regression, Decision Tree, and Random Forest.  
5. **Evaluation:** Compare model accuracy and visualize ROC curve.  

---

## Technologies Used
- **Language:** R  
- **Libraries:**  
  - `ggplot2` → Visualization  
  - `caret` → Model training  
  - `dplyr` → Data cleaning  
  - `caTools` → Data splitting  
  - `randomForest` → Classification


---

## Sample Results
| Model | Accuracy | 
|--------|-----------|
| Linear Regression | 100% |
| Random Forest | 91.59% | 
| Logistic Tree | 100% | 



---

## Key Insights
- **Monsoon intensity** and **rainfall** are strong flood indicators.  
- Random Forest achieved the best performance.  
- Feature scaling improved model accuracy.

---

## Future Enhancements
- Integrate **live weather data APIs** for real-time prediction.  
- Deploy using **R Shiny dashboard** for user interaction.  
- Expand model for **multi-region flood forecasting**.

---

## Author
**Deepika S**  
 MCA Student  

---

⭐ *If you found this useful, don’t forget to give this project a star on GitHub!*


---


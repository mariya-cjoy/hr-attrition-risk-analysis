# HR Attrition Risk Analysis 
This project analyzes employee attrition risk using the IBM HR Analytics dataset.

The goal is to simulate how a company could identify employees who may leave soon and take proactive retention actions.

---

## Dataset

IBM HR Analytics Employee Attrition Dataset  
Total Employees: 1470

---


## Project Workflow

1. Data exploration using SQL
2. Attrition analysis by department, salary band, overtime
3. Rule-based Attrition Risk Score Model
4. Risk ranking using SQL window functions

---

## Risk Score Logic

Employees receive risk points based on the following conditions:

+2 → Works Overtime  
+2 → Years at company < 2  
+1 → Job Satisfaction < 2  
+1 → Salary below company average  
+1 → Years with current manager < 1

Risk Category:

Low Risk → Score ≤ 2  
Medium Risk → Score 3–4  
High Risk → Score ≥ 5

---

## Advanced SQL Techniques Used

Common Table Expressions (CTE)

Window Functions:
- RANK()
- NTILE()

Business segmentation analysis

---

## Example Business Insights

Overtime employees show significantly higher attrition risk.

Employees with <2 years tenure have the highest turnover probability.

Low salary relative to peers increases attrition likelihood.

---

## Validation

The risk scoring logic was validated using a Python script to ensure SQL and Python outputs matched for all 1470 employees.

---

## Future Improvements

Build automated data pipeline using Python + FastAPI

Create interactive Power BI dashboard


Build machine learning attrition prediction model

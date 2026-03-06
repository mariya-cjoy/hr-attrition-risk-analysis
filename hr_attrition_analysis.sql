/*
PROJECT: HR Attrition Risk Analysis

This project builds a rule-based employee attrition risk model using PostgreSQL.

Key Features:
- Attrition analysis
- Risk scoring model
- Window function ranking
- Analytics view for dashboard consumption

Dataset: IBM HR Analytics Dataset (1470 employees)
*/


-- =====================================
-- CREATE TABLE
-- =====================================

DROP TABLE IF EXISTS hr_attrition;

CREATE TABLE hr_attrition (
    age INT,
    attrition VARCHAR(10),
    business_travel VARCHAR(50),
    daily_rate INT,
    department VARCHAR(50),
    distance_from_home INT,
    education INT,
    education_field VARCHAR(50),
    employee_count INT,
    employee_number INT,
    environment_satisfaction INT,
    gender VARCHAR(10),
    hourly_rate INT,
    job_involvement INT,
    job_level INT,
    job_role VARCHAR(50),
    job_satisfaction INT,
    marital_status VARCHAR(20),
    monthly_income INT,
    monthly_rate INT,
    num_companies_worked INT,
    over18 VARCHAR(5),
    overtime VARCHAR(5),
    percent_salary_hike INT,
    performance_rating INT,
    relationship_satisfaction INT,
    standard_hours INT,
    stock_option_level INT,
    total_working_years INT,
    training_times_last_year INT,
    work_life_balance INT,
    years_at_company INT,
    years_in_current_role INT,
    years_since_last_promotion INT,
    years_with_curr_manager INT
);


-- =====================================
-- VERIFY DATA
-- =====================================

SELECT *
FROM hr_attrition
LIMIT 5;


-- =====================================
-- CHECK DUPLICATE EMPLOYEES
-- =====================================

SELECT employee_number, COUNT(*)
FROM hr_attrition
GROUP BY employee_number
HAVING COUNT(*) > 1;


-- =====================================
-- TOTAL EMPLOYEES
-- =====================================

SELECT COUNT(*) AS total_employees
FROM hr_attrition;


-- =====================================
-- ATTRITION COUNT
-- =====================================

SELECT COUNT(*) AS attrition_count
FROM hr_attrition
WHERE attrition = 'Yes';


-- =====================================
-- ATTRITION PERCENTAGE
-- =====================================

SELECT 
ROUND(
    100.0 * SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*),
2) AS attrition_percentage
FROM hr_attrition;


-- =====================================
-- ATTRITION BY DEPARTMENT
-- =====================================

SELECT 
department,
COUNT(*) AS total_employees,
SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) AS attrition_count,
ROUND(
    100.0 * SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),
2) AS attrition_percentage
FROM hr_attrition
GROUP BY department
ORDER BY attrition_percentage DESC;


-- =====================================
-- ATTRITION BY OVERTIME
-- =====================================

SELECT 
overtime,
COUNT(*) AS total_employees,
SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) AS attrition_count,
ROUND(
    100.0 * SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),
2) AS attrition_percentage
FROM hr_attrition
GROUP BY overtime
ORDER BY attrition_percentage DESC;


-- =====================================
-- ATTRITION BY EXPERIENCE BUCKET
-- =====================================

SELECT 
CASE
    WHEN years_at_company < 2 THEN '0-2 years'
    WHEN years_at_company BETWEEN 2 AND 5 THEN '2-5 years'
    WHEN years_at_company BETWEEN 6 AND 10 THEN '6-10 years'
    ELSE '10+ years'
END AS experience_bucket,

COUNT(*) AS total_employees,

SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) AS attrition_count,

ROUND(
100.0 * SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),
2) AS attrition_percentage

FROM hr_attrition
GROUP BY experience_bucket
ORDER BY attrition_percentage DESC;


-- =====================================
-- SALARY BAND ANALYSIS
-- =====================================

SELECT 
CASE
    WHEN monthly_income < 3000 THEN 'Low'
    WHEN monthly_income BETWEEN 3000 AND 7000 THEN 'Medium'
    ELSE 'High'
END AS salary_band,

COUNT(*) AS total_employees,

SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END) AS attrition_count,

ROUND(
100.0 * SUM(CASE WHEN attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),
2) AS attrition_percentage

FROM hr_attrition
GROUP BY salary_band
ORDER BY attrition_percentage DESC;


-- =====================================
-- SALARY QUARTILES (DATA-DRIVEN SEGMENTATION)
-- =====================================

SELECT
employee_number,
monthly_income,
NTILE(4) OVER (ORDER BY monthly_income) AS salary_quartile
FROM hr_attrition;


-- =====================================
-- BUILD EMPLOYEE RISK MODEL
-- =====================================

WITH EmployeeRisk AS (

SELECT 
*,

(
CASE WHEN overtime='Yes' THEN 2 ELSE 0 END +
CASE WHEN years_at_company < 2 THEN 2 ELSE 0 END +
CASE WHEN job_satisfaction < 2 THEN 1 ELSE 0 END +
CASE WHEN years_with_curr_manager < 1 THEN 1 ELSE 0 END +
CASE WHEN monthly_income < AVG(monthly_income) OVER() THEN 1 ELSE 0 END
) AS risk_score

FROM hr_attrition
)

SELECT *,
CASE 
    WHEN risk_score <= 2 THEN 'Low Risk'
    WHEN risk_score BETWEEN 3 AND 4 THEN 'Medium Risk'
    ELSE 'High Risk'
END AS risk_category
FROM EmployeeRisk;


-- =====================================
-- RISK SCORE DISTRIBUTION
-- =====================================

WITH EmployeeRisk AS (

SELECT 
*,

(
CASE WHEN overtime='Yes' THEN 2 ELSE 0 END +
CASE WHEN years_at_company < 2 THEN 2 ELSE 0 END +
CASE WHEN job_satisfaction < 2 THEN 1 ELSE 0 END +
CASE WHEN years_with_curr_manager < 1 THEN 1 ELSE 0 END +
CASE WHEN monthly_income < AVG(monthly_income) OVER() THEN 1 ELSE 0 END
) AS risk_score

FROM hr_attrition
)

SELECT
risk_score,
COUNT(*) AS employee_count
FROM EmployeeRisk
GROUP BY risk_score
ORDER BY risk_score DESC;


-- =====================================
-- AVERAGE RISK SCORE BY ATTRITION
-- =====================================

WITH EmployeeRisk AS (

SELECT 
attrition,

(
CASE WHEN overtime='Yes' THEN 2 ELSE 0 END +
CASE WHEN years_at_company < 2 THEN 2 ELSE 0 END +
CASE WHEN job_satisfaction < 2 THEN 1 ELSE 0 END +
CASE WHEN years_with_curr_manager < 1 THEN 1 ELSE 0 END +
CASE WHEN monthly_income < AVG(monthly_income) OVER() THEN 1 ELSE 0 END
) AS risk_score

FROM hr_attrition
)

SELECT
attrition,
ROUND(AVG(risk_score),2) AS avg_risk_score
FROM EmployeeRisk
GROUP BY attrition;


-- =====================================
-- RISK RANKING USING WINDOW FUNCTIONS
-- =====================================

WITH EmployeeRisk AS (

SELECT 
employee_number,
attrition,

(
CASE WHEN overtime='Yes' THEN 2 ELSE 0 END +
CASE WHEN years_at_company < 2 THEN 2 ELSE 0 END +
CASE WHEN job_satisfaction < 2 THEN 1 ELSE 0 END +
CASE WHEN years_with_curr_manager < 1 THEN 1 ELSE 0 END +
CASE WHEN monthly_income < AVG(monthly_income) OVER() THEN 1 ELSE 0 END
) AS risk_score

FROM hr_attrition
)

SELECT
employee_number,
attrition,
risk_score,

RANK() OVER (ORDER BY risk_score DESC) AS risk_rank,

NTILE(5) OVER (ORDER BY risk_score DESC) AS risk_bucket

FROM EmployeeRisk;


-- =====================================
-- HIGH RISK EMPLOYEES (RETENTION TARGET)
-- =====================================

WITH EmployeeRisk AS (

SELECT 
employee_number,
department,
job_role,
attrition,

(
CASE WHEN overtime='Yes' THEN 2 ELSE 0 END +
CASE WHEN years_at_company < 2 THEN 2 ELSE 0 END +
CASE WHEN job_satisfaction < 2 THEN 1 ELSE 0 END +
CASE WHEN years_with_curr_manager < 1 THEN 1 ELSE 0 END +
CASE WHEN monthly_income < AVG(monthly_income) OVER() THEN 1 ELSE 0 END
) AS risk_score

FROM hr_attrition
)

SELECT *
FROM EmployeeRisk
WHERE risk_score >= 4
AND attrition = 'No'
ORDER BY risk_score DESC;


-- =====================================
-- CREATE ANALYTICS VIEW
-- ATTRITION RISK ENGINE (ANALYTICS VIEW)
-- =====================================

CREATE OR REPLACE VIEW attrition_risk_dashboard AS

WITH EmployeeRisk AS (

SELECT 
employee_number,
department,
job_role,
age,
gender,
monthly_income,
years_at_company,
years_with_curr_manager,
job_satisfaction,
overtime,
attrition,

(
CASE WHEN overtime='Yes' THEN 2 ELSE 0 END +
CASE WHEN years_at_company < 2 THEN 2 ELSE 0 END +
CASE WHEN job_satisfaction < 2 THEN 1 ELSE 0 END +
CASE WHEN years_with_curr_manager < 1 THEN 1 ELSE 0 END +
CASE WHEN monthly_income < AVG(monthly_income) OVER() THEN 1 ELSE 0 END
) AS risk_score

FROM hr_attrition
)

SELECT

employee_number,
department,
job_role,
age,
gender,
monthly_income,
years_at_company,
years_with_curr_manager,
job_satisfaction,
overtime,
attrition,
risk_score,

CASE 
WHEN risk_score <= 2 THEN 'Low Risk'
WHEN risk_score BETWEEN 3 AND 4 THEN 'Medium Risk'
ELSE 'High Risk'
END AS risk_category,

RANK() OVER (ORDER BY risk_score DESC) AS risk_rank,

NTILE(5) OVER (ORDER BY risk_score DESC) AS risk_bucket

FROM EmployeeRisk;

-- =====================================
-- SAMPLE OUTPUT
-- =====================================

SELECT *
FROM attrition_risk_dashboard
LIMIT 20;

-- =====================================
-- BUSINESS USE CASE
-- HIGH RISK EMPLOYEES WHO HAVE NOT LEFT
-- =====================================

SELECT *
FROM attrition_risk_dashboard
WHERE risk_category = 'High Risk'
AND attrition = 'No'
ORDER BY risk_score DESC;


# # =========================================
# # IBM HR ATTRITION - PYTHON RISK MODEL
# # =========================================

# import pandas as pd

# # =========================================
# # LOAD DATA
# # =========================================

# file_path = r"C:\Users\mariy\Downloads\IBM HR Analytics Project\WA_Fn-UseC_-HR-Employee-Attrition.csv"

# df = pd.read_csv(file_path)

# # =========================================
# # CLEAN COLUMN NAMES
# # =========================================

# df.columns = df.columns.str.lower()

# # =========================================
# # CALCULATE AVERAGE SALARY
# # =========================================

# avg_salary = df['monthlyincome'].mean()

# # =========================================
# # BUILD RISK SCORE
# # =========================================

# df['risk_score'] = 0

# # Overtime rule
# df.loc[df['overtime'] == 'Yes', 'risk_score'] += 2

# # Low tenure rule
# df.loc[df['yearsatcompany'] < 2, 'risk_score'] += 2

# # Low satisfaction rule
# df.loc[df['jobsatisfaction'] < 2, 'risk_score'] += 1

# # Salary below average rule
# df.loc[df['monthlyincome'] < avg_salary, 'risk_score'] += 1

# # New manager rule
# df.loc[df['yearswithcurrmanager'] < 1, 'risk_score'] += 1


# # =========================================
# # RISK CATEGORY
# # =========================================

# def risk_category(score):
#     if score <= 2:
#         return "Low Risk"
#     elif score <= 4:
#         return "Medium Risk"
#     else:
#         return "High Risk"

# df['risk_category'] = df['risk_score'].apply(risk_category)


# # =========================================
# # RISK RANK
# # =========================================

# df['risk_rank'] = df['risk_score'].rank(method='dense', ascending=False)


# # =========================================
# # RISK BUCKET (QUANTILE)
# # =========================================

# df['risk_bucket'] = pd.qcut(
#     df['risk_score'],
#     q=5,
#     duplicates="drop"
# )

# df['risk_bucket'] = 6 - (df['risk_bucket'].cat.codes + 1)


# # =========================================
# # SHOW SAMPLE RESULTS
# # =========================================

# print("\nTop 10 Risk Employees\n")

# print(
#     df[['employeenumber','attrition','risk_score','risk_category','risk_rank','risk_bucket']]
#     .sort_values('risk_score', ascending=False)
#     .head(10)
# )


# # =========================================
# # RISK DISTRIBUTION
# # =========================================

# print("\nRisk Category Distribution\n")

# print(df['risk_category'].value_counts())


# # =========================================
# # ATTRITION VS RISK SCORE
# # =========================================

# print("\nAverage Risk Score by Attrition\n")

# print(
#     df.groupby('attrition')['risk_score']
#     .mean()
# )


# # =========================================
# # EXPORT RESULT
# # =========================================

# df.to_csv("python_risk_output.csv", index=False)

# print("\nPython Risk Model Output Saved!")





import pandas as pd

# load python output
python_df = pd.read_csv(r"C:\Users\mariy\Downloads\IBM HR Analytics Project\python_risk_output.csv")
python_df.columns = python_df.columns.str.lower()

# load sql output
sql_df = pd.read_csv(r"C:\Users\mariy\Downloads\sql_risk_scores.csv")


# merge on employee number
compare = python_df.merge(
    sql_df,
    left_on="employeenumber",
    right_on="employee_number",
    suffixes=("_python","_sql")
)

# check differences
compare["match"] = compare["risk_score_python"] == compare["risk_score_sql"]

print(compare["match"].value_counts())
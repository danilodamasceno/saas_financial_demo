⚠️ Important:
This is a demo project. It does not include any real company data — all datasets and scripts are illustrative, created only for demonstration and learning purposes.

Finance Analytics – Snowflake

This repository contains the SQL and Python script used inside Snowflake to build financial and SaaS metrics for the FP&A and Finance teams.

📂 Contents

SQL scripts:

Creation of views for Finance & SaaS KPIs (MRR, ARR, Churn, NRR, Delinquency, Collections, Marketing attribution).

Analytical views combining Customers, Subscriptions, Invoices, Charges, Plans, and UTM Sources.

Scripts for aging analysis, churn decomposition, marketing efficiency, and cash vs accrual revenue.

Python scripts (Snowflake Notebooks):

Data quality checks (nulls, duplicates, PK/FK consistency).

Exploratory analysis using pandas, matplotlib, and seaborn.

Simple visualizations: boxplots, distributions, churn curves.

⚠️ Security Note

The following are not included in this repository (for security reasons):

Snowflake warehouse creation scripts

User and role provisioning scripts

These must be created and managed directly by administrators in the Snowflake account.
This repo only includes analytical logic (SQL views, Python checks).

🚀 Usage

Connect to your Snowflake environment.

Run the SQL scripts in the order defined to create analytics views.

Use the Python notebooks inside Snowflake Worksheets (or Snowpark) for validation and exploratory analysis.

Connect your BI tool (e.g., Looker Studio, Tableau, Power BI) to the schema with these views.

📊 Key Outputs

Finance KPIs: MRR, ARR, Cash Collected, Churn, NRR, ARPU.

Collections & Risk: Invoice aging, Delinquency %, Charge success rate.

Marketing Attribution: MRR by UTM Source & Campaign, Trial vs Paid conversion.

Product Metrics: Revenue by plan, Plan migration, Product-level churn.

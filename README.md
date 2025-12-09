# mysql-powerbi-excel-project

## 📊 Overview

This project is an end-to-end data analytics workflow for an e-commerce business. It demonstrates how raw data is transformed into insights using:

MySQL for database design, cleaning, transformation, and analysis

Excel for KPI analysis, pivot tables, and cohort metrics

Power BI for interactive dashboards

SQL for customer segmentation, revenue trends, product performance, and geographic insights

Goal: Understand customer behavior, improve retention, and identify revenue opportunities.

## 🖥️ Dashboard Preview

<p align="center">
  <img src="ecommerce_sales_overview.png" width="900">
</p>

📂 Project Files

/database
    01_schema.sql
    02_sample_data.sql

/sql_queries
    01_data_cleaning.sql
    02_data_transformation.sql
    03_business_analysis.sql

/excel
    Excel_Workbook_Guide.md

/powerbi
    Power_BI_Dashboard_Guide.md

Business_Insights_and_Recommendations.md
PROJECT_SUMMARY.md
SETUP_GUIDE.md

Business insights & recommendations

## 📖 Detailed Documentation

To keep this README clean, full documentation is available in separate files:

Project Summary → PROJECT_SUMMARY.md

Insights & Recommendations → Business_Insights_and_Recommendations.md

SQL Scripts → /sql_queries/

Power BI Guide → Power_BI_Dashboard_Guide.md

Excel Guide → Excel_Workbook_Guide.md

Setup Steps → SETUP_GUIDE.md

<br>
## 🔍 Key Insights (Brief)

High-value customers generate 60%+ of total revenue

Electronics is the strongest-performing product category

Major metro areas (CA, TX) produce the highest revenue

Retention varies significantly by customer cohort

Several products show low sales velocity → optimization opportunities

Full insights here: Business_Insights_and_Recommendations.md

<br>
## 🚦 How to Run the Project
1️⃣ Load Database
mysql -u root -p < database/01_schema.sql
mysql -u root -p < database/02_sample_data.sql

2️⃣ Run SQL Analysis

Execute files in /sql_queries in this order.

3️⃣ Excel Analysis

Follow: excel/Excel_Workbook_Guide.md

4️⃣ Power BI Dashboard

Follow: powerbi/Power_BI_Dashboard_Guide.md

<br>
## 🎓 Skills Demonstrated

Database design & normalization

SQL analytics (CTEs, window functions, aggregations, views)

Data cleaning & validation

Pivot tables, dashboards, KPI modeling

Power BI visualization & DAX

Business intelligence & storytelling

<br>
## 📄 Documentation

Project Summary — PROJECT_SUMMARY.md

Business Insights — Business_Insights_and_Recommendations.md

Setup Guide — SETUP_GUIDE.md

<br>
## 📝 License

MIT License

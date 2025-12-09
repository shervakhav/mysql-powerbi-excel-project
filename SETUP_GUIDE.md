# Quick Setup Guide
## E-commerce Sales Performance & Customer Segmentation

This guide will help you get the project up and running quickly.

---

## Step 1: MySQL Database Setup (5 minutes)

### Option A: Using MySQL Command Line

```bash
# 1. Connect to MySQL
mysql -u root -p

# 2. Create database and tables
source database/01_schema.sql

# 3. Insert sample data
source database/02_sample_data.sql

# 4. Verify setup
USE ecommerce_analytics;
SELECT COUNT(*) FROM customers;  -- Should return 20
SELECT COUNT(*) FROM orders;      -- Should return 57
```

### Option B: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your MySQL server
3. File → Open SQL Script → Select `database/01_schema.sql`
4. Click Execute (⚡) button
5. File → Open SQL Script → Select `database/02_sample_data.sql`
6. Click Execute (⚡) button
7. Verify: Run `SELECT COUNT(*) FROM customers;`

---

## Step 2: Run SQL Analysis Queries (10 minutes)

Execute queries in this order:

1. **Data Cleaning** (`sql_queries/01_data_cleaning.sql`)
   - Verifies data quality
   - Identifies any issues

2. **Data Transformation** (`sql_queries/02_data_transformation.sql`)
   - Creates analytical views
   - Prepares data for analysis

3. **Business Analysis** (`sql_queries/03_business_analysis.sql`)
   - Runs comprehensive analysis
   - Generates insights

**Quick Test:**
```sql
-- Test that views were created
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Test a view
SELECT * FROM v_customer_metrics LIMIT 5;
```

---

## Step 3: Export Data for Excel (5 minutes)

### Export Views to CSV

1. In MySQL Workbench:
   - Run: `SELECT * FROM v_customer_metrics;`
   - Right-click results → Export → CSV
   - Save as `customer_metrics.csv`

2. Repeat for:
   - `v_product_performance`
   - `v_monthly_sales`
   - `v_customer_segmentation`

### Alternative: Using Command Line

```bash
mysql -u root -p ecommerce_analytics -e "SELECT * FROM v_customer_metrics" > customer_metrics.csv
```

---

## Step 4: Create Excel Workbook (15 minutes)

1. Open Excel
2. Import CSV files (Data → Get Data → From File → From Text/CSV)
3. Follow instructions in `excel/Excel_Workbook_Guide.md`
4. Create pivot tables and charts as specified

**Quick Start:**
- Import all 4 CSV files
- Create a pivot table from `customer_metrics`
- Rows: `value_segment`
- Values: Sum of `total_revenue`

---

## Step 5: Build Power BI Dashboard (30 minutes)

1. **Connect to MySQL:**
   - Open Power BI Desktop
   - Get Data → Database → MySQL database
   - Enter server: `localhost` (or your server)
   - Database: `ecommerce_analytics`
   - Import tables: customers, orders, order_items, products, payments
   - Import views: v_customer_metrics, v_product_performance, v_monthly_sales, v_customer_segmentation, v_cohort_base

2. **Set Up Relationships:**
   - Go to Model view
   - Create relationships:
     - customers → orders (One-to-Many)
     - orders → order_items (One-to-Many)
     - products → order_items (One-to-Many)
     - orders → payments (One-to-Many)

3. **Create Measures:**
   - Follow `powerbi/Power_BI_Dashboard_Guide.md`
   - Start with basic measures:
     - Total Revenue
     - Total Orders
     - Average Order Value
     - Total Customers

4. **Build Visuals:**
   - Start with Executive Summary page
   - Add KPI cards
   - Create charts one by one

---

## Troubleshooting

### MySQL Issues

**Error: "Table already exists"**
```sql
DROP DATABASE IF EXISTS ecommerce_analytics;
-- Then re-run schema script
```

**Error: "Access denied"**
- Check MySQL user permissions
- Ensure user has CREATE DATABASE privilege

**Error: "Unknown column"**
- Verify you ran `01_schema.sql` before `02_sample_data.sql`

### Excel Issues

**CSV import errors:**
- Check file encoding (should be UTF-8)
- Verify CSV delimiter (comma)
- Ensure no special characters in headers

**Formula errors:**
- Check cell references
- Verify data types (numbers vs text)
- Ensure pivot table source data is correct

### Power BI Issues

**Connection errors:**
- Verify MySQL server is running
- Check firewall settings
- Ensure MySQL connector is installed

**Relationship errors:**
- Verify data types match between tables
- Check for duplicate keys
- Ensure relationships are One-to-Many

**DAX errors:**
- Check measure syntax
- Verify table and column names
- Use CALCULATE for filtered measures

---

## Verification Checklist

- [ ] MySQL database created successfully
- [ ] All 5 tables populated with data
- [ ] All 6 views created and accessible
- [ ] SQL queries execute without errors
- [ ] Data exported to CSV files
- [ ] Excel workbook created with pivot tables
- [ ] Power BI connected to database
- [ ] Relationships set up correctly
- [ ] DAX measures calculate correctly
- [ ] Dashboard visuals display data

---

## Next Steps

1. Review `Business_Insights_and_Recommendations.md` for key findings
2. Customize dashboards for your needs
3. Add additional analysis queries
4. Expand dataset with more data
5. Share dashboard with stakeholders

---

## Quick Reference

### Key SQL Views
- `v_customer_metrics` - Customer-level metrics
- `v_product_performance` - Product sales data
- `v_monthly_sales` - Time-series aggregations
- `v_customer_segmentation` - Customer segments
- `v_geographic_sales` - Geographic performance
- `v_cohort_base` - Cohort analysis data

### Key Excel Formulas
- `SUMIFS()` - Conditional sum
- `COUNTIFS()` - Conditional count
- `AVERAGEIFS()` - Conditional average
- `VLOOKUP()` - Lookup values

### Key Power BI Measures
- `Total Revenue = SUM(orders[total_amount])`
- `Average Order Value = DIVIDE([Total Revenue], [Total Orders])`
- `Total Customers = DISTINCTCOUNT(customers[customer_id])`

---

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the detailed guides in each folder
3. Verify all prerequisites are installed
4. Check MySQL, Excel, and Power BI documentation

---

**Estimated Total Setup Time:** 60-90 minutes

**Difficulty Level:** Intermediate

**Prerequisites:** Basic SQL, Excel, and Power BI knowledge




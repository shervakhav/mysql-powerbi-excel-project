# Excel Workbook Guide
## E-commerce Sales Performance & Customer Segmentation

### Overview
This guide provides step-by-step instructions for creating an Excel workbook that performs additional calculations, KPIs, and descriptive analytics on the e-commerce data exported from MySQL.

---

## Workbook Structure

### Sheet 1: Data Import
**Purpose:** Import raw data from MySQL queries

**Steps:**
1. Export the following queries from MySQL to CSV:
   - `v_customer_metrics` view
   - `v_product_performance` view
   - `v_monthly_sales` view
   - `v_customer_segmentation` view

2. Import each CSV into separate sheets:
   - Sheet: `Customer_Metrics`
   - Sheet: `Product_Performance`
   - Sheet: `Monthly_Sales`
   - Sheet: `Customer_Segmentation`

---

### Sheet 2: Executive Summary Dashboard
**Purpose:** High-level KPIs and metrics

**Key Metrics to Calculate:**

#### A. Revenue Metrics
```
Total Revenue: =SUM(Monthly_Sales!E:E)
Average Monthly Revenue: =AVERAGE(Monthly_Sales!E:E)
Revenue Growth Rate: =(E2-E3)/E3*100
```
*(Where E2 is current month, E3 is previous month)*

#### B. Customer Metrics
```
Total Customers: =COUNT(Customer_Metrics!A:A)
Active Customers: =COUNTIFS(Customer_Segmentation!I:I,"Active")
Average CLV: =AVERAGE(Customer_Metrics!H:H)
Customer Retention Rate: =COUNTIFS(Customer_Segmentation!H:H,">=2")/COUNT(Customer_Segmentation!A:A)*100
```

#### C. Order Metrics
```
Total Orders: =SUM(Monthly_Sales!D:D)
Average Order Value: =AVERAGE(Customer_Metrics!I:I)
Orders per Customer: =SUM(Monthly_Sales!D:D)/COUNT(Customer_Metrics!A:A)
```

#### D. Product Metrics
```
Total Products: =COUNT(Product_Performance!A:A)
Products Sold: =COUNTIF(Product_Performance!H:H,">0")
Average Margin %: =AVERAGE(Product_Performance!G:G)
```

---

### Sheet 3: Customer Segmentation Analysis
**Purpose:** Detailed customer segment analysis

**Create Pivot Tables:**

#### Pivot Table 1: Revenue by Segment
- **Rows:** Value Segment (High Value, Medium Value, Low Value)
- **Values:** Sum of Total Revenue, Count of Customers, Average Revenue per Customer

#### Pivot Table 2: Engagement Analysis
- **Rows:** Engagement Segment (Active, At Risk, Inactive, Churned)
- **Columns:** Value Segment
- **Values:** Count of Customers, Sum of Total Revenue

#### Pivot Table 3: Geographic Performance
- **Rows:** State
- **Values:** Sum of Total Revenue, Count of Customers, Average Order Value

**Formulas to Add:**

```
Segment Revenue Share: =B2/SUM($B$2:$B$5)*100
Segment Customer Share: =C2/SUM($C$2:$C$5)*100
```

---

### Sheet 4: Product Performance Analysis
**Purpose:** Product-level insights

**Create Pivot Tables:**

#### Pivot Table 1: Category Performance
- **Rows:** Category
- **Values:** 
  - Sum of Total Revenue
  - Sum of Total Profit
  - Average Margin %
  - Count of Products

#### Pivot Table 2: Top Products
- **Rows:** Product Name
- **Values:** Sum of Total Revenue, Sum of Total Quantity Sold
- **Filter:** Top 10 by Revenue

**Additional Calculations:**

```
Revenue Contribution %: =B2/SUM($B$2:$B$21)*100
Profit Margin: =C2/B2*100
Units per Order: =D2/E2
```

---

### Sheet 5: Monthly Trends Analysis
**Purpose:** Time-series analysis

**Create Charts:**

1. **Line Chart: Monthly Revenue Trend**
   - X-axis: Year-Month
   - Y-axis: Total Revenue
   - Add trendline (linear)

2. **Column Chart: Orders vs Customers**
   - X-axis: Year-Month
   - Y-axis: Total Orders (Primary), Unique Customers (Secondary)

3. **Combo Chart: Revenue vs Discounts**
   - X-axis: Year-Month
   - Y-axis: Total Revenue (Column), Total Discounts (Line)

**Formulas:**

```
Month-over-Month Growth: =(B2-B3)/B3*100
Cumulative Revenue: =SUM($B$2:B2)
3-Month Moving Average: =AVERAGE(B2:B4)
```

---

### Sheet 6: Cohort Analysis
**Purpose:** Customer retention by cohort

**Steps:**
1. Export `v_cohort_base` view from MySQL
2. Create a pivot table:
   - **Rows:** Registration Cohort
   - **Columns:** Period Number (0, 1, 2, 3...)
   - **Values:** Count of Customers

3. Calculate Retention Rates:
```
Period 0 Retention: =B2/B2*100 (always 100%)
Period 1 Retention: =C2/B2*100
Period 2 Retention: =D2/B2*100
Period 3 Retention: =E2/B2*100
```

4. Create Heatmap:
   - Use conditional formatting (Color Scale)
   - Green = High retention, Red = Low retention

---

### Sheet 7: Advanced Calculations
**Purpose:** Complex business metrics

**Key Formulas:**

#### Customer Lifetime Value (CLV) Projection
```
Projected Annual CLV: =AVERAGE(Customer_Metrics!H:H)/AVERAGE(Customer_Metrics!K:K)*365
```

#### Churn Rate
```
Churn Rate: =COUNTIFS(Customer_Segmentation!I:I,"Churned")/COUNT(Customer_Segmentation!A:A)*100
```

#### Average Days Between Orders
```
Days Between Orders: =AVERAGE(Customer_Metrics!K:K)/AVERAGE(Customer_Metrics!G:G)
```

#### Product Velocity
```
Sales Velocity: =SUM(Product_Performance!H:H)/COUNT(Product_Performance!A:A)
```

#### Revenue Concentration
```
Top 20% Customer Revenue: =PERCENTILE(Customer_Metrics!H:H,0.8)
Concentration Ratio: =SUMIFS(Customer_Metrics!H:H,Customer_Metrics!H:H,">="&B2)/SUM(Customer_Metrics!H:H)
```

---

### Sheet 8: What-If Analysis
**Purpose:** Scenario planning

**Create Data Tables:**

#### Scenario 1: Discount Impact
- **Input:** Discount percentage (5%, 10%, 15%, 20%)
- **Calculate:** Projected revenue impact
- **Formula:** `=Current_Revenue*(1-Discount_Percent)*(1+Expected_Order_Increase)`

#### Scenario 2: Customer Acquisition
- **Input:** New customers per month
- **Calculate:** Projected revenue growth
- **Formula:** `=New_Customers*Average_CLV*Retention_Rate`

---

## Excel Functions Reference

### Essential Functions Used:
- **SUMIFS:** Conditional sum with multiple criteria
- **COUNTIFS:** Conditional count with multiple criteria
- **AVERAGEIFS:** Conditional average
- **VLOOKUP/XLOOKUP:** Lookup values across sheets
- **PERCENTILE:** Calculate percentiles
- **IF/IFS:** Conditional logic
- **TEXT:** Format dates/numbers
- **YEAR/MONTH:** Extract date components

### Example Formulas:

```
Revenue by Segment: =SUMIFS(Customer_Metrics!H:H, Customer_Segmentation!H:H,"High Value")
Top 10% Customers: =PERCENTILE(Customer_Metrics!H:H,0.9)
Growth Rate: =(Current_Period-Previous_Period)/Previous_Period*100
```

---

## Data Refresh Instructions

1. **Export from MySQL:**
   ```sql
   -- Run queries and export to CSV
   SELECT * FROM v_customer_metrics;
   SELECT * FROM v_product_performance;
   SELECT * FROM v_monthly_sales;
   SELECT * FROM v_customer_segmentation;
   ```

2. **Update Excel:**
   - Go to Data → Get Data → From File → From Text/CSV
   - Select the updated CSV files
   - Refresh all pivot tables (Data → Refresh All)

3. **Verify Calculations:**
   - Check that formulas reference correct ranges
   - Ensure pivot tables include all new data

---

## Best Practices

1. **Data Validation:**
   - Use data validation for dropdown lists
   - Add input restrictions for manual entries

2. **Formatting:**
   - Use consistent number formats (currency, percentage)
   - Apply conditional formatting for visual insights
   - Use named ranges for complex formulas

3. **Documentation:**
   - Add comments to complex formulas
   - Create a "Notes" sheet explaining calculations
   - Document data sources and refresh dates

4. **Error Handling:**
   - Use IFERROR for division by zero
   - Add checks for missing data
   - Validate data ranges before calculations

---

## Sample Excel File Structure

```
📁 E-commerce_Analytics.xlsx
├── 📄 Customer_Metrics (Data)
├── 📄 Product_Performance (Data)
├── 📄 Monthly_Sales (Data)
├── 📄 Customer_Segmentation (Data)
├── 📄 Executive_Summary (Dashboard)
├── 📄 Customer_Analysis (Pivot Tables)
├── 📄 Product_Analysis (Pivot Tables)
├── 📄 Monthly_Trends (Charts)
├── 📄 Cohort_Analysis (Heatmap)
├── 📄 Advanced_Metrics (Calculations)
├── 📄 What_If_Scenarios (Data Tables)
└── 📄 Notes (Documentation)
```

---

## Next Steps

1. Export data from MySQL using the provided SQL queries
2. Import into Excel following the structure above
3. Create pivot tables and charts as specified
4. Build the executive summary dashboard
5. Document any custom calculations or insights




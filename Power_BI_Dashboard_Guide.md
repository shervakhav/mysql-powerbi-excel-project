# Power BI Dashboard Guide
## E-commerce Sales Performance & Customer Segmentation

### Overview
This guide provides comprehensive instructions for building a professional Power BI dashboard that visualizes key business metrics, customer segments, and actionable insights.

---

## Dashboard Structure

### Page 1: Executive Summary Dashboard
**Purpose:** High-level KPIs and overview metrics

**Visuals to Create:**

#### 1. KPI Cards (Top Row)
- **Total Revenue**
- **Total Orders**
- **Average Order Value**
- **Total Customers**
- **Active Customers**
- **Customer Retention Rate**

#### 2. Revenue Trend (Line Chart)
- **X-axis:** Order Date (Month)
- **Y-axis:** Total Revenue
- **Tooltip:** Orders, Customers, Growth %

#### 3. Revenue by Segment (Donut Chart)
- **Legend:** Value Segment
- **Values:** Total Revenue
- **Tooltip:** Customer Count, Avg CLV

#### 4. Geographic Performance (Map Visual)
- **Location:** State
- **Size:** Total Revenue
- **Tooltip:** Orders, Customers, Avg Order Value

#### 5. Top Products (Bar Chart - Horizontal)
- **Y-axis:** Product Name (Top 10)
- **X-axis:** Total Revenue
- **Color:** Category

---

### Page 2: Customer Segmentation Analysis
**Purpose:** Deep dive into customer behavior and segments

**Visuals to Create:**

#### 1. Customer Segment Matrix
- **Rows:** Value Segment
- **Columns:** Engagement Segment
- **Values:** Customer Count, Total Revenue
- **Format:** Heatmap with conditional formatting

#### 2. Customer Lifetime Value Distribution (Histogram)
- **X-axis:** CLV Bins ($0-100, $100-300, etc.)
- **Y-axis:** Customer Count
- **Color:** Value Segment

#### 3. Days Since Last Order (Bar Chart)
- **X-axis:** Engagement Segment
- **Y-axis:** Average Days Since Last Order
- **Color:** Value Segment

#### 4. Orders per Customer (Scatter Plot)
- **X-axis:** Total Orders
- **Y-axis:** Total Revenue
- **Color:** Value Segment
- **Size:** Customer Count

#### 5. Customer Acquisition Trend (Area Chart)
- **X-axis:** Registration Date (Month)
- **Y-axis:** New Customers
- **Color:** Customer Segment

---

### Page 3: Product Performance
**Purpose:** Product and category insights

**Visuals to Create:**

#### 1. Category Performance (Stacked Bar Chart)
- **X-axis:** Category
- **Y-axis:** Total Revenue
- **Legend:** Sales Category (High/Medium/Low)
- **Tooltip:** Profit, Margin %

#### 2. Product Profitability Matrix (Scatter Plot)
- **X-axis:** Total Revenue
- **Y-axis:** Total Profit
- **Size:** Quantity Sold
- **Color:** Category
- **Tooltip:** Product Name, Margin %

#### 3. Top 10 Products (Table)
- **Columns:** Product Name, Category, Revenue, Profit, Margin %, Quantity Sold
- **Sort:** By Revenue (Descending)

#### 4. Product Sales Trend (Line Chart)
- **X-axis:** Order Date (Month)
- **Y-axis:** Quantity Sold
- **Legend:** Top 5 Products
- **Filter:** Product selection

#### 5. Margin Analysis (Waterfall Chart)
- **Categories:** Category
- **Values:** Total Profit
- **Show:** Contribution to overall profit

---

### Page 4: Time Series & Trends
**Purpose:** Temporal analysis and forecasting

**Visuals to Create:**

#### 1. Revenue Trend with Forecast (Line Chart)
- **X-axis:** Order Date (Month)
- **Y-axis:** Total Revenue
- **Add:** Forecast line (12 months ahead)
- **Tooltip:** MoM Growth %

#### 2. Monthly Metrics Comparison (Combo Chart)
- **X-axis:** Year-Month
- **Y-axis (Primary):** Total Revenue (Column)
- **Y-axis (Secondary):** Orders, Customers (Line)

#### 3. Seasonal Pattern (Heatmap)
- **Rows:** Month
- **Columns:** Year
- **Values:** Total Revenue
- **Format:** Color scale

#### 4. Discount Impact (Area Chart)
- **X-axis:** Order Date (Month)
- **Y-axis:** Total Discount Amount
- **Overlay:** Total Revenue (Line)

#### 5. Payment Method Trends (Stacked Area Chart)
- **X-axis:** Payment Date (Month)
- **Y-axis:** Payment Amount
- **Legend:** Payment Method

---

### Page 5: Cohort Analysis
**Purpose:** Customer retention and cohort performance

**Visuals to Create:**

#### 1. Cohort Retention Heatmap
- **Rows:** Registration Cohort
- **Columns:** Period Number (0, 1, 2, 3...)
- **Values:** Retention Rate (%)
- **Format:** Color scale (Green = High, Red = Low)

#### 2. Cohort Revenue (Line Chart)
- **X-axis:** Period Number
- **Y-axis:** Average Revenue per Customer
- **Legend:** Registration Cohort

#### 3. Cohort Size Comparison (Bar Chart)
- **X-axis:** Registration Cohort
- **Y-axis:** Cohort Size (Customer Count)
- **Color:** Average CLV

#### 4. Retention Curve (Line Chart)
- **X-axis:** Period Number
- **Y-axis:** Average Retention Rate
- **Show:** Overall trend across all cohorts

---

## DAX Measures to Create

### Revenue Measures

```dax
Total Revenue = 
SUM(orders[total_amount])

Average Order Value = 
DIVIDE([Total Revenue], [Total Orders], 0)

Revenue Growth % = 
VAR CurrentRevenue = [Total Revenue]
VAR PreviousRevenue = 
    CALCULATE(
        [Total Revenue],
        DATEADD(orders[order_date], -1, MONTH)
    )
RETURN
    DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue, 0)

Revenue YoY Growth = 
VAR CurrentRevenue = [Total Revenue]
VAR PreviousYearRevenue = 
    CALCULATE(
        [Total Revenue],
        DATEADD(orders[order_date], -1, YEAR)
    )
RETURN
    DIVIDE(CurrentRevenue - PreviousYearRevenue, PreviousYearRevenue, 0)
```

### Customer Measures

```dax
Total Customers = 
DISTINCTCOUNT(customers[customer_id])

Active Customers = 
CALCULATE(
    DISTINCTCOUNT(customers[customer_id]),
    customers[days_since_last_order] <= 30
)

Customer Retention Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(customers[customer_id]),
        customers[total_orders] >= 2
    ),
    [Total Customers],
    0
)

Average CLV = 
AVERAGE(customers[total_revenue])

Churn Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(customers[customer_id]),
        customers[engagement_segment] = "Churned"
    ),
    [Total Customers],
    0
)
```

### Order Measures

```dax
Total Orders = 
COUNTROWS(orders)

Orders per Customer = 
DIVIDE([Total Orders], [Total Customers], 0)

Average Days Between Orders = 
AVERAGE(customers[customer_lifetime_days]) / 
AVERAGE(customers[total_orders])
```

### Product Measures

```dax
Total Products Sold = 
DISTINCTCOUNT(order_items[product_id])

Average Margin % = 
AVERAGE(products[margin_percent])

Total Profit = 
SUM(order_items[line_total]) - 
SUMX(
    RELATEDTABLE(order_items),
    order_items[quantity] * RELATED(products[cost])
)

Profit Margin % = 
DIVIDE([Total Profit], [Total Revenue], 0)
```

### Time Intelligence Measures

```dax
Revenue MTD = 
TOTALMTD(
    [Total Revenue],
    orders[order_date]
)

Revenue YTD = 
TOTALYTD(
    [Total Revenue],
    orders[order_date]
)

Revenue Previous Month = 
CALCULATE(
    [Total Revenue],
    DATEADD(orders[order_date], -1, MONTH)
)

Revenue Previous Year = 
CALCULATE(
    [Total Revenue],
    DATEADD(orders[order_date], -1, YEAR)
)

Month-over-Month Growth = 
DIVIDE(
    [Total Revenue] - [Revenue Previous Month],
    [Revenue Previous Month],
    0
)
```

### Segment Measures

```dax
High Value Customer Revenue = 
CALCULATE(
    [Total Revenue],
    customers[value_segment] = "High Value"
)

High Value Customer Count = 
CALCULATE(
    DISTINCTCOUNT(customers[customer_id]),
    customers[value_segment] = "High Value"
)

Segment Revenue Share = 
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        ALL(customers[value_segment])
    ),
    0
)
```

### Cohort Measures

```dax
Cohort Size = 
DISTINCTCOUNT(customers[customer_id])

Period 0 Customers = 
CALCULATE(
    [Cohort Size],
    cohort_base[period_number] = 0
)

Period N Customers = 
CALCULATE(
    [Cohort Size],
    cohort_base[period_number] = SELECTEDVALUE(cohort_base[period_number])
)

Retention Rate = 
DIVIDE(
    [Period N Customers],
    [Period 0 Customers],
    0
)
```

---

## Data Model Relationships

### Required Relationships:

```
customers (1) ──── (Many) orders
orders (1) ──── (Many) order_items
orders (1) ──── (Many) payments
products (1) ──── (Many) order_items
customers ──── (1) v_customer_segmentation (view)
```

### Relationship Settings:
- **Type:** One-to-Many
- **Cross Filter Direction:** Both (where applicable)
- **Make This Relationship Active:** Yes

---

## Filters and Slicers

### Global Filters (All Pages):
- **Date Range:** Order Date (Date Slicer)
- **Customer Segment:** Value Segment (Dropdown)
- **Order Status:** Order Status (Checkbox)

### Page-Specific Filters:

#### Executive Summary:
- **State:** Geographic filter
- **Category:** Product category filter

#### Customer Segmentation:
- **Engagement Segment:** Engagement status
- **Registration Date Range:** Customer acquisition period

#### Product Performance:
- **Category:** Product category
- **Brand:** Product brand
- **Price Range:** Price slider

#### Time Series:
- **Year:** Year selector
- **Quarter:** Quarter selector

---

## Formatting Guidelines

### Color Scheme:
- **Primary:** #2E86AB (Blue)
- **Secondary:** #A23B72 (Purple)
- **Success:** #06A77D (Green)
- **Warning:** #F18F01 (Orange)
- **Danger:** #C73E1D (Red)

### Visual Formatting:
- **Font:** Segoe UI, 10-12pt
- **Titles:** Bold, 14-16pt
- **Background:** Light gray (#F5F5F5)
- **Card Background:** White
- **Borders:** Subtle gray

### Chart Best Practices:
- Remove unnecessary gridlines
- Use consistent color palette
- Add data labels where helpful
- Include tooltips with additional context
- Use appropriate chart types for data

---

## Power BI Setup Steps

### Step 1: Connect to MySQL
1. Open Power BI Desktop
2. Get Data → Database → MySQL database
3. Enter server and database credentials
4. Select tables: customers, orders, order_items, products, payments
5. Import views: v_customer_metrics, v_product_performance, v_monthly_sales, v_customer_segmentation, v_cohort_base

### Step 2: Data Preparation
1. Check data types (dates, numbers, text)
2. Create calculated columns if needed
3. Set up relationships in Model view
4. Hide unnecessary columns

### Step 3: Create Measures
1. Go to Modeling tab
2. Create all DAX measures listed above
3. Organize measures in display folders:
   - Revenue Measures
   - Customer Measures
   - Product Measures
   - Time Intelligence

### Step 4: Build Visuals
1. Start with Executive Summary page
2. Add KPI cards first
3. Build charts one by one
4. Apply filters and slicers
5. Format visuals consistently

### Step 5: Add Interactivity
1. Set up cross-filtering
2. Add drill-through pages
3. Configure tooltips
4. Test user interactions

### Step 6: Publish and Share
1. Publish to Power BI Service
2. Create dashboard from report
3. Set up data refresh schedule
4. Share with stakeholders

---

## Advanced Features

### Drill-Through Pages:
- **Customer Detail Page:** Click customer → See detailed history
- **Product Detail Page:** Click product → See sales performance
- **Order Detail Page:** Click order → See order items

### Tooltips:
- Create tooltip pages with additional context
- Show related metrics on hover
- Include trend indicators

### Bookmarks:
- Save filter states
- Create navigation buttons
- Enable quick scenario switching

### Q&A Visual:
- Add natural language query
- Enable "Ask a question" feature
- Train Q&A with synonyms

---

## Performance Optimization

1. **Use Import Mode:** For better performance
2. **Aggregate Tables:** Pre-calculate summaries
3. **Limit Columns:** Hide unused columns
4. **Optimize DAX:** Use CALCULATE efficiently
5. **Reduce Visuals:** Limit visuals per page
6. **Use DirectQuery Sparingly:** Only for real-time needs

---

## Testing Checklist

- [ ] All measures calculate correctly
- [ ] Relationships are properly set up
- [ ] Filters work as expected
- [ ] Visuals update with filter changes
- [ ] Tooltips display correct information
- [ ] Drill-through pages function
- [ ] Date filters work correctly
- [ ] No blank or error values
- [ ] Performance is acceptable
- [ ] Mobile view is readable

---

## Next Steps

1. Connect Power BI to MySQL database
2. Import all required tables and views
3. Set up data model relationships
4. Create DAX measures
5. Build visuals page by page
6. Apply formatting and styling
7. Test interactivity
8. Publish to Power BI Service
9. Create dashboard
10. Share with stakeholders




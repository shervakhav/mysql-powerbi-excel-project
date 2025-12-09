-- =====================================================
-- E-commerce Sales Performance & Customer Segmentation
-- Data Transformation & Feature Engineering
-- =====================================================

USE ecommerce_analytics;

-- =====================================================
-- 1. Create Customer Metrics View
-- =====================================================

CREATE OR REPLACE VIEW v_customer_metrics AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.registration_date,
    c.city,
    c.state,
    c.customer_segment,
    -- Order metrics
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifetime_days,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
    -- Product metrics
    SUM(oi.quantity) AS total_items_purchased,
    COUNT(DISTINCT oi.product_id) AS unique_products_purchased,
    -- Payment metrics
    COUNT(DISTINCT p.payment_method) AS payment_methods_used
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.registration_date, 
         c.city, c.state, c.customer_segment;

-- =====================================================
-- 2. Create Product Performance View
-- =====================================================

CREATE OR REPLACE VIEW v_product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.price,
    p.cost,
    (p.price - p.cost) AS profit_margin,
    ROUND(((p.price - p.cost) / p.price * 100), 2) AS margin_percent,
    p.brand,
    p.stock_quantity,
    -- Sales metrics
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.line_total) AS total_revenue,
    AVG(oi.unit_price) AS avg_selling_price,
    SUM(oi.quantity * (oi.unit_price - p.cost)) AS total_profit,
    -- Customer metrics
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    AVG(oi.quantity) AS avg_quantity_per_order
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed' OR o.order_status IS NULL
GROUP BY p.product_id, p.product_name, p.category, p.subcategory, p.price, 
         p.cost, p.brand, p.stock_quantity;

-- =====================================================
-- 3. Create Monthly Sales Summary View
-- =====================================================

CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS year_month,
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    MONTHNAME(o.order_date) AS month_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    SUM(oi.quantity) AS total_items_sold,
    SUM(o.discount_amount) AS total_discounts,
    SUM(o.shipping_cost) AS total_shipping_revenue,
    COUNT(DISTINCT oi.product_id) AS unique_products_sold
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), YEAR(o.order_date), 
         MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY year_month;

-- =====================================================
-- 4. Create Customer Segmentation Table
-- =====================================================

CREATE OR REPLACE VIEW v_customer_segmentation AS
SELECT 
    cm.*,
    CASE 
        WHEN cm.total_revenue >= 300 AND cm.total_orders >= 3 
        THEN 'High Value'
        WHEN cm.total_revenue >= 100 AND cm.total_orders >= 2
        THEN 'Medium Value'
        WHEN cm.total_orders >= 1
        THEN 'Low Value'
        ELSE 'No Purchase'
    END AS value_segment,
    CASE 
        WHEN cm.days_since_last_order <= 30 THEN 'Active'
        WHEN cm.days_since_last_order <= 90 THEN 'At Risk'
        WHEN cm.days_since_last_order <= 180 THEN 'Inactive'
        ELSE 'Churned'
    END AS engagement_segment,
    CASE 
        WHEN cm.total_orders >= 5 THEN 'Frequent'
        WHEN cm.total_orders >= 2 THEN 'Regular'
        WHEN cm.total_orders = 1 THEN 'One-time'
        ELSE 'No Purchase'
    END AS frequency_segment
FROM v_customer_metrics cm;

-- =====================================================
-- 5. Create Geographic Sales View
-- =====================================================

CREATE OR REPLACE VIEW v_geographic_sales AS
SELECT 
    o.shipping_state AS state,
    o.shipping_city AS city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    SUM(oi.quantity) AS total_items_sold
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.shipping_state, o.shipping_city
ORDER BY total_revenue DESC;

-- =====================================================
-- 6. Create Cohort Analysis Base Table
-- =====================================================

CREATE OR REPLACE VIEW v_cohort_base AS
SELECT 
    c.customer_id,
    DATE_FORMAT(c.registration_date, '%Y-%m') AS registration_cohort,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    PERIOD_DIFF(
        DATE_FORMAT(o.order_date, '%Y%m'),
        DATE_FORMAT(c.registration_date, '%Y%m')
    ) AS period_number,
    COUNT(DISTINCT o.order_id) AS orders_in_period,
    SUM(o.total_amount) AS revenue_in_period
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, registration_cohort, order_month, period_number;


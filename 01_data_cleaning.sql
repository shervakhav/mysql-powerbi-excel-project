-- =====================================================
-- E-commerce Sales Performance & Customer Segmentation
-- Data Cleaning & Quality Checks
-- =====================================================

USE ecommerce_analytics;

-- =====================================================
-- 1. Check for Missing Values
-- =====================================================

-- Check customers with missing critical fields
SELECT 
    'Customers' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) AS missing_reg_date,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_city
FROM customers;

-- Check orders with missing or invalid data
SELECT 
    'Orders' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN total_amount IS NULL OR total_amount <= 0 THEN 1 ELSE 0 END) AS invalid_amount
FROM orders;

-- Check order items for data quality
SELECT 
    'Order Items' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END) AS invalid_price,
    SUM(CASE WHEN line_total IS NULL OR line_total <= 0 THEN 1 ELSE 0 END) AS invalid_line_total
FROM order_items;

-- =====================================================
-- 2. Identify Duplicate Records
-- =====================================================

-- Check for duplicate customer emails
SELECT 
    email,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Check for duplicate order items (same order + product)
SELECT 
    order_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- =====================================================
-- 3. Data Validation & Consistency Checks
-- =====================================================

-- Verify order totals match sum of order items
SELECT 
    o.order_id,
    o.total_amount AS order_total,
    COALESCE(SUM(oi.line_total), 0) AS calculated_total,
    o.total_amount - COALESCE(SUM(oi.line_total), 0) AS difference
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - COALESCE(SUM(oi.line_total), 0)) > 0.01;

-- Check for orders with no items
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    COUNT(oi.order_item_id) AS item_count
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.total_amount
HAVING COUNT(oi.order_item_id) = 0;

-- Verify discount calculations
SELECT 
    oi.order_item_id,
    oi.quantity,
    oi.unit_price,
    oi.discount_percent,
    oi.line_total,
    (oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) AS calculated_total,
    ABS(oi.line_total - (oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100))) AS difference
FROM order_items oi
HAVING ABS(oi.line_total - (oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100))) > 0.01;

-- =====================================================
-- 4. Identify Outliers
-- =====================================================

-- Identify unusually high order amounts (potential outliers)
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    CASE 
        WHEN total_amount > (SELECT AVG(total_amount) + 3 * STDDEV(total_amount) FROM orders) 
        THEN 'High Outlier'
        WHEN total_amount < (SELECT AVG(total_amount) - 3 * STDDEV(total_amount) FROM orders) 
        THEN 'Low Outlier'
        ELSE 'Normal'
    END AS outlier_status
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) + 3 * STDDEV(total_amount) FROM orders)
   OR total_amount < (SELECT AVG(total_amount) - 3 * STDDEV(total_amount) FROM orders);

-- Check for products with unusual pricing
SELECT 
    product_id,
    product_name,
    price,
    cost,
    (price - cost) AS margin,
    CASE 
        WHEN price > (SELECT AVG(price) + 2 * STDDEV(price) FROM products) 
        THEN 'High Price Outlier'
        WHEN price < (SELECT AVG(price) - 2 * STDDEV(price) FROM products) 
        THEN 'Low Price Outlier'
        ELSE 'Normal'
    END AS price_status
FROM products
WHERE price > (SELECT AVG(price) + 2 * STDDEV(price) FROM products)
   OR price < (SELECT AVG(price) - 2 * STDDEV(price) FROM products);

-- =====================================================
-- 5. Data Completeness Report
-- =====================================================

SELECT 
    'Data Quality Summary' AS report_type,
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_items) AS total_order_items,
    (SELECT COUNT(*) FROM payments) AS total_payments,
    (SELECT COUNT(DISTINCT customer_id) FROM orders) AS customers_with_orders,
    (SELECT COUNT(DISTINCT product_id) FROM order_items) AS products_sold,
    (SELECT MIN(order_date) FROM orders) AS first_order_date,
    (SELECT MAX(order_date) FROM orders) AS last_order_date;




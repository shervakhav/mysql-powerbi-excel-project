-- =====================================================
-- E-commerce Sales Performance & Customer Segmentation
-- Business Analysis Queries
-- =====================================================

USE ecommerce_analytics;

-- =====================================================
-- 1. Overall Business Performance KPIs
-- =====================================================

SELECT 
    'Overall Business KPIs' AS metric_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    SUM(oi.quantity) AS total_items_sold,
    SUM(o.discount_amount) AS total_discounts_given,
    SUM(o.shipping_cost) AS shipping_revenue,
    COUNT(DISTINCT oi.product_id) AS unique_products_sold,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';

-- =====================================================
-- 2. Revenue Trends by Month
-- =====================================================

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS year_month,
    MONTHNAME(o.order_date) AS month_name,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.customer_id) AS customers,
    SUM(o.total_amount) AS revenue,
    AVG(o.total_amount) AS avg_order_value,
    LAG(SUM(o.total_amount)) OVER (ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')) AS previous_month_revenue,
    ROUND(
        ((SUM(o.total_amount) - LAG(SUM(o.total_amount)) OVER (ORDER BY DATE_FORMAT(o.order_date, '%Y-%m'))) 
         / LAG(SUM(o.total_amount)) OVER (ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')) * 100), 
        2
    ) AS month_over_month_growth_pct
FROM orders o
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), MONTHNAME(o.order_date)
ORDER BY year_month;

-- =====================================================
-- 3. Customer Segmentation Analysis
-- =====================================================

SELECT 
    cs.value_segment,
    cs.engagement_segment,
    COUNT(DISTINCT cs.customer_id) AS customer_count,
    SUM(cs.total_revenue) AS total_revenue,
    AVG(cs.total_revenue) AS avg_revenue_per_customer,
    AVG(cs.total_orders) AS avg_orders_per_customer,
    AVG(cs.avg_order_value) AS avg_order_value,
    AVG(cs.days_since_last_order) AS avg_days_since_last_order
FROM v_customer_segmentation cs
GROUP BY cs.value_segment, cs.engagement_segment
ORDER BY total_revenue DESC;

-- =====================================================
-- 4. Top Customers by Revenue
-- =====================================================

SELECT 
    cs.customer_id,
    cs.customer_name,
    cs.customer_segment,
    cs.value_segment,
    cs.engagement_segment,
    cs.total_orders,
    cs.total_revenue,
    cs.avg_order_value,
    cs.days_since_last_order,
    cs.total_items_purchased
FROM v_customer_segmentation cs
ORDER BY cs.total_revenue DESC
LIMIT 20;

-- =====================================================
-- 5. Product Performance Analysis
-- =====================================================

SELECT 
    pp.product_name,
    pp.category,
    pp.brand,
    pp.total_quantity_sold,
    pp.total_revenue,
    pp.total_profit,
    pp.margin_percent,
    pp.unique_customers,
    pp.total_orders,
    ROUND(pp.total_revenue / NULLIF(pp.total_orders, 0), 2) AS revenue_per_order,
    CASE 
        WHEN pp.total_quantity_sold = 0 THEN 'Not Sold'
        WHEN pp.total_quantity_sold < 5 THEN 'Low Sales'
        WHEN pp.total_quantity_sold < 15 THEN 'Medium Sales'
        ELSE 'High Sales'
    END AS sales_category
FROM v_product_performance pp
ORDER BY pp.total_revenue DESC;

-- =====================================================
-- 6. Category Performance
-- =====================================================

SELECT 
    pp.category,
    COUNT(DISTINCT pp.product_id) AS total_products,
    COUNT(DISTINCT pp.product_id) - SUM(CASE WHEN pp.total_quantity_sold = 0 THEN 1 ELSE 0 END) AS products_sold,
    SUM(pp.total_quantity_sold) AS total_units_sold,
    SUM(pp.total_revenue) AS total_revenue,
    SUM(pp.total_profit) AS total_profit,
    AVG(pp.margin_percent) AS avg_margin_percent,
    COUNT(DISTINCT pp.unique_customers) AS unique_customers
FROM v_product_performance pp
GROUP BY pp.category
ORDER BY total_revenue DESC;

-- =====================================================
-- 7. Geographic Performance
-- =====================================================

SELECT 
    gs.state,
    COUNT(DISTINCT gs.city) AS cities_count,
    gs.total_orders,
    gs.unique_customers,
    gs.total_revenue,
    gs.avg_order_value,
    ROUND(gs.total_revenue / NULLIF(gs.unique_customers, 0), 2) AS revenue_per_customer
FROM v_geographic_sales gs
GROUP BY gs.state, gs.total_orders, gs.unique_customers, gs.total_revenue, gs.avg_order_value
ORDER BY gs.total_revenue DESC;

-- =====================================================
-- 8. Customer Lifetime Value (CLV) Analysis
-- =====================================================

SELECT 
    cs.value_segment,
    COUNT(DISTINCT cs.customer_id) AS customer_count,
    AVG(cs.total_revenue) AS avg_clv,
    AVG(cs.customer_lifetime_days) AS avg_lifetime_days,
    AVG(cs.total_orders) AS avg_orders,
    AVG(cs.avg_order_value) AS avg_order_value,
    ROUND(AVG(cs.total_revenue) / NULLIF(AVG(cs.customer_lifetime_days), 0) * 365, 2) AS projected_annual_value
FROM v_customer_segmentation cs
WHERE cs.total_orders > 0
GROUP BY cs.value_segment
ORDER BY avg_clv DESC;

-- =====================================================
-- 9. Payment Method Analysis
-- =====================================================

SELECT 
    p.payment_method,
    COUNT(DISTINCT p.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(p.payment_amount) AS total_payment_amount,
    AVG(p.payment_amount) AS avg_payment_amount,
    ROUND(COUNT(DISTINCT p.order_id) * 100.0 / (SELECT COUNT(*) FROM payments), 2) AS usage_percentage
FROM payments p
INNER JOIN orders o ON p.order_id = o.order_id
WHERE p.payment_status = 'Completed'
GROUP BY p.payment_method
ORDER BY total_payment_amount DESC;

-- =====================================================
-- 10. Cohort Retention Analysis
-- =====================================================

SELECT 
    cb.registration_cohort,
    COUNT(DISTINCT CASE WHEN cb.period_number = 0 THEN cb.customer_id END) AS cohort_size,
    COUNT(DISTINCT CASE WHEN cb.period_number = 0 THEN cb.customer_id END) AS period_0_customers,
    COUNT(DISTINCT CASE WHEN cb.period_number = 1 THEN cb.customer_id END) AS period_1_customers,
    COUNT(DISTINCT CASE WHEN cb.period_number = 2 THEN cb.customer_id END) AS period_2_customers,
    COUNT(DISTINCT CASE WHEN cb.period_number = 3 THEN cb.customer_id END) AS period_3_customers,
    ROUND(COUNT(DISTINCT CASE WHEN cb.period_number = 1 THEN cb.customer_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT CASE WHEN cb.period_number = 0 THEN cb.customer_id END), 0), 2) AS retention_period_1,
    ROUND(COUNT(DISTINCT CASE WHEN cb.period_number = 2 THEN cb.customer_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT CASE WHEN cb.period_number = 0 THEN cb.customer_id END), 0), 2) AS retention_period_2
FROM v_cohort_base cb
GROUP BY cb.registration_cohort
ORDER BY cb.registration_cohort;

-- =====================================================
-- 11. Product Cross-Sell Analysis
-- =====================================================

SELECT 
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(DISTINCT o1.order_id) AS times_bought_together
FROM order_items oi1
INNER JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
INNER JOIN products p1 ON oi1.product_id = p1.product_id
INNER JOIN products p2 ON oi2.product_id = p2.product_id
INNER JOIN orders o ON oi1.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p1.product_name, p2.product_name
HAVING times_bought_together >= 2
ORDER BY times_bought_together DESC
LIMIT 20;

-- =====================================================
-- 12. Discount Impact Analysis
-- =====================================================

SELECT 
    CASE 
        WHEN o.discount_amount = 0 THEN 'No Discount'
        WHEN o.discount_amount < 10 THEN 'Low Discount (<$10)'
        WHEN o.discount_amount < 25 THEN 'Medium Discount ($10-$25)'
        ELSE 'High Discount (>$25)'
    END AS discount_category,
    COUNT(DISTINCT o.order_id) AS order_count,
    AVG(o.total_amount) AS avg_order_value,
    SUM(o.total_amount) AS total_revenue,
    AVG(oi.quantity) AS avg_items_per_order,
    SUM(o.discount_amount) AS total_discounts
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY discount_category
ORDER BY avg_order_value DESC;




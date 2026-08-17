USE Olist_Ecommerce;
GO

-----------------------------
-- Olist E-Commerce Analytics
-- Business Insights
-----------------------------

-- 1. Top product categories by revenue
SELECT TOP 10
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM dbo.order_items oi
JOIN dbo.products p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC;

-- 2. Customer retention
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM dbo.customers c
    JOIN dbo.orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;

-- 3. Delivery time vs customer satisfaction
SELECT
    r.review_score,
    COUNT(*) AS reviewed_orders,
    ROUND(
        AVG(
            CAST(
                DATEDIFF(
                    DAY,
                    o.order_purchase_timestamp,
                    o.order_delivered_customer_date
                ) AS DECIMAL(10,2)
            )
        ),
        2
    ) AS avg_delivery_days
FROM dbo.orders o
JOIN dbo.order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

-- 4. Revenue concentration by customer state
SELECT TOP 10
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM dbo.orders o
JOIN dbo.customers c
    ON o.customer_id = c.customer_id
JOIN dbo.order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- 5. Payment method analysis
SELECT
    payment_type,
    COUNT(*) AS transactions,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;
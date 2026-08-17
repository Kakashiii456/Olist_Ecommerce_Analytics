USE Olist_Ecommerce;
GO

-----------------------------
-- Olist E-Commerce Analytics
-- Exploratory Analysis
-----------------------------

-- 1. Overall business performance
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(oi.price) AS total_revenue,
    COUNT(*) AS total_items_sold
FROM dbo.orders o
JOIN dbo.order_items oi
    ON o.order_id = oi.order_id;

-- 2. Average order value
SELECT
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM dbo.order_items oi;

-- 3. Monthly revenue trend
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS revenue
FROM dbo.orders o
JOIN dbo.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;

-- 4. Revenue by product category
SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
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

-- 5. Revenue and usage by payment type
SELECT
    payment_type,
    COUNT(*) AS payment_transactions,
    SUM(payment_value) AS total_payment_value,
    AVG(payment_value) AS average_payment_value
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- 6. Orders and revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS revenue
FROM dbo.orders o
JOIN dbo.customers c
    ON o.customer_id = c.customer_id
JOIN dbo.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_state
ORDER BY
    revenue DESC;

-- 7. Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM dbo.orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 8. Delivery performance
SELECT
    COUNT(*) AS delivered_orders,
    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS avg_delivery_days,
    AVG(
        DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        )
    ) AS avg_difference_from_estimated_days
FROM dbo.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- 9. Delivery time vs. review score
SELECT
    r.review_score,
    COUNT(*) AS reviewed_orders,
    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        )
    ) AS avg_delivery_days
FROM dbo.orders o
JOIN dbo.order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

-- 10. Seller performance
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(CAST(r.review_score AS DECIMAL(3,2))), 2) AS avg_review_score
FROM dbo.order_items oi
JOIN dbo.order_reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY revenue DESC;

-- 11. Top products by revenue
SELECT TOP 20
    oi.product_id,
    COALESCE(p.product_category_name, 'Unknown') AS product_category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM dbo.order_items oi
JOIN dbo.products p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    p.product_category_name
ORDER BY revenue DESC;

-- 12. Customer purchase frequency
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
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END;

-- 13. Revenue by customer type
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1
                THEN 'One-time customer'
            ELSE 'Repeat customer'
        END AS customer_type
    FROM dbo.customers c
    JOIN dbo.orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    co.customer_type,
    COUNT(DISTINCT co.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customer_orders co
JOIN dbo.customers c
    ON co.customer_unique_id = c.customer_unique_id
JOIN dbo.orders o
    ON c.customer_id = o.customer_id
JOIN dbo.order_items oi
    ON o.order_id = oi.order_id
GROUP BY co.customer_type
ORDER BY revenue DESC;

-- 14. Average revenue per customer type
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1
                THEN 'One-time customer'
            ELSE 'Repeat customer'
        END AS customer_type
    FROM dbo.customers c
    JOIN dbo.orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
customer_revenue AS (
    SELECT
        co.customer_unique_id,
        co.customer_type,
        SUM(oi.price) AS revenue
    FROM customer_orders co
    JOIN dbo.customers c
        ON co.customer_unique_id = c.customer_unique_id
    JOIN dbo.orders o
        ON c.customer_id = o.customer_id
    JOIN dbo.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        co.customer_unique_id,
        co.customer_type
)
SELECT
    customer_type,
    COUNT(*) AS customers,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_customer
FROM customer_revenue
GROUP BY customer_type;
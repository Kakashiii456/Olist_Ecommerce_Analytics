USE Olist_Ecommerce;
GO

-----------------------------
-- Olist E-Commerce Analytics
-- Advanced SQL Analysis
-----------------------------

-- 1. Top sellers by customer state
WITH seller_state_revenue AS (
    SELECT
        c.customer_state,
        oi.seller_id,
        SUM(oi.price) AS revenue
    FROM dbo.order_items oi
    JOIN dbo.orders o
        ON oi.order_id = o.order_id
    JOIN dbo.customers c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.customer_state,
        oi.seller_id
),
ranked_sellers AS (
    SELECT
        customer_state,
        seller_id,
        revenue,
        RANK() OVER (
            PARTITION BY customer_state
            ORDER BY revenue DESC
        ) AS seller_rank
    FROM seller_state_revenue
)
SELECT
    customer_state,
    seller_id,
    ROUND(revenue, 2) AS revenue,
    seller_rank
FROM ranked_sellers
WHERE seller_rank <= 3
ORDER BY
    customer_state,
    seller_rank;

-- 2. Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS order_year,
        MONTH(o.order_purchase_timestamp) AS order_month,
        SUM(oi.price) AS revenue
    FROM dbo.orders o
    JOIN dbo.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),
revenue_with_previous AS (
    SELECT
        order_year,
        order_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_year, order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_year,
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100.0 / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage
FROM revenue_with_previous
ORDER BY order_year, order_month;

-- 3. Top 3 products by revenue within each category
WITH product_revenue AS (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS product_category,
        oi.product_id,
        SUM(oi.price) AS revenue
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
        ),
        oi.product_id
),
ranked_products AS (
    SELECT
        product_category,
        product_id,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY product_category
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_revenue
)
SELECT
    product_category,
    product_id,
    ROUND(revenue, 2) AS revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    product_category,
    product_rank;

-- 4. Average time between repeat purchases
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_purchase
    FROM dbo.customers c
    JOIN dbo.orders o
        ON c.customer_id = o.customer_id
),
purchase_gaps AS (
    SELECT
        customer_unique_id,
        DATEDIFF(
            DAY,
            previous_purchase,
            order_purchase_timestamp
        ) AS days_between_purchases
    FROM customer_orders
    WHERE previous_purchase IS NOT NULL
)
SELECT
    COUNT(*) AS repeat_purchase_events,
    ROUND(AVG(CAST(days_between_purchases AS DECIMAL(10,2))), 2)
        AS avg_days_between_purchases,
    MIN(days_between_purchases) AS minimum_days,
    MAX(days_between_purchases) AS maximum_days
FROM purchase_gaps;

-- 5. Top customers by lifetime revenue
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS lifetime_revenue
    FROM dbo.customers c
    JOIN dbo.orders o
        ON c.customer_id = o.customer_id
    JOIN dbo.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
ranked_customers AS (
    SELECT
        customer_unique_id,
        lifetime_revenue,
        RANK() OVER (
            ORDER BY lifetime_revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)
SELECT TOP 20
    customer_unique_id,
    ROUND(lifetime_revenue, 2) AS lifetime_revenue,
    revenue_rank
FROM ranked_customers
ORDER BY revenue_rank;
USE Olist_Ecommerce;
GO

------------------------------
-- Olist E-commerce Analytics
-- Data Validation
------------------------------

-- 1. Checking for duplicate order IDs
SELECT
	order_id,
	COUNT(*) AS occurence_count
FROM dbo.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. Checking for orphan customer IDS

SELECT COUNT(*) AS orphan_customer_ids
FROM dbo.orders o
LEFT JOIN dbo.customers c
	on o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 3. Checking for orphan order IDS in order_items
SELECT COUNT(*) AS orphan_order_ids
FROM dbo.order_items oi
LEFT JOIN dbo.orders o
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 4. Checking for orphan product IDS in 
SELECT COUNT(*) AS orphan_product_ids
FROM dbo.order_items oi
LEFT JOIN dbo.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 5. Check for orphan seller IDs in order_items
SELECT COUNT(*) AS orphan_seller_ids
FROM dbo.order_items oi
LEFT JOIN dbo.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 6. Check for orphan order IDs in order_payments
SELECT COUNT(*) AS orphan_order_ids
FROM dbo.order_payments op
LEFT JOIN dbo.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 7. Check for orphan order IDs in order_reviews
SELECT COUNT(*) AS orphan_order_ids
FROM dbo.order_reviews r
LEFT JOIN dbo.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 8. Check for invalid monetary values
SELECT
    COUNT(*) AS invalid_values
FROM dbo.order_items
WHERE price < 0
   OR freight_value < 0;

SELECT
    COUNT(*) AS invalid_values
FROM dbo.order_payments
WHERE payment_value < 0;

-- 9. Check for inconsistent order dates
SELECT COUNT(*) AS invalid_order_dates
FROM dbo.orders
WHERE order_approved_at < order_purchase_timestamp
   OR order_delivered_carrier_date < order_approved_at
   OR order_delivered_customer_date < order_delivered_carrier_date;

-- 10. Identify the type of order date inconsistency
SELECT
    SUM(CASE
        WHEN order_approved_at < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS approved_before_purchase,

    SUM(CASE
        WHEN order_delivered_carrier_date < order_approved_at
        THEN 1 ELSE 0
    END) AS carrier_before_approved,

    SUM(CASE
        WHEN order_delivered_customer_date < order_delivered_carrier_date
        THEN 1 ELSE 0
    END) AS customer_delivery_before_carrier
FROM dbo.orders;

-- Date validation found 1,392 chronological inconsistencies:
-- 1,359 carrier dates before approval dates
-- 23 customer delivery dates before carrier dates
-- Original data retained without modification
# Data Dictionary

The project uses nine tables from the Olist Brazilian E-Commerce dataset.

## 1. customers

Contains customer-level information.

| Column | Description |
|---|---|
| customer_id | Unique identifier for an order-specific customer record |
| customer_unique_id | Unique identifier for the actual customer |
| customer_zip_code_prefix | Customer ZIP-code prefix |
| customer_city | Customer city |
| customer_state | Customer state |

## 2. orders

Contains order-level information and timestamps.

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer associated with the order |
| order_status | Current status of the order |
| order_purchase_timestamp | Timestamp when the order was placed |
| order_approved_at | Timestamp when payment was approved |
| order_delivered_carrier_date | Date the order was handed to the carrier |
| order_delivered_customer_date | Date the customer received the order |
| order_estimated_delivery_date | Estimated delivery date |

## 3. order_items

Contains individual products purchased within orders.

| Column | Description |
|---|---|
| order_id | Order identifier |
| order_item_id | Sequential item number within an order |
| product_id | Product identifier |
| seller_id | Seller identifier |
| shipping_limit_date | Seller shipping deadline |
| price | Product price |
| freight_value | Freight/shipping cost |

## 4. order_payments

Contains payment transactions for orders.

| Column | Description |
|---|---|
| order_id | Order identifier |
| payment_sequential | Sequence of payment within an order |
| payment_type | Payment method |
| payment_installments | Number of installments |
| payment_value | Payment amount |

## 5. order_reviews

Contains customer reviews.

| Column | Description |
|---|---|
| review_id | Review identifier |
| order_id | Associated order |
| review_score | Rating from 1 to 5 |
| review_comment_title | Review title |
| review_comment_message | Review text |
| review_creation_date | Review creation timestamp |
| review_answer_timestamp | Review response timestamp |

## 6. products

Contains product attributes.

| Column | Description |
|---|---|
| product_id | Product identifier |
| product_category_name | Product category |
| product_name_length | Length of product name |
| product_description_length | Length of product description |
| product_photos_qty | Number of product photos |
| product_weight_g | Product weight |
| product_length_cm | Product length |
| product_height_cm | Product height |
| product_width_cm | Product width |

## 7. sellers

Contains seller information.

| Column | Description |
|---|---|
| seller_id | Seller identifier |
| seller_zip_code_prefix | Seller ZIP-code prefix |
| seller_city | Seller city |
| seller_state | Seller state |

## 8. geolocation

Contains geographic information associated with ZIP-code prefixes.

| Column | Description |
|---|---|
| geolocation_zip_code_prefix | ZIP-code prefix |
| geolocation_lat | Latitude |
| geolocation_lng | Longitude |
| geolocation_city | City |
| geolocation_state | State |

## 9. product_category_translation

Maps Portuguese product-category names to English names.

| Column | Description |
|---|---|
| product_category_name | Original Portuguese category name |
| product_category_name_english | English category name |

## Key Relationships

The primary analytical relationships are:

- customers → orders
- orders → order_items
- orders → order_payments
- orders → order_reviews
- products → order_items
- sellers → order_items
- product_category_translation → products

These relationships form the basis of the SQL analysis and Power BI data model.
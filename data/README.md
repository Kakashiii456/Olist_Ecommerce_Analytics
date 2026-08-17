# Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist.

The raw CSV files are not included in this repository because the dataset is large and contains files that are unnecessary to commit directly to GitHub.

## Dataset contents

The project uses the following tables:

- customers
- geolocation
- order_items
- order_payments
- order_reviews
- orders
- products
- sellers
- product_category_translation

## Reproducing the project

1. Obtain the Olist Brazilian E-Commerce Public Dataset.
2. Place the CSV files inside:

   `data/raw/`

3. Import the data into SQL Server using the scripts in:

   `sql/`

4. Open the Power BI file in:

   `powerbi/Olist_Ecommerce_Analytics.pbix`

The SQL scripts document the database setup, data validation, exploratory analysis, advanced analysis, and business insights.
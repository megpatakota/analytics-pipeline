-- data_models/models/marts/fact_sales.sql

-- Materialize as a table for the best query performance in Power BI


WITH items AS (
    SELECT * FROM "primary_app_db"."public_staging"."stg_order_items" 
),

orders AS (
    SELECT * FROM "primary_app_db"."public_staging"."stg_orders"
),

products AS (
    -- Reference the clean dimension table to pull in descriptive data
    SELECT 
        product_pk, 
        product_sku,
        product_category_name -- Pulling the clean, categorized name from dim_products
    FROM 
        "primary_app_db"."public_analytics"."dim_products"
)

SELECT
    -- 1. Foreign Keys (To link to the Dimension Tables)
    o.order_pk AS order_key,
    o.customer_id AS customer_key, -- Assumes a dim_customers table for lookup
    i.product_pk AS product_key,

    -- 2. Date/Time Dimensions (For temporal slicing and dicing)
    o.order_timestamp AS sales_timestamp,
    CAST(o.order_timestamp AS DATE) AS sales_date, -- For easy date filtering

    -- 3. Measures (The core business metrics to be aggregated)
    i.quantity AS units_sold,
    i.unit_price_at_sale,
    (i.quantity * i.unit_price_at_sale) AS gross_revenue_amount,
    
    -- 4. Descriptive Attributes (Denormalized into the fact for reporting convenience)
    p.product_sku,
    p.product_category_name,

    -- 5. Status and Lineage
    o.order_status,
    o.source_system AS source_system
    
FROM
    items i
INNER JOIN
    orders o 
    ON i.order_pk = o.order_pk
LEFT JOIN
    products p
    ON i.product_pk = p.product_pk

WHERE
    -- CRITICAL BUSINESS LOGIC: Ensure data integrity by only including transactions that are completed
    o.order_status = 'Delivered' 
    -- Filter out any future-dated orders or garbage data
    AND o.order_timestamp <= NOW()
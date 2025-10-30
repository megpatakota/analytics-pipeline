-- data_models/models/marts/dim_products.sql

-- Materialize as a table for fast read performance in Power BI
{{ config(
    materialized='table',
    schema='analytics',
    tags=['core_dimension', 'daily_run']
) }}

SELECT
    -- Final Unique Identifier for Power BI (Dimension Key)
    product_pk, 
    
    -- Core Product Attributes
    product_sku,
    product_name,
    
    -- Descriptive Attributes
    CASE
        WHEN category_id = 1 THEN 'Electronics'
        WHEN category_id = 2 THEN 'Apparel'
        ELSE 'Other' 
    END AS product_category_name, -- Logic to translate raw FK to a user-friendly name
    
    -- Price and Status
    unit_price AS current_unit_price,
    current_stock,
    is_active,
    
    -- Metadata/History
    created_timestamp
    
FROM
    {{ ref('stg_products') }}

-- Optional: Add a unique constraint check to ensure dimension integrity
-- You would typically add this to a 'schema.yml' file for testing
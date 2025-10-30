-- data_models/models/staging/stg_products.sql

-- Set the materialization as view for quick development/light queries


SELECT
    -- 1. Primary Key/Identifier Renaming
    id AS product_pk, -- 'pk' for primary key in the source system (raw table)
    
    -- 2. Cleaning and Standardizing Identifiers
    UPPER(product_sku) AS product_sku, -- Ensure SKUs are consistently uppercase
    
    -- 3. Core Attributes (Simple pass-through)
    product_name,
    category_id,
    
    -- 4. Type Casting/Formatting
    CAST(unit_price AS NUMERIC(10, 2)) AS unit_price,
    current_stock,
    is_active,
    
    -- 5. Timestamp Standardization
    created_timestamp,
    
    -- 6. Source Metadata (Useful for data lineage/debugging)
    'postgres_raw' AS source_system
    
FROM
    -- Reference the RAW table in the PostgreSQL database
    "primary_app_db"."public"."raw_products"
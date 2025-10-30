-- data_models/models/staging/stg_order_items.sql



SELECT
    -- 1. Identifier Renaming
    id AS order_item_pk,
    order_id AS order_pk,
    product_id AS product_pk,

    -- 2. Type Casting and Validation
    quantity,
    CAST(unit_price_at_sale AS NUMERIC(10, 2)) AS unit_price_at_sale,
    
    -- 3. Source Metadata
    'postgres_raw' AS source_system
    
FROM
    "primary_app_db"."public"."raw_order_items"
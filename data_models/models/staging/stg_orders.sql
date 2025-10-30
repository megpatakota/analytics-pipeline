-- data_models/models/staging/stg_orders.sql

{{ config(materialized='view') }}

SELECT
    -- 1. Identifier Renaming
    id AS order_pk,
    customer_id,
    
    -- 2. Cleaning and Standardization
    TRIM(order_status) AS order_status, -- Remove accidental whitespace
    
    -- 3. Timestamp Standardization
    order_timestamp,
    
    -- 4. Type Casting
    CAST(total_paid AS NUMERIC(10, 2)) AS total_paid_amount,
    
    -- 5. Source Metadata
    'postgres_raw' AS source_system
    
FROM
    {{ source('public', 'raw_orders') }}
-- migrations/V1__create_raw_tables.sql

-- Set transaction safety for schema changes
BEGIN;

-- 1. Product Table
CREATE TABLE IF NOT EXISTS public.raw_products (
    id SERIAL PRIMARY KEY,
    product_sku VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category_id INTEGER,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    current_stock INTEGER NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Create indexes on frequently joined/searched columns
CREATE UNIQUE INDEX idx_raw_products_sku ON public.raw_products (product_sku);
CREATE INDEX idx_raw_products_category ON public.raw_products (category_id);


-- 2. Sales Order Header Table
CREATE TABLE IF NOT EXISTS public.raw_orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_paid NUMERIC(10, 2) NOT NULL
);
CREATE INDEX idx_raw_orders_customer_id ON public.raw_orders (customer_id);
CREATE INDEX idx_raw_orders_timestamp ON public.raw_orders (order_timestamp);


-- 3. Sales Order Item Table
CREATE TABLE IF NOT EXISTS public.raw_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES public.raw_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES public.raw_products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_at_sale NUMERIC(10, 2) NOT NULL,
    
    UNIQUE (order_id, product_id)
);
CREATE INDEX idx_raw_order_items_order_id ON public.raw_order_items (order_id);
CREATE INDEX idx_raw_order_items_product_id ON public.raw_order_items (product_id);

COMMIT;
# Data Flow Documentation

This document explains how data moves through the pipeline from raw ingestion to analytics-ready tables.

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA INGESTION                            │
│  Application writes to raw tables (public schema)            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    RAW LAYER (public)                        │
│  • Preserves original data structure                         │
│  • Foreign keys ensure referential integrity                 │
│  • Indexes optimize joins                                    │
│                                                               │
│  Tables:                                                     │
│  - raw_products (product master)                             │
│  - raw_orders (order headers)                                │
│  - raw_order_items (order lines)                             │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│               STAGING LAYER (staging)                        │
│  • Data cleaning and standardization                         │
│  • Type validation and casting                               │
│  • Column renaming for consistency                           │
│  • Source tracking                                           │
│                                                               │
│  Views (lightweight, on-the-fly):                           │
│  - stg_products                                              │
│  - stg_orders                                                │
│  - stg_order_items                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│             ANALYTICS LAYER (analytics)                      │
│  • Business logic applied                                    │
│  • Dimensional modeling (star schema)                        │
│  • Denormalized for reporting                                │
│  • Ready for BI tools                                        │
│                                                               │
│  Tables (materialized for performance):                      │
│  - dim_products (product dimension)                          │
│  - fact_sales (sales transactions)                           │
└─────────────────────────────────────────────────────────────┘
```

## Layer 1: Raw Layer (public schema)

### Purpose
Primary landing zone for source data with minimal transformation.

### Created By
**Flyway migrations**: `migrations/V1__create_raw_tables.sql`

### Tables

#### raw_products
**Purpose**: Product catalog master data

**Columns**:
- `id` - Primary key
- `product_sku` - Unique product identifier
- `product_name` - Product name
- `category_id` - Category foreign key (1=Electronics, 2=Apparel)
- `unit_price` - Current unit price
- `current_stock` - Stock quantity
- `is_active` - Active status
- `created_timestamp` - Creation timestamp

**Indexes**:
- Unique index on `product_sku`
- Index on `category_id`

#### raw_orders
**Purpose**: Sales order headers

**Columns**:
- `id` - Primary key
- `customer_id` - Customer identifier
- `order_status` - Status (Pending, Processing, Delivered, etc.)
- `order_timestamp` - Order creation timestamp
- `total_paid` - Total amount paid

**Indexes**:
- Index on `customer_id`
- Index on `order_timestamp`

#### raw_order_items
**Purpose**: Sales order line items

**Columns**:
- `id` - Primary key
- `order_id` - Foreign key to raw_orders
- `product_id` - Foreign key to raw_products
- `quantity` - Quantity ordered
- `unit_price_at_sale` - Price at time of sale

**Indexes**:
- Index on `order_id`
- Index on `product_id`
- Unique constraint on (order_id, product_id)

### Characteristics
- ✅ Preserves original data structure
- ✅ Foreign keys enforce referential integrity
- ✅ Indexes optimize query performance
- ✅ Ready for application writes

## Layer 2: Staging Layer (staging schema)

### Purpose
Data quality and standardization before analytics.

### Created By
**DBT models**: `data_models/models/staging/*.sql`

### Views

#### stg_products
**Transformations**:
- Rename `id` → `product_pk`
- Uppercase `product_sku` for consistency
- Cast `unit_price` to NUMERIC(10,2)
- Add `source_system` metadata column

**Purpose**: Ensure clean, consistent product data

#### stg_orders
**Transformations**:
- Rename `id` → `order_pk`
- Trim whitespace from `order_status`
- Cast `total_paid` to NUMERIC(10,2) → `total_paid_amount`
- Add `source_system` metadata column

**Purpose**: Clean order data and standardize formats

#### stg_order_items
**Transformations**:
- Rename `id` → `order_item_pk`
- Rename `order_id` → `order_pk`
- Rename `product_id` → `product_pk`
- Cast `unit_price_at_sale` to NUMERIC(10,2)
- Add `source_system` metadata column

**Purpose**: Standardize foreign key naming and data types

### Characteristics
- ✅ Materialized as views (lightweight)
- ✅ Data quality checks applied
- ✅ Consistent naming conventions
- ✅ Type validation and casting

## Layer 3: Analytics Layer (analytics schema)

### Purpose
Business-ready dimensional models for reporting.

### Created By
**DBT models**: `data_models/models/marts/*.sql`

### Tables

#### dim_products
**Type**: Dimension table

**Purpose**: Complete product dimension with business-friendly attributes

**Columns**:
- `product_pk` - Dimension key (for joining to facts)
- `product_sku` - Product identifier
- `product_name` - Product name
- `product_category_name` - Human-readable category (Electronics, Apparel, Other)
- `current_unit_price` - Current price
- `current_stock` - Stock quantity
- `is_active` - Active status
- `created_timestamp` - Creation timestamp

**Business Logic**:
```sql
CASE
    WHEN category_id = 1 THEN 'Electronics'
    WHEN category_id = 2 THEN 'Apparel'
    ELSE 'Other' 
END AS product_category_name
```

**Materialization**: `table` for fast reads

#### fact_sales
**Type**: Fact table (star schema)

**Purpose**: Denormalized sales transactions ready for aggregation

**Columns**:
- `order_key` - Order dimension key
- `customer_key` - Customer dimension key
- `product_key` - Product dimension key
- `sales_timestamp` - Transaction timestamp
- `sales_date` - Transaction date (for date filtering)
- `units_sold` - Quantity sold
- `unit_price_at_sale` - Price at sale time
- `gross_revenue_amount` - Calculated: quantity × unit_price
- `product_sku` - Denormalized for convenience
- `product_category_name` - Denormalized for convenience
- `order_status` - Order status
- `source_system` - Source tracking

**Business Logic**:
1. Only includes orders with status = 'Delivered'
2. Filters out future-dated orders
3. Joins products to get category names
4. Calculates gross revenue

**Materialization**: `table` for performance

### Characteristics
- ✅ Materialized as tables (fast query performance)
- ✅ Star schema design
- ✅ Business logic embedded
- ✅ Ready for BI tools

## Data Transformation Examples

### Example 1: Product Category Translation

**Raw**: `category_id = 1`
**Staging**: `category_id = 1` (pass-through)
**Analytics**: `product_category_name = 'Electronics'`

### Example 2: Revenue Calculation

**Raw**: `quantity = 5`, `unit_price_at_sale = 19.99`
**Staging**: Pass-through with type casting
**Analytics**: `gross_revenue_amount = 99.95` (calculated)

### Example 3: Data Filtering

**Raw**: All orders (Pending, Processing, Delivered, Cancelled)
**Staging**: All orders (pass-through)
**Analytics**: Only 'Delivered' orders

## Why Three Layers?

### Raw Layer
- **Flexibility**: Can add new columns without breaking transformations
- **Auditability**: Preserves original source data
- **Performance**: Write-optimized design

### Staging Layer
- **Quality**: Standardizes data before complex transformations
- **Maintainability**: Centralizes cleaning logic
- **Testing**: Isolated transformations are easier to test

### Analytics Layer
- **Performance**: Pre-calculated aggregations
- **Business Logic**: Encodes business rules
- **Convenience**: Ready for direct BI consumption

## Data Lineage

Tracking data from source to report:

```
raw_products.id → stg_products.product_pk → dim_products.product_pk
                                                      ↓
                                              fact_sales.product_key

raw_orders.id → stg_orders.order_pk → fact_sales.order_key

raw_orders + raw_order_items → stg_orders + stg_order_items → fact_sales
```

---

**Next**: See [COMPONENTS.md](COMPONENTS.md) for detailed component information.


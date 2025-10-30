# pgAdmin Access Guide

This guide explains how to access and explore your database using the pgAdmin web interface.

## Accessing pgAdmin

### Web Browser Access

1. Open your web browser
2. Navigate to:
   ```
   http://localhost:8080
   ```

3. Log in with credentials from your `.env` file (PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD)

4. You should see the pgAdmin dashboard!

### Terminal Access (Alternative)

If you prefer command-line access:

```bash
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME
```

Type `\q` to exit.

## Setting Up Your First Connection

### Step 1: Create Server Connection

1. In the left sidebar of pgAdmin, right-click on **"Servers"**
2. Select **"Create" → "Server..."**
3. A dialog box will appear

### Step 2: Configure Connection

#### General Tab

- **Name**: `Production DB` (or any name you prefer)
- **Server Group**: `Servers` (default)

#### Connection Tab

Fill in the following details:

| Field | Value | Notes |
|-------|-------|-------|
| **Host name/address** | `db` | This is the Docker service name |
| **Port** | `5432` | Default PostgreSQL port |
| **Maintenance database** | `{your DB_NAME}` | From your .env file |
| **Username** | `{your DB_USER}` | From your .env file |
| **Password** | `{your DB_PASSWORD}` | From your .env file |
| **Save password?** | ✓ Check this box | Optional but convenient |

Click **"Save"**

### Step 3: Explore Your Database

Once connected, expand the server tree in the left sidebar:

```
Production DB
└── Databases
    └── {your_database_name}
        └── Schemas
            ├── public           # Raw tables
            ├── staging          # DBT staging views
            └── analytics        # DBT analytics tables
```

## Exploring Schemas

### Public Schema (Raw Layer)

Navigate to `Schemas → public → Tables`:

#### raw_products
- Product catalog master data
- Columns: id, product_sku, product_name, category_id, unit_price, current_stock, is_active, created_timestamp

#### raw_orders
- Sales order headers
- Columns: id, customer_id, order_status, order_timestamp, total_paid

#### raw_order_items
- Sales order line items
- Columns: id, order_id, product_id, quantity, unit_price_at_sale

**To view data**: Right-click a table → **"View/Edit Data" → "All Rows"**

### Staging Schema (Cleaning Layer)

Navigate to `Schemas → staging → Views`:

#### stg_products
- Cleaned and standardized product data
- SKUs uppercased, data types validated

#### stg_orders
- Cleaned order data
- Status fields trimmed, timestamps standardized

#### stg_order_items
- Cleaned order item data
- Foreign keys renamed, data types validated

**To view data**: Right-click a view → **"View/Edit Data" → "All Rows"**

**To see SQL**: Right-click a view → **"View/Edit Data" → "Properties"**

### Analytics Schema (Business Intelligence Layer)

Navigate to `Schemas → analytics → Tables`:

#### dim_products
- Product dimension table
- Includes human-readable category names
- Ready for dimension tables in star schema
- Columns: product_pk, product_sku, product_name, product_category_name, current_unit_price, current_stock, is_active, created_timestamp

#### fact_sales
- Sales fact table
- Denormalized for easy reporting
- Includes product and order data
- Filtered to only completed orders
- Columns: order_key, customer_key, product_key, sales_timestamp, sales_date, units_sold, unit_price_at_sale, gross_revenue_amount, product_sku, product_category_name, order_status, source_system

**These are the tables you'd typically connect to Power BI, Tableau, or other BI tools!**

## Running Queries

### Using Query Tool

1. Right-click on `{your_database_name}` → **"Query Tool"**
2. Type your SQL query, for example:

```sql
-- Count products by category
SELECT 
    product_category_name,
    COUNT(*) as product_count
FROM analytics.dim_products
GROUP BY product_category_name;
```

3. Click the execute button (▶️) or press `F5`

### Example Queries

#### Total Sales by Category
```sql
SELECT 
    product_category_name,
    SUM(gross_revenue_amount) as total_revenue,
    SUM(units_sold) as total_units
FROM analytics.fact_sales
GROUP BY product_category_name
ORDER BY total_revenue DESC;
```

#### Products with Low Stock
```sql
SELECT 
    product_sku,
    product_name,
    current_stock
FROM analytics.dim_products
WHERE current_stock < 10
ORDER BY current_stock;
```

#### Recent Orders
```sql
SELECT 
    order_key,
    sales_date,
    product_category_name,
    units_sold,
    gross_revenue_amount
FROM analytics.fact_sales
ORDER BY sales_timestamp DESC
LIMIT 10;
```

## Table Relationships

Understanding how tables relate:

```
raw_orders (id)
    ├── raw_order_items (order_id) → References raw_orders
    └── raw_order_items (product_id) → References raw_products (id)

stg_orders (order_pk)
    └── stg_order_items (order_pk) → References stg_orders

fact_sales
    ├── order_key → References stg_orders
    └── product_key → References dim_products
```

## Common pgAdmin Tasks

### View Table Structure
1. Right-click table → **"Properties"**
2. Select **"Columns"** tab

### Export Data
1. Right-click table → **"Import/Export Data"**
2. Choose export options
3. Select CSV, SQL, or JSON format

### View Indexes
1. Expand table → **"Indexes"**
2. See all indexes created for query performance

### Backup Database
1. Right-click database → **"Backup..."**
2. Choose backup options and location

---

**Next**: See [DATA_FLOW.md](DATA_FLOW.md) to understand how data transforms through layers.


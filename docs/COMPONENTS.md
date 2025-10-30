# Component Details

This document provides detailed information about the individual components and configuration files in this project.

## Docker Compose Services

The pipeline consists of four services orchestrated by Docker Compose.

### Service 1: PostgreSQL Database (`db`)

**Image**: `postgres:16-alpine`

**Purpose**: Production-ready relational database

**Configuration**:
- **Container Name**: `my_app_postgres_db`
- **Port**: `5432` (exposed to host)
- **Restart Policy**: `unless-stopped`
- **Health Check**: Checks readiness every 5 seconds

**Volumes**:
- `postgres_data` - Persistent storage for database files

**Environment Variables**:
- `POSTGRES_USER` - From `.env` (`DB_USER`)
- `POSTGRES_PASSWORD` - From `.env` (`DB_PASSWORD`)
- `POSTGRES_DB` - From `.env` (`DB_NAME`)

**Custom Configuration**:
- Listen on all addresses: `listen_addresses=*`

**Network**: `backend_network` (bridge)

### Service 2: Migration Service (`migration`)

**Image**: `flyway/flyway:latest`

**Purpose**: Apply database schema migrations

**Configuration**:
- **Container Name**: `db_migrator`
- **Depends On**: `db` (waits for health check)
- **Volumes**: `./migrations` → `/flyway/sql`

**Environment Variables**:
- `FLYWAY_URL` - `jdbc:postgresql://db:5432/${DB_NAME}`
- `FLYWAY_USER` - Database user
- `FLYWAY_PASSWORD` - Database password

**Command**:
```bash
sleep 5 && flyway migrate -locations=filesystem:/flyway/sql
```

**Lifecycle**: Runs once, then exits

### Service 3: DBT Transformation Service (`dbt`)

**Image**: `ghcr.io/dbt-labs/dbt-postgres:latest`

**Purpose**: Transform raw data through staging to analytics

**Configuration**:
- **Container Name**: `data_transformer`
- **Platform**: `linux/amd64`
- **Depends On**: `migration` (waits for completion)
- **Volumes**: `./data_models` → `/usr/app/dbt_project`

**Environment Variables**:
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `DB_NAME` - Database name

**Command**:
```bash
sleep 10 && dbt debug --target prod && dbt run --target prod
```

**Lifecycle**: Runs once, then exits

### Service 4: pgAdmin (`pgadmin`)

**Image**: `dpage/pgadmin4`

**Purpose**: Web-based database administration UI

**Configuration**:
- **Container Name**: `pgadmin_ui`
- **Port**: `8080:80` (host:container)
- **Restart Policy**: `unless-stopped`
- **Depends On**: `db` (waits for health check)

**Environment Variables**:
- `PGADMIN_DEFAULT_EMAIL` - Login email
- `PGADMIN_DEFAULT_PASSWORD` - Login password
- `PGADMIN_CONFIG_CHECK_EMAIL_DELIVERABILITY` - `False`
- `PGADMIN_CONFIG_ALLOW_SPECIAL_EMAIL_DOMAINS` - Allows local/test domains

**Network**: `backend_network` (bridge)

## DBT Configuration

### `data_models/dbt_project.yml`

Main dbt project configuration file.

**Key Settings**:
- **Name**: `data_models`
- **Version**: `1.0.0`
- **Profile**: `data_models` (references profiles.yml)
- **Config Version**: `2`

**Model Paths**:
- `models` - Model files
- `analyses` - Analysis queries
- `tests` - Test definitions
- `seeds` - Seed data
- `macros` - Custom macros
- `snapshots` - Snapshot definitions

**Materialization Strategy**:
```yaml
models:
  data_models:
    staging:
      +materialized: view      # Lightweight transformations
      +schema: staging
    marts:
      +materialized: table     # Performance-optimized
      +schema: analytics
```

### `data_models/profiles.yml`

Database connection configuration.

**Profile Name**: `data_models`

**Target**: `prod`

**Connection Details**:
- **Type**: `postgres`
- **Threads**: `4` (parallel transformations)
- **Host**: `db` (Docker service name)
- **Port**: `5432`
- **User**: From `DB_USER` environment variable
- **Password**: From `DB_PASSWORD` environment variable
- **Database**: From `DB_NAME` environment variable
- **Schema**: `public` (where raw data lives)

### `data_models/models/sources.yml`

Definition of source tables for lineage tracking.

**Source Name**: `public`

**Tables**:
- `raw_products`
- `raw_orders`
- `raw_order_items`

**Purpose**: dbt tracks data lineage from these sources

## Migration Files

### `migrations/V1__create_raw_tables.sql`

Initial schema creation.

**Purpose**: Create raw tables with constraints and indexes

**Tables Created**:
1. `raw_products` - Product catalog
   - Primary key: `id`
   - Unique index on `product_sku`
   - Index on `category_id`
   - Check constraints on price and stock

2. `raw_orders` - Order headers
   - Primary key: `id`
   - Index on `customer_id`
   - Index on `order_timestamp`

3. `raw_order_items` - Order line items
   - Primary key: `id`
   - Foreign key to `raw_orders` (CASCADE delete)
   - Foreign key to `raw_products` (RESTRICT delete)
   - Unique constraint on (order_id, product_id)
   - Check constraint on quantity

**Features**:
- Transaction-safe: wrapped in `BEGIN`/`COMMIT`
- Idempotent: `CREATE TABLE IF NOT EXISTS`
- Performance: Strategic indexes
- Integrity: Foreign keys and check constraints

### `migrations/V2__add_foreign_keys.sql`

Placeholder for additional constraints.

**Current Status**: Empty (ready for future enhancements)

**Potential Uses**:
- Add composite foreign keys
- Add additional check constraints
- Create additional indexes

## Staging Models

### `data_models/models/staging/stg_products.sql`

**Purpose**: Clean and standardize product data

**Materialization**: `view`

**Key Transformations**:
- Rename: `id` → `product_pk`
- Standardize: Uppercase product SKUs
- Cast: Ensure proper numeric types
- Add: Source system metadata

**Referenced Source**: `{{ source('public', 'raw_products') }}`

### `data_models/models/staging/stg_orders.sql`

**Purpose**: Clean and standardize order data

**Materialization**: `view`

**Key Transformations**:
- Rename: `id` → `order_pk`
- Clean: Trim whitespace from status
- Cast: Ensure proper numeric types
- Add: Source system metadata

**Referenced Source**: `{{ source('public', 'raw_orders') }}`

### `data_models/models/staging/stg_order_items.sql`

**Purpose**: Clean and standardize order item data

**Materialization**: `view`

**Key Transformations**:
- Rename: Standardize primary/foreign key names
- Cast: Ensure proper numeric types
- Add: Source system metadata

**Referenced Source**: `{{ source('public', 'raw_order_items') }}`

## Analytics Models

### `data_models/models/marts/dim_products.sql`

**Purpose**: Create product dimension table

**Materialization**: `table` in `analytics` schema

**Tags**: `['core_dimension', 'daily_run']`

**Key Features**:
- Primary key: `product_pk`
- Business-friendly column names
- Category translation logic
- Current price and stock status

**Referenced Model**: `{{ ref('stg_products') }}`

### `data_models/models/marts/fact_sales.sql`

**Purpose**: Create sales fact table (star schema)

**Materialization**: `table` in `analytics` schema

**Tags**: `['finance', 'daily_run', 'fact']`

**Key Features**:
- Foreign keys to dimensions
- Pre-calculated measures (revenue)
- Denormalized attributes for convenience
- Business filters (only delivered orders)
- Temporal dimensions

**Referenced Models**:
- `{{ ref('stg_order_items') }}`
- `{{ ref('stg_orders') }}`
- `{{ ref('dim_products') }}`

**Business Logic**:
```sql
WHERE
    o.order_status = 'Delivered' 
    AND o.order_timestamp <= NOW()
```

## Configuration Files

### `.env`

**Purpose**: Environment-specific configuration (secrets)

**Contents**:
- Database credentials
- pgAdmin credentials

**Security**: Never commit to version control (`.gitignore`)

### `.gitignore`

**Contents**: `.env`

**Purpose**: Prevent accidental commit of secrets

### `docker-compose.yml`

**Purpose**: Orchestrate all services

**Key Sections**:
1. Services definition
2. Volume definitions
3. Network definitions

**Volumes**:
- `postgres_data` - Persistent database storage

**Networks**:
- `backend_network` - Bridge network for service communication

---

**Next**: See [COMMANDS.md](COMMANDS.md) for useful commands and operations.


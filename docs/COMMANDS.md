# Commands Reference

This document provides a comprehensive list of commands for operating and managing the data pipeline.

## Table of Contents

- [Docker Compose Commands](#docker-compose-commands)
- [Database Commands](#database-commands)
- [DBT Commands](#dbt-commands)
- [Viewing Logs](#viewing-logs)
- [Data Management](#data-management)
- [Troubleshooting](#troubleshooting)

## Docker Compose Commands

### Starting Services

#### Start All Services
```bash
docker compose up -d
```
- Starts all containers in detached mode (background)
- Creates network and volumes if needed
- Runs migrations and transformations automatically

#### Start Specific Service
```bash
docker compose up -d db           # Start only database
docker compose up -d pgadmin      # Start only pgAdmin
```

### Stopping Services

#### Stop Services (Keep Containers)
```bash
docker compose stop
```
- Stops running containers
- Preserves containers and data

#### Remove Containers
```bash
docker compose down
```
- Stops and removes containers
- Keeps volumes (data preserved)

#### Remove Everything (Including Data)
```bash
docker compose down -v
```
- ⚠️ **Warning**: Deletes all data!
- Use for complete fresh start

### Viewing Status

#### List Container Status
```bash
docker compose ps
```

**Expected Output**:
```
NAME                      STATUS
my_app_postgres_db        running (healthy)
db_migrator               exited (0)
data_transformer          exited (0)
pgadmin_ui                running
```

#### View Service Health
```bash
docker compose ps --format json
```

## Database Commands

### Access PostgreSQL CLI

#### Quick Access
```bash
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME
```

#### With Custom Commands
```bash
# List all databases
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "\l"

# List all schemas
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "\dn"

# List all tables
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "\dt public.*"
```

### Common psql Commands

Once inside psql:

```sql
-- List schemas
\dn

-- List tables in public schema
\dt public.*

-- List views in staging schema
\dv staging.*

-- Describe table structure
\d analytics.fact_sales

-- Exit psql
\q
```

### Running SQL Scripts

```bash
docker exec -i my_app_postgres_db psql -U $DB_USER -d $DB_NAME < script.sql
```

## DBT Commands

### Running dbt Inside Container

#### Debug Connection
```bash
docker exec -it data_transformer dbt debug --target prod
```
Checks database connection and configuration.

#### Run All Models
```bash
docker exec -it data_transformer dbt run --target prod
```
Rebuilds all dbt models.

#### Run Specific Model
```bash
docker exec -it data_transformer dbt run --select dim_products --target prod
docker exec -it data_transformer dbt run --select fact_sales --target prod
```

#### Run by Tags
```bash
# Run all staging models
docker exec -it data_transformer dbt run --select tag:staging --target prod

# Run all daily_run models
docker exec -it data_transformer dbt run --select tag:daily_run --target prod

# Run all finance models
docker exec -it data_transformer dbt run --select tag:finance --target prod
```

#### Run Tests
```bash
docker exec -it data_transformer dbt test --target prod
```

#### View Documentation
```bash
docker exec -it data_transformer dbt docs generate --target prod
docker exec -it data_transformer dbt docs serve --target prod
```

### Interactive dbt Shell

```bash
docker exec -it data_transformer bash
cd /usr/app/dbt_project
dbt debug --target prod
dbt run --target prod
exit
```

## Viewing Logs

### All Services
```bash
docker compose logs
```

### Specific Service
```bash
docker compose logs db
docker compose logs migration
docker compose logs dbt
docker compose logs pgadmin
```

### Follow Logs (Real-time)
```bash
docker compose logs -f db
docker compose logs -f dbt
```

### Last N Lines
```bash
docker compose logs --tail=50 db
docker compose logs --tail=100 dbt
```

### Logs with Timestamps
```bash
docker compose logs -t db
docker compose logs -t dbt
```

## Data Management

### Adding Sample Data

#### Insert Sample Products
```bash
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "
INSERT INTO public.raw_products (product_sku, product_name, category_id, unit_price, current_stock, is_active) VALUES
('LAPTOP-001', 'Gaming Laptop', 1, 1299.99, 15, true),
('LAPTOP-002', 'Business Laptop', 1, 899.99, 25, true),
('TSHIRT-M', 'Cotton T-Shirt (M)', 2, 19.99, 100, true),
('TSHIRT-L', 'Cotton T-Shirt (L)', 2, 19.99, 150, true),
('JEANS-32', 'Blue Jeans (32)', 2, 49.99, 75, true);
"
```

#### Insert Sample Orders
```bash
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "
INSERT INTO public.raw_orders (customer_id, order_status, order_timestamp, total_paid) VALUES
(1, 'Delivered', NOW() - INTERVAL '2 days', 1299.99),
(2, 'Delivered', NOW() - INTERVAL '1 day', 39.98),
(3, 'Processing', NOW(), 49.99);
"
```

#### Insert Sample Order Items
```bash
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "
INSERT INTO public.raw_order_items (order_id, product_id, quantity, unit_price_at_sale) VALUES
(1, 1, 1, 1299.99),
(2, 3, 2, 19.99),
(3, 5, 1, 49.99);
"
```

### Refresh Transformations

After adding data to raw tables, refresh the pipeline:

```bash
# Rebuild staging views and analytics tables
docker exec -it data_transformer dbt run --target prod
```

### Backup Database

#### Full Backup
```bash
docker exec -it my_app_postgres_db pg_dump -U $DB_USER $DB_NAME > backup.sql
```

#### Schema-Only Backup
```bash
docker exec -it my_app_postgres_db pg_dump -U $DB_USER -s $DB_NAME > schema_only.sql
```

#### Restore Backup
```bash
docker exec -i my_app_postgres_db psql -U $DB_USER $DB_NAME < backup.sql
```

### Query Data from Command Line

```bash
# Total products
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "
SELECT COUNT(*) FROM public.raw_products;
"

# Sales summary
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    product_category_name,
    SUM(gross_revenue_amount) as total_revenue
FROM analytics.fact_sales
GROUP BY product_category_name;
"
```

## Troubleshooting

### Check Service Health

```bash
# Container status
docker compose ps

# Container health
docker inspect my_app_postgres_db --format='{{.State.Health.Status}}'
```

### Reset Everything

```bash
# Stop and remove all containers and volumes
docker compose down -v

# Remove unused images (optional)
docker image prune

# Restart fresh
docker compose up -d
```

### Check Port Usage

```bash
# Check if ports are in use
lsof -i :5432   # PostgreSQL
lsof -i :8080   # pgAdmin

# On Windows
netstat -ano | findstr :5432
netstat -ano | findstr :8080
```

### View Container Details

```bash
# Inspect container
docker inspect my_app_postgres_db

# View container IP
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my_app_postgres_db

# View container logs
docker logs my_app_postgres_db
docker logs db_migrator
docker logs data_transformer
docker logs pgadmin_ui
```

### Fix Permission Issues

```bash
# If you have permission issues, run as root
docker exec -u root -it my_app_postgres_db bash
```

### Database Connection Test

```bash
# Test database connectivity
docker exec -it my_app_postgres_db pg_isready -U $DB_USER
```

### Check DBT Project Files

```bash
# List dbt project files
docker exec -it data_transformer ls -la /usr/app/dbt_project

# Verify dbt configuration
docker exec -it data_transformer cat /usr/app/dbt_project/dbt_project.yml
```

### Rebuild Single Container

```bash
# Rebuild and restart specific service
docker compose up -d --force-recreate db

# Rebuild without cache
docker compose build --no-cache dbt
docker compose up -d dbt
```

## Useful One-Liners

### Quick Status Check
```bash
docker compose ps && echo "---" && docker compose logs --tail=10 dbt
```

### Watch Logs for Multiple Services
```bash
docker compose logs -f db dbt
```

### Execute SQL and Exit
```bash
docker exec my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "SELECT NOW();"
```

### Get Row Counts
```bash
docker exec -it my_app_postgres_db psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    schemaname,
    tablename,
    n_tup_ins - n_tup_del as row_count
FROM pg_stat_user_tables
ORDER BY schemaname, tablename;
"
```

---

**Next**: Return to [README.md](../README.md) for project overview.


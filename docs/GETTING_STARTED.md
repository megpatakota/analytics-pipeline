# Getting Started

This guide will help you set up and run the data pipeline from scratch.

## Prerequisites

Before you begin, ensure you have:

- **Docker** installed and running
- **Docker Compose** installed
- Terminal access (bash, zsh, or PowerShell)
- A code editor (VS Code, IntelliJ, etc.)

### Verify Docker Installation

```bash
docker --version
docker compose version
```

Both commands should return version numbers.

## Step-by-Step Setup

### Step 1: Create Environment File

Create a `.env` file in the project root directory:

```bash
cp .env.example .env
```

Then edit `.env` with your actual credentials. The `.env.example` file provides a template with placeholder values.

Alternatively, you can create `.env` manually:

```ini
# Database Credentials
DB_USER=your_db_user
DB_PASSWORD=your_strong_password
DB_NAME=your_database_name

# pgAdmin Credentials
PGADMIN_DEFAULT_EMAIL=your_email@example.com
PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password
```

> ⚠️ **Security Note**: Use strong, randomly generated passwords for all credentials!

> 📝 **Note**: The `.env` file is already in `.gitignore` to prevent accidental commits. Never commit sensitive credentials.

### Step 2: Start All Services

From the project root, run:

```bash
docker compose up -d
```

This command will:
1. ✅ Pull required Docker images (if not already present)
2. ✅ Start PostgreSQL database container
3. ✅ Wait for database to be healthy
4. ✅ Run Flyway migrations (create raw tables)
5. ✅ Execute dbt transformations (create staging views and analytics tables)
6. ✅ Launch pgAdmin web interface

The `-d` flag runs containers in detached mode (background).

### Step 3: Verify Services Are Running

Check container status:

```bash
docker compose ps
```

**Expected output**:
```
NAME                      STATUS
my_app_postgres_db        running (healthy)
db_migrator               exited (0)
data_transformer          exited (0)
pgadmin_ui                running
```

**Status meanings**:
- `running (healthy)` - Service is operational
- `exited (0)` - Service completed successfully (migrations and transformations)
- `running` - Service is active

### Step 4: Check Logs (Optional)

If you want to verify everything ran correctly:

```bash
# Database logs
docker compose logs db

# Migration logs
docker compose logs migration

# DBT transformation logs
docker compose logs dbt
```

Look for `Successfully applied` (Flyway) and `Completed successfully` (dbt).

## What Just Happened?

Your data pipeline is now running! Here's what was created:

### Database Schemas Created

1. **`public`** schema (Raw Layer)
   - `raw_products` table
   - `raw_orders` table
   - `raw_order_items` table

2. **`staging`** schema (Cleaning Layer)
   - `stg_products` view
   - `stg_orders` view
   - `stg_order_items` view

3. **`analytics`** schema (Business Intelligence Layer)
   - `dim_products` table
   - `fact_sales` table

## Next Steps

Now that your pipeline is running:

1. **View the data** → See [PGADMIN_GUIDE.md](PGADMIN_GUIDE.md) to explore tables
2. **Understand the data flow** → See [DATA_FLOW.md](DATA_FLOW.md)
3. **Add sample data** → See [COMMANDS.md](COMMANDS.md#adding-sample-data)

## Troubleshooting

### Containers won't start

**Issue**: `docker compose up -d` fails

**Solutions**:
- Check if ports 5432 and 8080 are already in use
- Verify Docker is running: `docker ps`
- Check logs: `docker compose logs`

### Database connection refused

**Issue**: Cannot connect to database

**Solutions**:
- Wait for health checks to complete: `docker compose ps`
- Verify `.env` file exists and has correct values
- Check database logs: `docker compose logs db`

### dbt transformations failed

**Issue**: `data_transformer` exited with non-zero code

**Solutions**:
- Check dbt logs: `docker compose logs dbt`
- Verify migrations ran successfully
- Rebuild containers: `docker compose down -v && docker compose up -d`

### pgAdmin not accessible

**Issue**: Cannot access http://localhost:8080

**Solutions**:
- Verify pgAdmin container is running: `docker compose ps`
- Check if port 8080 is available: `lsof -i :8080` (Mac/Linux)
- Wait 30-60 seconds for pgAdmin to fully initialize

## Stopping Services

To stop all services:

```bash
docker compose stop
```

To remove containers and data volumes (complete cleanup):

```bash
docker compose down -v
```

**Warning**: `docker compose down -v` will delete all data!

---

**Next**: See [PGADMIN_GUIDE.md](PGADMIN_GUIDE.md) to view your data.


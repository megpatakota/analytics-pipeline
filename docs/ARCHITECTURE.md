# Architecture Overview

This document explains the high-level architecture and design patterns used in this data pipeline.

## 🏗️ Architecture Diagram

```
┌─────────────────┐
│   Application   │  (Writes data)
└────────┬────────┘
         │ Writes to
         ▼
┌─────────────────┐
│  Raw Tables     │  (public schema)
│  - raw_products │
│  - raw_orders   │
│  - raw_order_items│
└────────┬────────┘
         │ Transformed by
         ▼
┌─────────────────┐      ┌──────────────────┐
│  Staging Views  │ ───► │  Analytics Marts │
│  (staging schema)│      │  (analytics schema)│
│  - stg_products │      │  - dim_products  │
│  - stg_orders   │      │  - fact_sales    │
│  - stg_order_items│    └──────────────────┘
└─────────────────┘
```

## The Three-Layer Architecture

### 1. Raw Layer (`public` schema)
**Purpose**: Direct copy of source data with minimal transformation

**Characteristics**:
- Primary data landing zone
- Preserves original data structure
- Foreign keys and indexes for integrity
- Application writes directly here

**Files**:
- `migrations/V1__create_raw_tables.sql` - Creates raw tables

### 2. Staging Layer (`staging` schema)
**Purpose**: Cleaned, standardized, and validated data

**Characteristics**:
- Materialized as views (lightweight)
- Data quality checks and transformations
- Column renaming and type casting
- Source system tracking
- Foundation for analytics layer

**Files**:
- `data_models/models/staging/stg_products.sql`
- `data_models/models/staging/stg_orders.sql`
- `data_models/models/staging/stg_order_items.sql`

### 3. Analytics Layer (`analytics` schema)
**Purpose**: Business-ready dimensional models for reporting

**Characteristics**:
- Materialized as tables (performant)
- Star schema design (fact and dimensions)
- Denormalized for BI tool consumption
- Business logic embedded
- Ready for Power BI, Tableau, etc.

**Files**:
- `data_models/models/marts/dim_products.sql` - Product dimension
- `data_models/models/marts/fact_sales.sql` - Sales fact table

## Design Principles

1. **Separation of Concerns**: Each layer has a distinct purpose
2. **Idempotency**: Transformations can run multiple times safely
3. **Lineage**: Clear data flow from raw to analytics
4. **Modularity**: Each transformation is independently testable
5. **Performance**: Views for flexibility, tables for performance

## Data Flow Summary

1. **Application** writes to raw tables
2. **Flyway** manages schema changes
3. **DBT** transforms raw → staging → analytics
4. **BI Tools** consume analytics tables

## Technology Stack

| Technology | Purpose |
|------------|---------|
| **PostgreSQL 16** | Production-ready relational database |
| **Docker Compose** | Multi-container orchestration |
| **Flyway** | Database migration management |
| **DBT** | SQL-based data transformation |
| **pgAdmin 4** | Web-based database administration |

---

**Next**: See [GETTING_STARTED.md](GETTING_STARTED.md) for setup instructions.


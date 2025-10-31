# Quality Checks & Guardrails

This document outlines the security, data quality, and reliability features built into the pipeline.

## Database Constraints (Raw Layer)

### Product Table
- **Unique SKU**: Prevents duplicate products
- **Length checks**: SKU minimum 3 characters, name minimum 1 character
- **Price validation**: Unit price must be >= 0
- **Stock validation**: Current stock must be >= 0
- **Category validation**: Category ID must be > 0 if provided
- **Timestamp validation**: Created timestamp cannot be in the future

### Orders Table
- **Customer validation**: Customer ID must be > 0
- **Status validation**: Must be one of: Pending, Processing, Shipped, Delivered, Cancelled
- **Timestamp validation**: Order timestamp cannot be in the future
- **Payment validation**: Total paid must be >= 0
- **Status index**: Speeds up status-based queries

### Order Items Table
- **Quantity validation**: Must be between 1 and 10,000
- **Price validation**: Unit price must be >= 0
- **Unique constraint**: Prevents duplicate product per order
- **Foreign keys**: Cascade deletes for orders, restrict for products

## Transaction Safety
- All migrations wrapped in `BEGIN`/`COMMIT` transactions
- Failed migrations roll back completely (no half-broken tables)

## Data Quality Tests (dbt)

### Staging Layer Tests
- **Uniqueness**: All primary keys must be unique
- **Not null**: Critical fields cannot be missing
- **Quantity validation**: Order items must have positive quantities

### Analytics Layer Tests
- **Not null**: All fact table keys and timestamps required
- **Revenue validation**: Gross revenue must be >= 0
- **Units validation**: Units sold must be > 0
- **Timestamp range**: Sales timestamps must be after 2000-01-01 and before now
- **Relationship integrity**: Product keys must exist in dimension table

## Security Features

### Credential Management
- `.env` file ignored by git (never committed)
- `.env.example` template shows required fields without exposing values
- Environment variables used throughout for sensitive configuration

### Access Control
- Database credentials injected at runtime
- No hardcoded passwords in code or configuration files

## Incremental Processing

### Safety Features
- Only processes new records since last successful run
- Prevents reprocessing entire datasets on failure
- Late-arriving data can be backfilled without full refresh

### Data Integrity
- COALESCE ensures first run doesn't fail on empty table
- Timestamp-based filtering prevents data loss
- Automatic index maintenance on incremental tables

## Performance Guarantees

### Automated Maintenance
- VACUUM (ANALYZE) runs after transformations
- Keeps query planner statistics current
- Prevents table bloat over time

### Resource Management
- Docker memory limits prevent OOM crashes
- CPU limits ensure services don't compete excessively
- Proper indexing on frequently queried columns

## Monitoring & Observability

### dbt Lineage
- Tracks data flow from raw to analytics
- Identifies upstream impacts of changes
- Shows which models depend on each other

### Logs
- All services log to standard output
- dbt logs show transformation progress and failures
- Migration logs confirm schema changes applied

## Running Tests

### Full Test Suite
```bash
docker exec -it data_transformer dbt test --target prod
```

### Test Specific Models
```bash
docker exec -it data_transformer dbt test --select staging --target prod
docker exec -it data_transformer dbt test --select marts --target prod
```

### Test Specific Checks
```bash
docker exec -it data_transformer dbt test --select fact_sales --target prod
```

## Failure Scenarios Handled

1. **Invalid data at source**: Constraints reject bad input
2. **Migration failure**: Transaction rollback keeps DB consistent
3. **Transformation failure**: Dependent models don't run
4. **Incremental run issues**: Can force full refresh to recover
5. **Memory issues**: Resource limits prevent cascading failures
6. **Stale statistics**: Auto VACUUM keeps query planner accurate

## Adding New Checks

### Database Constraints
Add to `migrations/V1__create_raw_tables.sql` (or new migration file):
```sql
ALTER TABLE public.raw_products 
ADD CONSTRAINT check_name_not_empty 
CHECK (product_name != '');
```

### dbt Tests
Add to relevant `schema.yml`:
```yaml
- name: your_model
  tests:
    - dbt_utils.expression_is_true:
        expression: "revenue >= 0"
```

### Custom Macros
Create in `data_models/macros/`:
```sql
{% macro validate_revenue() %}
    CASE 
        WHEN revenue < 0 THEN FALSE
        ELSE TRUE
    END
{% endmacro %}
```

---

**Remember**: Quality checks are your first line of defense. The more you catch at the data layer, the less your downstream users will suffer.


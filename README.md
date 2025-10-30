# SQL Data Pipeline with PostgreSQL, DBT, and Docker

This project demonstrates a modern data engineering pipeline using Docker, PostgreSQL, Flyway migrations, and dbt for data transformation. The architecture follows a layered approach: **Raw Data → Staging → Analytics Marts**.

## 📚 Documentation

This project's documentation is organized into focused guides for easy navigation:

| Document | Description |
|----------|-------------|
| **[Architecture Overview](docs/ARCHITECTURE.md)** | High-level architecture and design patterns |
| **[Getting Started](docs/GETTING_STARTED.md)** | Setup instructions and first steps |
| **[pgAdmin Guide](docs/PGADMIN_GUIDE.md)** | How to access and use the database UI |
| **[Data Flow](docs/DATA_FLOW.md)** | How data moves through the pipeline |
| **[Components](docs/COMPONENTS.md)** | Detailed component documentation |
| **[Commands Reference](docs/COMMANDS.md)** | Useful commands and operations |

## 📋 Quick Start

For the fastest start, see the [Getting Started Guide](docs/GETTING_STARTED.md). Quick summary:

For details, see [Architecture Overview](docs/ARCHITECTURE.md).

---

### Project Structure

```
sql/
├── .env                                    # Environment variables (secrets)
├── docker-compose.yml                       # Multi-service orchestration
├── README.md                                # This file
├── docs/                                    # 📚 Documentation folder
│   ├── ARCHITECTURE.md                     # Architecture details
│   ├── GETTING_STARTED.md                  # Setup guide
│   ├── PGADMIN_GUIDE.md                    # Database UI guide
│   ├── DATA_FLOW.md                        # Data flow documentation
│   ├── COMPONENTS.md                       # Component details
│   └── COMMANDS.md                         # Commands reference
├── app/                                     # Application code
│   └── app.py                              # (To be implemented)
├── data_models/                             # DBT Project
│   ├── dbt_project.yml                     # DBT configuration
│   ├── profiles.yml                        # Database connection details
│   └── models/
│       ├── sources.yml                     # Raw table references
│       ├── staging/                        # Data cleaning layer
│       └── marts/                          # Business intelligence layer
├── infrastructure/
│   └── postgres/
│       └── postgresql.conf                 # PostgreSQL configuration
└── migrations/                             # Database schema
    ├── V1__create_raw_tables.sql           # Creates raw tables
    └── V2__add_foreign_keys.sql            # (Optional) FK constraints
```

### Prerequisites
- Docker & Docker Compose installed
- Terminal access

### Basic Setup
1. Create `.env` file (see example in [Getting Started](docs/GETTING_STARTED.md))
2. Run `docker compose up -d`
3. Access pgAdmin at http://localhost:8080

**For detailed instructions**: See [Getting Started Guide](docs/GETTING_STARTED.md)

---

## 🛠️ Technology Stack

| Technology | Purpose |
|------------|---------|
| **PostgreSQL 16** | Production-ready relational database |
| **Docker Compose** | Multi-container orchestration |
| **Flyway** | Database migration management |
| **DBT (Data Build Tool)** | SQL-based data transformation |
| **pgAdmin 4** | Web-based PostgreSQL administration UI |

---

## 📝 Quick Commands Reference

```bash
# Start services
docker compose up -d

# View status
docker compose ps

# View logs
docker compose logs -f db

# Access database CLI
docker exec -it my_app_postgres_db psql -U prod_app_user_2025 -d primary_app_db

# Rebuild transforms
docker exec -it data_transformer dbt run --target prod
```

**For complete commands**: See [Commands Reference](docs/COMMANDS.md)

---

## 🎯 Next Steps

1. **Read the Docs**: Explore the detailed guides in the `docs/` folder
2. **Add Sample Data**: See [Commands Reference](docs/COMMANDS.md#adding-sample-data)
3. **Explore Data**: Follow the [pgAdmin Guide](docs/PGADMIN_GUIDE.md)
4. **Understand Flow**: Read [Data Flow Documentation](docs/DATA_FLOW.md)
5. **Extend Pipeline**: Add more models, implement `app.py`, connect BI tools

---

## 📚 Additional Resources

### External Documentation
- [DBT Documentation](https://docs.getdbt.com/) - Learn dbt best practices
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) - SQL reference
- [Docker Compose Documentation](https://docs.docker.com/compose/) - Container orchestration
- [Flyway Documentation](https://flywaydb.org/documentation/) - Database migrations

### Project Documentation
- [Architecture Overview](docs/ARCHITECTURE.md)
- [Getting Started](docs/GETTING_STARTED.md)
- [pgAdmin Guide](docs/PGADMIN_GUIDE.md)
- [Data Flow](docs/DATA_FLOW.md)
- [Components](docs/COMPONENTS.md)
- [Commands Reference](docs/COMMANDS.md)

---

## 🤝 Contributing

This is a sample project for learning modern data engineering practices. Feel free to adapt it for your own use case!

---

**Happy Data Engineering! 🚀**


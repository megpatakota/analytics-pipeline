my-data-repo/
├── .env                              # Project-wide environment variables (SECRETS)
├── docker-compose.yml                # Infrastructure definition (Postgres, App, ETL Orchestration)
│
├── data_models/                      #    Clear and Descriptive Home for dbt Code
│   ├── profiles.yml                  #    dbt connection to PostgreSQL
│   ├── dbt_project.yml               #    dbt project configuration
│   └── models/                       #    The core data transformation logic
│       ├── staging/                  #    A. Staging/Source Layer (Raw data cleaning)
│       ├── marts/                    #    B. Business/Marts Layer (Final reporting tables)
│       └── sources.yml               #    Definition of the raw PostgreSQL tables
│
├── infrastructure/                   # 2. Infrastructure configuration files (Optional, but clean)
│   └── postgres/
│       └── postgresql.conf           #    Custom PostgreSQL tuning file
│
├── migrations/                       # 3. Database Schema Migration Scripts
│   ├── V1__create_raw_tables.sql     #    Raw table DDL from Step 1
│   └── V2__add_foreign_keys.sql
│
└── application/                      # 4. Your Web/API Application Code 
    └── app.py                        #    (This code interacts ONLY with the raw tables)
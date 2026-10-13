# Financial Fraud Pipeline

End-to-end banking data pipeline using Kaggle Indian Financial Fraud dataset.

## Architecture
S3 (Raw) → Databricks (Bronze/Silver/Gold) → Delta Lake → Airflow → SQL Analytics

## Tech Stack
Python | PySpark | AWS S3 | Databricks | Delta Lake | Airflow | SQL | Git

## Dataset
Kaggle: Indian Financial Fraud Dataset
- Transaction_Data_250k.csv  → Fact table (250k transactions)
- Cards_Data.csv             → dim_card
- Cusmtomer_data.csv         → dim_customer
- merchant_table.csv         → dim_merchant

## Concepts Covered
- Medallion architecture (Bronze → Silver → Gold)
- Star schema (Fact + Dimensions)
- Delta Lake ACID transactions
- Incremental loads with MERGE
- Airflow DAG orchestration

## Setup
1. `python -m venv venv && source venv/bin/activate`
2. `pip install -r requirements.txt`
3. Place Kaggle CSVs in `data/raw/`
4. Run `python inspect_data.py` to profile data
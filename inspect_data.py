"""
inspect_data.py
Purpose: Look at the Kaggle CSVs to understand columns, types, nulls.
Run once, note findings, then move on.
"""

import pandas as pd

FILES = {
    "transactions": "data/raw/Transaction_Data_250k.csv",
    "cards":        "data/raw/Cards_Data.csv",
    "customers":    "data/raw/Cusmtomer_data.csv",
    "merchants":    "data/raw/merchant_table.csv",
}

for name, path in FILES.items():
    print(f"\n{'='*70}")
    print(name.upper())
    print('='*70)

    df = pd.read_csv(path, nrows=5000)

    print(f"Shape (sample): {df.shape}")
    print(f"\nColumns ({len(df.columns)}): {list(df.columns)}")
    print(f"\nDtypes:\n{df.dtypes}")
    print(f"\nNulls:\n{df.isnull().sum()}")
    print(f"\nHead:\n{df.head(3)}")


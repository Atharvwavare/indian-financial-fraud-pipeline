"""
upload_to_s3.py
Purpose: Upload Kaggle CSVs to S3 raw/ folder.
Why: Manual uploads don't scale; this is reusable and will be called by Airflow later.
"""

import boto3
import os
from botocore.exceptions import ClientError

# ── Configuration ──────────────────────────────────────────
BUCKET_NAME = "finance-fraud-analytics-aw"  # ← change if your bucket name differs
S3_PREFIX = "raw/"  # target folder in S3
LOCAL_DATA_PATH = "data/raw/"  # local folder with CSVs

FILES_TO_UPLOAD = [
    "Transaction_Data_250k.csv",
    "Cards_Data.csv",
    "Cusmtomer_data.csv",
    "merchant_table.csv",
]


# ───────────────────────────────────────────────────────────


def upload_file(local_path: str, s3_key: str) -> bool:
    """
    Upload one file to S3.

    Args:
        local_path: Path to local file
        s3_key: Full S3 key (folder + filename)

    Returns:
        True if success, False otherwise.
    """
    s3_client = boto3.client("s3")

    try:
        s3_client.upload_file(local_path, BUCKET_NAME, s3_key)
        print(f"   Uploaded → s3://{BUCKET_NAME}/{s3_key}")
        return True
    except ClientError as e:
        print(f"   Failed: {e}")
        return False


def main():
    print(f" Uploading to s3://{BUCKET_NAME}/{S3_PREFIX}\n")

    success = 0
    for filename in FILES_TO_UPLOAD:
        local_path = os.path.join(LOCAL_DATA_PATH, filename)

        if not os.path.exists(local_path):
            print(f"   Missing: {local_path}")
            continue

        s3_key = f"{S3_PREFIX}{filename}"
        if upload_file(local_path, s3_key):
            success += 1

    print(f"\n Done: {success}/{len(FILES_TO_UPLOAD)} files uploaded.")


if __name__ == "__main__":
    main()
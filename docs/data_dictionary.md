# Data Dictionary — BankTransaction 360

## Source
Kaggle: Indian Financial Fraud Dataset

## Gold Layer Tables

### fact_transactions (Fact)
| Column | Type | Description |
|--------|------|-------------|
| transaction_key | string | Primary key (business ID) |
| customer_key | string | FK → dim_customer |
| card_key | string | FK → dim_card |
| merchant_key | string | FK → dim_merchant |
| date_key | int | FK → dim_date (yyyyMMdd) |
| transaction_date | date | Date of transaction |
| transaction_time | time | Time of transaction |
| transaction_amount | decimal(12,2) | Transaction value (INR) |
| payment_method | string | Debit Card / Credit Card / etc |
| transaction_channel | string | ATM / Mobile App / POS / Online |
| device_type | string | iOS / Android / ATM Machine / POS Terminal |
| transaction_status | string | Success / Failed / Pending |
| is_international | int | 1=international, 0=domestic |
| fraud_flag | int | 1=fraud, 0=legit |
| fraud_reason | string | Reason flagged (if fraud) |
| merchant_risk_level | string | Low / Medium / High |
| merchant_category | string | Travel / Grocery / Ecommerce / etc |
| customer_state | string | Customer's state |
| customer_city | string | Customer's city |
| merchant_state | string | Merchant's state |
| merchant_city | string | Merchant's city |

### dim_customer (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| customer_key | string | Primary key |
| customer_name | string | Full name |
| gender | string | M / F |
| age | int | Age in years |
| marital_status | string | Single / Married |
| occupation | string | Job title |
| annual_income | int | Yearly income (INR) |
| customer_segment | string | Premium / Regular / etc |
| state | string | State |
| city | string | City |
| account_type | string | Savings / Current |
| customer_since | date | Onboarding date |

### dim_card (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| card_key | string | Primary key |
| customer_key | string | FK → dim_customer |
| card_type | string | Credit / Debit |
| credit_limit | decimal(12,2) | Card limit |
| card_status | string | Active / Blocked / Expired |
| card_network | string | Visa / Mastercard / RuPay |
| issue_date | date | Card issue date |
| expiry_date | date | Card expiry |

### dim_merchant (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| merchant_key | string | Primary key |
| merchant_name | string | Business name |
| state | string | State |
| city | string | City |
| merchant_risk_level | string | Low / Medium / High |
| merchant_rating | decimal | Rating |
| merchant_status | string | Active / Inactive |
| merchant_since | date | Onboarding date |

### dim_date (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| date | date | Calendar date |
| date_key | int | Primary key (yyyyMMdd) |
| year | int | Year |
| quarter | int | Quarter (1-4) |
| month | int | Month (1-12) |
| month_name | string | January, February... |
| week | int | Week of year |
| day | int | Day of month |
| weekday | string | Monday, Tuesday... |
| is_weekend | int | 1=weekend, 0=weekday |
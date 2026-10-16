-- ============================================================
-- Finance Fraud Pipeline — Business Analytics Queries
-- Data source: Gold-layer star schema (Databricks Unity Catalog)
-- Tables used: fact_transactions, dim_customer, dim_card,
--              dim_merchant, dim_date
-- Author: Atharv  Wavare
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- Q1: Overall Fraud Baseline
-- Business Question: How much fraud do we have overall?
-- Result: 13,473 fraud txns / 250,000 total (5.39% fraud rate)
--         Total fraud amount: ₹1,05,22,00,974.24
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(*)                                                              AS total_transactions,
    SUM(fraud_flag)                                                       AS fraud_transactions,
    ROUND(100.0 * SUM(fraud_flag) / COUNT(*), 2)                          AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END), 2) AS total_fraud_amount,
    ROUND(AVG(CASE WHEN fraud_flag = 1 THEN transaction_amount END), 2)   AS avg_fraud_amount
FROM fact_transactions;


-- ────────────────────────────────────────────────────────────
-- Q2: Fraud by Merchant Category
-- Business Question: Which merchant categories are riskiest?
-- Insight: Hospital, Hotel, Airline, Travel have highest fraud amount
-- ────────────────────────────────────────────────────────────
SELECT
    merchant_category,
    COUNT(*)                                                              AS total_txns,
    SUM(fraud_flag)                                                       AS fraud_txns,
    ROUND(100.0 * SUM(fraud_flag) / COUNT(*), 2)                          AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END), 2) AS fraud_amount
FROM fact_transactions
GROUP BY merchant_category
ORDER BY fraud_amount DESC;


-- ────────────────────────────────────────────────────────────
-- Q3: Fraud by Customer State (uses star schema join)
-- Business Question: Which states have the highest fraud activity?
-- Insight: Uttar Pradesh, Telangana, Gujarat lead
-- ────────────────────────────────────────────────────────────
SELECT
    c.state,
    COUNT(*)                                                              AS total_txns,
    SUM(f.fraud_flag)                                                     AS fraud_txns,
    ROUND(100.0 * SUM(f.fraud_flag) / COUNT(*), 2)                        AS fraud_rate_pct
FROM fact_transactions f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.state
ORDER BY fraud_txns DESC
LIMIT 10;


-- ────────────────────────────────────────────────────────────
-- Q4: Fraud by Card Type (uses star schema join)
-- Business Question: Are certain card tiers more fraud-prone?
-- Insight: Platinum (5.57%) > Gold (5.39%) > Classic (5.38%) > Silver (5.28%)
-- ────────────────────────────────────────────────────────────
SELECT
    ca.card_type,
    COUNT(*)                                                              AS total_txns,
    SUM(f.fraud_flag)                                                     AS fraud_txns,
    ROUND(100.0 * SUM(f.fraud_flag) / COUNT(*), 2)                        AS fraud_rate_pct
FROM fact_transactions f
JOIN dim_card ca ON f.card_key = ca.card_key
GROUP BY ca.card_type
ORDER BY fraud_rate_pct DESC;


-- ────────────────────────────────────────────────────────────
-- Q5: Fraud by Transaction Channel
-- Business Question: Which channel has the most fraud?
-- Insight: Mobile App (5.56%) slightly higher than POS (5.29%)
-- ────────────────────────────────────────────────────────────
SELECT
    transaction_channel,
    COUNT(*)                                                              AS total_txns,
    SUM(fraud_flag)                                                       AS fraud_txns,
    ROUND(100.0 * SUM(fraud_flag) / COUNT(*), 2)                          AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END), 2) AS fraud_amount
FROM fact_transactions
GROUP BY transaction_channel
ORDER BY fraud_rate_pct DESC;


-- ────────────────────────────────────────────────────────────
-- Q6: Time-of-Day Fraud Patterns
-- Business Question: What hours are fraudsters most active?
-- Insight: Midnight (hour 0) is the peak fraud hour (5.80%)
-- ────────────────────────────────────────────────────────────
SELECT
    HOUR(transaction_time)                                                AS hour_of_day,
    COUNT(*)                                                              AS total_txns,
    SUM(fraud_flag)                                                       AS fraud_txns,
    ROUND(100.0 * SUM(fraud_flag) / COUNT(*), 2)                          AS fraud_rate_pct
FROM fact_transactions
GROUP BY HOUR(transaction_time)
ORDER BY fraud_rate_pct DESC
LIMIT 10;


-- ────────────────────────────────────────────────────────────
-- Q7: International vs Domestic Fraud
-- Business Question: Is international fraud more frequent?
-- Insight: 19.69% fraud rate international vs 4.63% domestic — 4x higher!
-- ────────────────────────────────────────────────────────────
SELECT
    CASE WHEN is_international = 1 THEN 'International' ELSE 'Domestic' END AS txn_type,
    COUNT(*)                                                              AS total_txns,
    SUM(fraud_flag)                                                       AS fraud_txns,
    ROUND(100.0 * SUM(fraud_flag) / COUNT(*), 2)                          AS fraud_rate_pct,
    ROUND(AVG(transaction_amount), 2)                                     AS avg_amount
FROM fact_transactions
GROUP BY is_international;


-- ────────────────────────────────────────────────────────────
-- Q8: Fraud Reasons Breakdown
-- Business Question: What are the top reasons flagged for fraud?
-- Insight: 'Expired Card' most frequent; 'High amount vs limit' highest ₹ impact
-- ────────────────────────────────────────────────────────────
SELECT
    fraud_reason,
    COUNT(*)                                                              AS occurrences,
    ROUND(SUM(transaction_amount), 2)                                     AS total_amount
FROM fact_transactions
WHERE fraud_flag = 1 AND fraud_reason IS NOT NULL
GROUP BY fraud_reason
ORDER BY occurrences DESC;


-- ────────────────────────────────────────────────────────────
-- Q9: Top 10 Fraudulent Merchants (uses star schema join)
-- Business Question: Which merchants have the highest fraud amount?
-- Insight: Max Healthcare leads at ₹1 crore; mix of Low/Medium/High risk
-- ────────────────────────────────────────────────────────────
SELECT
    m.merchant_name,
    m.city,
    m.merchant_risk_level,
    COUNT(*)                                                              AS fraud_txns,
    ROUND(SUM(f.transaction_amount), 2)                                   AS total_fraud_amount
FROM fact_transactions f
JOIN dim_merchant m ON f.merchant_key = m.merchant_key
WHERE f.fraud_flag = 1
GROUP BY m.merchant_name, m.city, m.merchant_risk_level
ORDER BY total_fraud_amount DESC
LIMIT 10;


-- ────────────────────────────────────────────────────────────
-- Q10: Month-over-Month Fraud Trend (uses dim_date)
-- Business Question: Is fraud increasing or decreasing over time?
-- Insight: Stable ~5-6% rate; volume grows through 2026
-- ────────────────────────────────────────────────────────────
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*)                                                              AS total_txns,
    SUM(f.fraud_flag)                                                     AS fraud_txns,
    ROUND(100.0 * SUM(f.fraud_flag) / COUNT(*), 2)                        AS fraud_rate_pct
FROM fact_transactions f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ────────────────────────────────────────────────────────────
-- Q11: High-Risk Merchant Validation
-- Business Question: Do merchants flagged 'High' risk actually have more fraud?
-- ────────────────────────────────────────────────────────────
SELECT
    merchant_risk_level,
    COUNT(*)                                                              AS total_txns,
    SUM(fraud_flag)                                                       AS fraud_txns,
    ROUND(100.0 * SUM(fraud_flag) / COUNT(*), 2)                          AS fraud_rate_pct
FROM fact_transactions
GROUP BY merchant_risk_level
ORDER BY fraud_rate_pct DESC;


-- ────────────────────────────────────────────────────────────
-- Q12: Customer Segment × Fraud (uses dim_customer)
-- Business Question: Which customer segments are most affected?
-- ────────────────────────────────────────────────────────────
SELECT
    c.customer_segment,
    COUNT(*)                                                              AS total_txns,
    SUM(f.fraud_flag)                                                     AS fraud_txns,
    ROUND(100.0 * SUM(f.fraud_flag) / COUNT(*), 2)                        AS fraud_rate_pct,
    ROUND(AVG(c.annual_income), 0)                                        AS avg_income
FROM fact_transactions f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.customer_segment
ORDER BY fraud_rate_pct DESC;
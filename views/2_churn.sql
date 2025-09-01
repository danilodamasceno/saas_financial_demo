CREATE OR REPLACE VIEW ANALYTICS.V_MONTHLY_CHURN_SIMPLE AS
WITH plan_prices_norm AS (
  SELECT
    PLAN_ID,
    PRODUCT_NAME,
    CASE LOWER(INTERVAL)
      WHEN 'month' THEN UNIT_AMOUNT/100
      WHEN 'year'  THEN (UNIT_AMOUNT/100.0)/12
      WHEN 'week'  THEN (UNIT_AMOUNT/100.0)*52/12
      WHEN 'day'   THEN (UNIT_AMOUNT/100.0)*365/12
      ELSE UNIT_AMOUNT/100
    END AS mrr_usd
  FROM PLAN_PRICES
),
churn_rows AS (
  SELECT
    DATE_TRUNC('month', s.CANCEL_DATE) AS month_start,
    s.SUBSCRIPTION_ID,
    pp.product_name,
    pp.mrr_usd
  FROM SUBSCRIPTIONS s
  JOIN plan_prices_norm pp
    ON pp.PLAN_ID = s.PLAN_ID
  WHERE s.CANCEL_DATE IS NOT NULL
)
SELECT
  am.month_start,
  c.product_name,
  COALESCE(COUNT(DISTINCT c.SUBSCRIPTION_ID), 0) AS churned_subscriptions,
  COALESCE(SUM(c.mrr_usd), 0)                  AS churned_mrr_usd
FROM ANALYTICS.ALL_MONTHS am
LEFT JOIN churn_rows c
  ON c.month_start = am.month_start
WHERE am.month_start <= '2025-07-01'
GROUP BY 1,2
ORDER BY 1;

CREATE OR REPLACE VIEW ANALYTICS.V_MRR_CASH_CHURN_MONTHLY AS
WITH base AS (
  SELECT
    m.month_start,
    m.mrr_usd,
    m.product_name,
    c.churned_subscriptions,
    c.churned_mrr_usd,
    -- previous mrr
    LAG(m.mrr_usd) OVER (PARTITION BY m.product_name ORDER BY m.month_start) AS prev_mrr_usd
  FROM ANALYTICS.V_MRR_AND_CASH_MONTHLY m
  LEFT JOIN ANALYTICS.V_MONTHLY_CHURN_SIMPLE c
    ON c.month_start = m.month_start and c.product_name = m.product_name
)
SELECT
  month_start,
  mrr_usd,
  product_name,
  COALESCE(churned_subscriptions, 0) AS churned_subscriptions,
  COALESCE(churned_mrr_usd, 0)      AS churned_mrr_usd,
  CASE
    WHEN COALESCE(prev_mrr_usd, 0) > 0
      THEN ROUND(COALESCE(churned_mrr_usd, 0) / prev_mrr_usd, 4)
    ELSE NULL
  END AS gross_churn_pct
FROM base
ORDER BY month_start;

select month_start, sum(churned_mrr_usd) as churned_mrr_usd  from V_MONTHLY_CHURN_SIMPLE group by 1; 

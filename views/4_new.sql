CREATE OR REPLACE VIEW ANALYTICS.V_NEW_MRR_MONTHLY AS
WITH plan_prices_norm AS (
  SELECT
    PLAN_ID,
    PRODUCT_NAME,
    CASE LOWER(INTERVAL)
      WHEN 'month' THEN UNIT_AMOUNT/100
      WHEN 'year'  THEN (UNIT_AMOUNT/100.0)/12
      WHEN 'week'  THEN (UNIT_AMOUNT/100.0)*52.0/12
      WHEN 'day'   THEN (UNIT_AMOUNT/100.0)*365.0/12
      ELSE UNIT_AMOUNT/100
    END AS mrr_usd
  FROM PLAN_PRICES
)
SELECT
  am.month_start,
  pp.product_name,
  SUM(pp.mrr_usd) AS new_mrr_usd
FROM ANALYTICS.ALL_MONTHS am
JOIN SUBSCRIPTIONS s ON DATE_TRUNC('month', s.START_DATE) = am.month_start
JOIN plan_prices_norm pp ON pp.PLAN_ID = s.PLAN_ID
WHERE am.month_start <= '2025-07-01'
GROUP BY 1,2
ORDER BY 1;

select month_start, sum(new_mrr_usd) as new_mrr_usd from V_NEW_MRR_MONTHLY group by 1;

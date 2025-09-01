CREATE OR REPLACE VIEW ANALYTICS.V_MRR_BY_MARKETING_MONTHLY AS
WITH plan_prices_norm AS (
  SELECT
    PLAN_ID,
    CASE LOWER(INTERVAL)
      WHEN 'month' THEN UNIT_AMOUNT/100.0
      WHEN 'year'  THEN (UNIT_AMOUNT/100.0)/12
      WHEN 'week'  THEN (UNIT_AMOUNT/100.0)*52/12
      WHEN 'day'   THEN (UNIT_AMOUNT/100.0)*365/12
      ELSE UNIT_AMOUNT/100.0
    END AS mrr_usd
  FROM PLAN_PRICES
),
subs_active AS (
  SELECT
    am.month_start,
    s.customer_id,
    s.subscription_id,
    s.plan_id
  FROM ANALYTICS.ALL_MONTHS am
  JOIN SUBSCRIPTIONS s
    ON s.start_date <= am.month_end
   AND (s.cancel_date IS NULL OR s.cancel_date >= am.month_start)
),
subs_with_mrr AS (
  SELECT
    sa.month_start,
    sa.customer_id,
    sa.subscription_id,
    pp.mrr_usd
  FROM subs_active sa
  JOIN plan_prices_norm pp
    ON pp.plan_id = sa.plan_id
),
subs_with_utm AS (
  SELECT
    sm.month_start,
    sm.customer_id,
    sm.mrr_usd,
    u.utm_source,
    u.utm_campaign
  FROM subs_with_mrr sm
  LEFT JOIN UTM_SOURCES u
    ON u.customer_id = sm.customer_id
)
SELECT
  month_start,
  COALESCE(utm_source, 'unknown')  AS utm_source,
  COALESCE(utm_campaign, 'unknown') AS utm_campaign,
  SUM(mrr_usd)                     AS mrr_usd
FROM subs_with_utm
WHERE month_start <= '2025-07-01'
GROUP BY 1,2,3
ORDER BY 1,2,3;

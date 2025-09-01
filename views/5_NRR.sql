CREATE OR REPLACE VIEW ANALYTICS.V_NRR_MONTHLY AS
WITH base AS (
  SELECT
    m.month_start,
    m.mrr_usd,
    LAG(m.mrr_usd) OVER (ORDER BY m.month_start) AS prev_mrr_usd,
    COALESCE(c.churned_mrr_usd, 0) AS churned_mrr_usd,
    COALESCE(n.new_mrr_usd, 0)     AS new_mrr_usd
  FROM (select month_start, sum(mrr_usd) as mrr_usd from V_MRR_AND_CASH_MONTHLY group by 1) as m
  LEFT JOIN (select month_start, sum(churned_mrr_usd) as churned_mrr_usd  from V_MONTHLY_CHURN_SIMPLE group by 1) c
    ON c.month_start = m.month_start
  LEFT JOIN (select month_start, sum(new_mrr_usd) as new_mrr_usd from V_NEW_MRR_MONTHLY group by 1) n
    ON n.month_start = m.month_start
),
calc AS (
  SELECT
    month_start,
    prev_mrr_usd,
    churned_mrr_usd,
    new_mrr_usd,
    (mrr_usd - prev_mrr_usd)                   AS delta_total_mrr,
    (mrr_usd - prev_mrr_usd) - new_mrr_usd     AS net_change_existing_mrr
  FROM base
),
scored AS (
  SELECT
    month_start,
    prev_mrr_usd,
    churned_mrr_usd,
    new_mrr_usd,
    net_change_existing_mrr,
    CASE
      WHEN COALESCE(prev_mrr_usd,0) > 0
        THEN (prev_mrr_usd - churned_mrr_usd + net_change_existing_mrr) / prev_mrr_usd
      ELSE NULL
    END AS nrr_raw
  FROM calc
)
SELECT
  month_start,
  prev_mrr_usd,
  churned_mrr_usd,
  new_mrr_usd,
  net_change_existing_mrr,
  /* clamp: NRR mínimo = 0 */
  CASE
    WHEN nrr_raw IS NULL THEN NULL
    ELSE ROUND(GREATEST(nrr_raw, 0), 4)
  END AS nrr_ratio
FROM scored
ORDER BY month_start;

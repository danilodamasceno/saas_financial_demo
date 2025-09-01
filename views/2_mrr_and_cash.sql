CREATE OR REPLACE VIEW ANALYTICS.V_MRR_AND_CASH_MONTHLY AS
WITH plan_prices_norm AS (
    SELECT
        PLAN_ID,
        PRODUCT_NAME,
        CASE LOWER(INTERVAL)
            WHEN 'month' THEN UNIT_AMOUNT/100
            WHEN 'year'  THEN (UNIT_AMOUNT/100)/12
            WHEN 'week'  THEN (UNIT_AMOUNT/100)*52/12
            WHEN 'day'   THEN (UNIT_AMOUNT/100)*365/12
            ELSE UNIT_AMOUNT/100
        END AS mrr_usd
    FROM PLAN_PRICES
),
mrr AS (
    SELECT
        am.month_start,
        pp.product_name,
        SUM(pp.mrr_usd) AS mrr_usd
    FROM ANALYTICS.ALL_MONTHS am
    JOIN SUBSCRIPTIONS s
      ON s.start_date <= am.month_end
     AND (s.cancel_date IS NULL OR s.cancel_date >= am.month_start)
    JOIN plan_prices_norm pp
      ON pp.plan_id = s.plan_id
    WHERE am.month_start <= '2025-07-01'
    GROUP BY am.month_start,pp.product_name
),
cash AS (
    SELECT
        DATE_TRUNC('month', i.PAID_DATE) AS month_start,
        pp.product_name,
        SUM(i.AMOUNT_PAID)/100.0         AS cash_collected_usd
    FROM INVOICES i
    INNER JOIN SUBSCRIPTIONS s on s.subscription_id = i.subscription_id
    INNER JOIN PLAN_PRICES pp on pp.plan_id = s.plan_id
    WHERE i.STATUS = 'paid'
      AND i.PAID_DATE IS NOT  NULL
    GROUP BY 1,2
)
SELECT
    c_subs_montlhy.month_start,
    c_subs_montlhy.product_name,
    COALESCE(m.mrr_usd, 0)          AS mrr_usd,
    COALESCE(m.mrr_usd, 0) * 12     AS arr_usd,
    COALESCE(c.cash_collected_usd,0) AS cash_collected_usd
FROM ANALYTICS.CUSTOMERS_AND_SUBSCRIPTIONS_MONTHLY c_subs_montlhy
LEFT JOIN mrr  m ON m.month_start = c_subs_montlhy.month_start and m.product_name = c_subs_montlhy.product_name
LEFT JOIN cash c ON c.month_start = c_subs_montlhy.month_start and c.product_name = c_subs_montlhy.product_name
WHERE c_subs_montlhy.month_start <= '2025-07-01'
ORDER BY c_subs_montlhy.month_start;

select * from V_MRR_AND_CASH_MONTHLY

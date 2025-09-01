CREATE OR REPLACE VIEW ANALYTICS.ALL_MONTHS AS
WITH months AS (
    SELECT
        DATEADD(
            month,
            ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1,
            DATE '2023-01-01'
        ) AS month_start
    FROM TABLE(GENERATOR(ROWCOUNT => 32)) 
)
SELECT
    month_start,
    LAST_DAY(month_start) AS month_end,
    TO_CHAR(month_start, 'YYYY-MM') AS month_key
FROM months;

CREATE OR REPLACE VIEW ANALYTICS.CUSTOMERS_AND_SUBSCRIPTIONS_MONTHLY AS
SELECT
    ALL_MONTHS.month_start,   
    pp.product_name,
    COUNT(DISTINCT s.customer_id) AS active_customers,
    COUNT(DISTINCT s.subscription_id) AS active_subscriptions
FROM ANALYTICS.ALL_MONTHS 
LEFT JOIN SUBSCRIPTIONS s ON s.start_date <= ALL_MONTHS.month_end
INNER JOIN PLAN_PRICES pp ON pp.plan_id = s.plan_id
 AND (s.cancel_date IS NULL OR s.cancel_date >= ALL_MONTHS.month_start)
WHERE ALL_MONTHS.month_start <= '2025-07-01'
GROUP BY 1,2
ORDER BY 1;

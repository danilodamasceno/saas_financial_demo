CREATE OR REPLACE VIEW ANALYTICS.V_INVOICES_AGING_MONTHLY AS
SELECT
  DATE_TRUNC('month', i.due_date) AS month_start,
  CASE 
    WHEN i.days_past_due = 0 OR i.is_past_due = FALSE THEN 'On time'
    WHEN i.days_past_due BETWEEN 1  AND 30  THEN '1–30 days'
    WHEN i.days_past_due BETWEEN 31 AND 60  THEN '31–60 days'
    WHEN i.days_past_due BETWEEN 61 AND 90  THEN '61–90 days'
    WHEN i.days_past_due > 90               THEN '90+ days'
    ELSE 'Unknown'
  END AS aging_bucket,
  COUNT(*)                         AS invoices_count,
  SUM(i.amount_due)/100.0          AS total_due_usd
FROM INVOICES i
WHERE i.status <> 'paid'
and i.due_date < '2025-08-01'
GROUP BY 1,2
ORDER BY 1,2;

select * from V_INVOICES_AGING_MONTHLY;

CREATE OR REPLACE VIEW ANALYTICS.V_CHARGE_SUCCESS_RATE AS
SELECT
  DATE_TRUNC('month', c.created)   AS month_start,
  COUNT(*)                         AS total_attempts,
  COUNT_IF(c.status = 'succeeded') AS succeeded_attempts,
  COUNT_IF(c.status = 'failed')    AS failed_attempts,
  ROUND(COUNT_IF(c.status = 'succeeded') / NULLIF(COUNT(*),0), 4) AS success_rate
FROM CHARGES c
WHERE c.created < '2025-08-01'
GROUP BY 1
ORDER BY 1;

select * from V_CHARGE_SUCCESS_RATE;

CREATE OR REPLACE VIEW ANALYTICS.V_DELINQUENCY_RATE_MONTHLY AS
SELECT
  am.month_start,
  SUM(CASE WHEN i.status <> 'paid' AND i.due_date < CURRENT_DATE THEN i.amount_due ELSE 0 END)/100.0 AS overdue_usd,
  SUM(i.amount_due)/100.0 AS total_billed_usd,
  CASE WHEN SUM(i.amount_due) > 0
       THEN ROUND(SUM(CASE WHEN i.status <> 'paid' AND i.due_date < CURRENT_DATE THEN i.amount_due ELSE 0 END)
                  / SUM(i.amount_due),4)
       ELSE NULL END AS delinquency_pct
FROM ANALYTICS.ALL_MONTHS am
LEFT JOIN INVOICES i
  ON DATE_TRUNC('month', i.due_date) = am.month_start
WHERE am.month_start < '2025-08-01'
GROUP BY 1
ORDER BY 1;

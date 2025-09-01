CREATE OR REPLACE VIEW FINANCIAL_METRICS AS 
SELECT c_subs.*,
mrr.mrr_usd, mrr.arr_usd, mrr.cash_collected_usd,
new.new_mrr_usd,
churn.churned_subscriptions, churn.churned_mrr_usd, coalesce(churn.gross_churn_pct,0) as gross_churn_pct,
nrr.nrr_ratio as nrr_ratio_company_month
FROM CUSTOMERS_AND_SUBSCRIPTIONS_MONTHLY c_subs
LEFT JOIN V_MRR_AND_CASH_MONTHLY mrr ON c_subs.month_start = mrr.month_start and c_subs.product_name = mrr.product_name
LEFT JOIN V_MRR_CASH_CHURN_MONTHLY churn on c_subs.month_start = churn.month_start and c_subs.product_name = churn.product_name
LEFT JOIN V_NEW_MRR_MONTHLY new on c_subs.month_start = new.month_start and c_subs.product_name = new.product_name
LEFT JOIN V_NRR_MONTHLY nrr on c_subs.month_start = nrr.month_start
order by 1 asc

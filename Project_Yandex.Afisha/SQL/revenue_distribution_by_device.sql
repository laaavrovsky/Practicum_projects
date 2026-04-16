WITH set_config_precode AS (
  SELECT set_config('synchronize_seqscans', 'off', true)
)
SELECT 
    device_type_canonical, 
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    AVG(revenue) AS avg_revenue_per_order,
    ROUND(SUM(revenue)::numeric / (SELECT SUM(revenue)::numeric 
                                   FROM afisha.purchases 
                                   WHERE currency_code = 'rub'), 3) AS revenue_share
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY device_type_canonical
ORDER BY revenue_share DESC;

-- Задача: Для заказов в рублях вычислите распределение выручки и количества заказов по типу устройства device_type_canonical. Результат должен включать поля:
-- тип устройства device_type_canonical;
-- общая выручка с заказов total_revenue;
-- количество заказов total_orders;
-- средняя стоимость заказа avg_revenue_per_order;
-- доля выручки для каждого устройства от общего значения revenue_share, округлённая до трёх знаков после точки.
--Результат отсортируйте по убыванию значения в поле revenue_share.

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

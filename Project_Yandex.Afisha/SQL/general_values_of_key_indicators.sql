-- Задача: Вычислите общие значения ключевых показателей сервиса за весь период:
-- общая выручка с заказов total_revenue;
-- количество заказов total_orders;
-- средняя выручка заказа avg_revenue_per_order;
-- общее число уникальных клиентов total_users.
-- Значения посчитайте в разрезе каждой валюты (поле currency_code). Результат отсортируйте по убыванию значения в поле total_revenue.
SELECT currency_code, 
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT(user_id)) AS total_users
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_revenue DESC;

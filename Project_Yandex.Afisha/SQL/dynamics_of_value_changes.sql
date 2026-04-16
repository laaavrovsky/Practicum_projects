-- Задача: Для заказов в рублях вычислите изменение выручки, количества заказов, уникальных клиентов и средней стоимости одного заказа в недельной динамике. Результат должен включать поля:
-- неделя week;
-- суммарная выручка total_revenue;
-- число заказов total_orders;
-- уникальное число клиентов total_users;
-- средняя стоимость одного заказа revenue_per_order, разделите суммарную выручку на число заказов.
-- Результат отсортируйте по возрастанию значения в поле week.

SELECT DATE_TRUNC('week', created_dt_msk)::date AS week, 
       SUM(revenue) AS total_revenue, 
       COUNT(order_id) AS total_orders,
       COUNT(DISTINCT(user_id)) AS total_users,
       SUM(revenue)/COUNT(order_id) AS revenue_per_order
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY week
ORDER BY week;

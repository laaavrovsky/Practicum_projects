-- Для заказов в рублях вычислите распределение количества заказов и их выручку в зависимости от типа мероприятия event_type_main. Результат должен включать поля:
-- тип мероприятия event_type_main;
-- общая выручка с заказов total_revenue;
-- количество заказов total_orders;
-- средняя стоимость заказа avg_revenue_per_order;
-- уникальное число событий total_event_name (по их коду event_name_code);
-- среднее число билетов в заказе avg_tickets;
-- средняя выручка с одного билета avg_ticket_revenue;
-- доля выручки от общего значения revenue_share, округлённая до трёх знаков после точки.
-- Результат отсортируйте по убыванию значения в поле total_orders.

SELECT event_type_main, 
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT event_name_code) AS total_event_name,
       AVG(tickets_count) AS avg_tickets,
       SUM(revenue)/SUM(tickets_count) AS avg_ticket_revenue,
       ROUND((SUM(revenue) / (SELECT SUM(revenue) FROM afisha.purchases WHERE currency_code = 'rub'))::numeric, 3) AS revenue_share
FROM afisha.purchases AS p 
JOIN afisha.events AS e ON p.event_id = e.event_id
WHERE currency_code = 'rub'
GROUP BY event_type_main
ORDER BY total_orders DESC

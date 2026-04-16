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

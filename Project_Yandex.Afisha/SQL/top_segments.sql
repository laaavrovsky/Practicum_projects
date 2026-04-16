SELECT region_name,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       COUNT(DISTINCT user_id) AS total_users,
       SUM(tickets_count) AS total_tickets,
       SUM(revenue)/SUM(tickets_count) AS one_ticket_cost
FROM afisha.purchases AS p 
JOIN afisha.events AS e ON p.event_id = e.event_id
JOIN afisha.city AS c ON e.city_id = c.city_id 
JOIN afisha.regions AS r ON c.region_id = r.region_id
WHERE currency_code = 'rub'
GROUP BY region_name
ORDER BY total_revenue DESC
LIMIT 7;

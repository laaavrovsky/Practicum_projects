SELECT currency_code, 
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT(user_id)) AS total_users
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_revenue DESC

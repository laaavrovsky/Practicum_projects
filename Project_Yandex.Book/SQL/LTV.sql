-- Задача: по имеющимся данным рассчитайте средние LTV, за все время, для пользователей в Москве и Санкт-Петербурге и сравните их между собой. Для расчёта среднего LTV используйте формулу: общий доход / количество пользователей. Выведите в результате запроса общее количество пользователей в каждом городе и их средний LTV.
-- В результат должны войти следующие поля:
-- city — название города или региона (данные из поля usage_geo_id_name);
-- total_users — суммарное количество пользователей в городе или регионе;
-- ltv — средний LTV пользователей в городе или регионе.Округлите до двух знаков после запятой.

WITH user_months AS (
    SELECT DISTINCT
        ba.puid,
        bg.usage_geo_id_name AS city,
        DATE_TRUNC('month', ba.msk_business_dt_str) AS month
    FROM bookmate.audition ba
    JOIN bookmate.geo bg
        ON ba.usage_geo_id = bg.usage_geo_id
    WHERE bg.usage_geo_id_name IN ('Москва', 'Санкт-Петербург')
),

user_revenue AS (
    SELECT
        puid,
        city,
        COUNT(month) * 399 AS revenue
    FROM user_months
    GROUP BY puid, city
)

SELECT
    city,
    COUNT(puid) AS total_users,
    ROUND(SUM(revenue) * 1.0 / COUNT(puid), 2) AS ltv
FROM user_revenue
GROUP BY city;

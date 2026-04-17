-- Задача: рассчитайте среднюю выручку прослушанного часа вместе с MAU и суммой прослушанных часов с сентября по ноябрь. В результат должны войти следующие поля:
-- month — месяц активности (первое число месяца в формате YYYY-MM-DD);
-- mau — значение MAU;
-- hours — общее количество прослушанных часов (вычисляется по полю hours). Округлите до двух знаков после запятой;
-- avg_hour_rev — средняя выручка от часа чтения или прослушивания. Округлите до двух знаков после запятой.

SELECT DATE_TRUNC('month', msk_business_dt_str)::date AS month,
        COUNT(DISTINCT puid) AS mau,
        ROUND(SUM(hours), 2) AS hours,
        ROUND(COUNT(DISTINCT puid)*399/SUM(hours), 2) AS avg_hour_rev
FROM bookmate.audition
WHERE DATE_TRUNC('month', msk_business_dt_str) >= '2024-09-01'::date AND DATE_TRUNC('month', msk_business_dt_str) <= '2024-11-30'::date
GROUP BY month

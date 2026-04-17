-- Задача: рассчитайте ежедневный Retention Rate пользователей до конца представленных данных. Выведите следующие поля:
-- day_since_install — срок жизни пользователя в днях;
-- retained_users — количество пользователей, которые вернулись в приложение в конкретный день;
-- retention_rate — коэффициент удержания для вернувшихся пользователей по отношению к общему числу пользователей, которые установили приложение. В оконной функции при расчете Retention Rate в знаменателе используйте функцию MAX() для подсчета размера исходной когорты (общего числа пользователей). Округлите до двух знаков после запятой.
-- Отсортируйте результат по сроку жизни в порядке возрастания.

WITH cohort AS (
    SELECT DISTINCT puid
    FROM bookmate.audition
    WHERE msk_business_dt_str = DATE '2024-12-02'
),

user_activity AS (
    SELECT
        a.puid,
        a.msk_business_dt_str,
        a.msk_business_dt_str - DATE '2024-12-02' AS day_since_install
    FROM bookmate.audition a
    JOIN cohort c
        ON a.puid = c.puid
    WHERE a.msk_business_dt_str >= DATE '2024-12-02'
),

retention AS (
    SELECT
        day_since_install,
        COUNT(DISTINCT puid) AS retained_users
    FROM user_activity
    GROUP BY day_since_install
)

SELECT
    day_since_install,
    retained_users,
    ROUND(
        retained_users * 1.0 /
        MAX(retained_users) OVER (),
        2
    ) AS retention_rate
FROM retention
ORDER BY day_since_install;

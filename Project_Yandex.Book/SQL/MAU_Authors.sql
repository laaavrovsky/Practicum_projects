-- Задача: расчёт MAU. Здесь MAU будет определяться как количество уникальных пользователей в месяц, которые читали или слушали конкретного автора. Выведите имена топ-3 авторов с наибольшим MAU в ноябре и сами значения MAU.
-- В результат должны войти следующие поля:
-- main_author_name — имя автора контента;
-- mau — значение MAU.
-- Отсортируйте результат по значению MAU в порядке убывания.

SELECT a.main_author_name,
       COUNT(DISTINCT au.puid) AS mau
FROM bookmate.audition AS au
JOIN bookmate.content AS c ON au.main_content_id = c.main_content_id
JOIN bookmate.author AS a ON c.main_author_id = a.main_author_id
WHERE EXTRACT('month' FROM au.msk_business_dt_str) = 11
GROUP BY a.main_author_name
ORDER BY mau DESC
LIMIT 3;

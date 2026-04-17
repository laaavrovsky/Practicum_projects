-- Задача: рассчитайте MAU произведений. Выведите имена топ-3 произведений с наибольшим MAU в ноябре, а также списки жанров этих произведений, их авторов и сами значения MAU.
-- В результат должны войти следующие поля:
-- main_content_name — название произведения, или контента;
-- published_topic_title_list — список жанров контента;
-- main_author_name — имя автора контента;
-- mau — значение MAU.
-- Отсортируйте результат по значению MAU в порядке убывания.

SELECT c.main_content_name,
       c.published_topic_title_list,
       a.main_author_name,
       COUNT(DISTINCT au.puid) AS mau
FROM bookmate.audition AS au
JOIN bookmate.content AS c ON au.main_content_id = c.main_content_id
JOIN bookmate.author AS a ON c.main_author_id = a.main_author_id
WHERE EXTRACT('month' FROM au.msk_business_dt_str) = 11
GROUP BY c.main_content_name, c.published_topic_title_list, a.main_author_name
ORDER BY mau DESC
LIMIT 3;

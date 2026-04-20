-- Задача: Разделите объявления на категории по количеству дней активности: 
-- 1-30 days — около одного месяца;
-- 31-90 days — от одного до трёх месяцев;
-- 91-180 days — от трёх месяцев до полугода;
-- 181+ days — более полугода
-- Объявления, которые не были сняты с продажи, объедините в категорию non category. 
-- Для каждой категории изучите количество продаваемых квартир, а также их параметры, включая среднюю стоимость квадратного метра, среднюю площадь недвижимости, количество комнат и балконов. Сравните объявления Санкт-Петербурга и городов Ленинградской области.
--При работе с данными используйте только объявления о продаже недвижимости в городах за 2015–2018 годы включительно.

-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats AS f
    JOIN real_estate.type t ON f.type_id = t.type_id
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
            AND t.type = 'город' -- Добавил фильтрацию по типу населенного пункта как во второй задаче.
),
-- Создаю CTE для разделения на категории по количеству дней размещения.
date_category AS (
    SELECT *,
    	  CASE
    	  	  WHEN days_exposition > 0 AND days_exposition <=30
    	  	  THEN 'около одного месяца'
    	  	  WHEN days_exposition >= 31 AND days_exposition <=90
    	  	  THEN 'от одного до трёх месяцев'
    	  	  WHEN days_exposition >= 91 AND days_exposition <=180
    	  	  THEN 'от трёх месяцев до полугода'
    	  	  WHEN days_exposition >= 181 
    	  	  THEN 'более полугода'
    	  	  ELSE 'non category'
    	  END AS d_category
    FROM real_estate.advertisement
    WHERE EXTRACT(YEAR FROM first_day_exposition) BETWEEN 2015 AND 2018
    ),
    -- Создаю CTE для разделения на категории по городам.
    city_category AS (
    SELECT *,
    	  CASE
    	  	  WHEN city_id = '6X8I'
    	  	  THEN 'Санкт-Петербург'
    	  	  ELSE 'Ленинградская область'
    	  END AS c_category
    FROM real_estate.city
    )
    -- Основной запрос
    SELECT dt.d_category,
	   cc.c_category,
	   COUNT(fi.id) AS total_advertisement,
	   ROUND(AVG(dt.last_price/NULLIF(fi.total_area, 0))::INTEGER, 2) AS avg_price_per_sqm,
	   ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fi.total_area)::integer, 2) AS median_total_area,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fi.rooms)::integer, 1) AS median_rooms,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fi.balcony)::integer, 1) AS median_balcony
FROM real_estate.flats AS fi
JOIN date_category AS dt ON dt.id = fi.id 
JOIN city_category AS cc ON cc.city_id = fi.city_id 
WHERE fi.id IN (SELECT * FROM filtered_id)
GROUP BY dt.d_category, cc.c_category 
ORDER BY cc.c_category DESC, total_advertisement DESC

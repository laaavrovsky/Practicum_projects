-- Задача: Заказчику важно понять сезонные тенденции на рынке недвижимости всего региона, включая объекты недвижимости Санкт-Петербурга и Ленинградской области, продаваемые в городах. 
-- Для исследования объявлений по периодам используйте дату публикации объявления и дату снятия объявления с публикации: можно считать, что снятие объявления часто происходит при продаже недвижимости. В качестве единицы периода используйте месяц — это позволит выявить сезонные колебания активности. 
-- При работе с данными используйте только объявления о продаже недвижимости в городах за полные годы — в датасете это 2015–2018 годы. Это позволит избежать искажений из-за неполных лет. 

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
    SELECT *
    FROM real_estate.flats AS f
    -- Присоединил таблицу для дальнейшей фильтрации по типу населенного пункта
    JOIN real_estate.type t ON f.type_id = t.type_id 
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
            AND t.type = 'город' -- добавил фильтр
    ),
    -- рассчитал показатели для даты первой публикации
    first_month_exposition_stat AS (
    SELECT EXTRACT(MONTH FROM first_day_exposition) AS month,
    	   COUNT(a.id) AS first_total_advertisement,
    	   ROUND(AVG(a.last_price/NULLIF(f.total_area, 0))::INTEGER, 2) AS first_avg_price_per_sqm,
    	   ROUND(AVG(f.total_area)::integer, 2) AS first_avg_total_area
    FROM real_estate.advertisement AS a 
    JOIN filtered_id  AS f ON f.id = a.id 
    WHERE EXTRACT(YEAR FROM first_day_exposition) BETWEEN 2015 AND 2018
    GROUP BY month
    ORDER BY month
    ),
    -- рассчитал показатели для даты снятия объявления
    last_month_exposition_stat AS (
    SELECT EXTRACT(MONTH FROM (first_day_exposition + INTERVAL '1 day' * days_exposition)) AS month,
    	   COUNT(a.id) AS last_total_advertisement,
    	   ROUND(AVG(a.last_price/NULLIF(f.total_area, 0))::INTEGER, 2) AS last_avg_price_per_sqm,
    	   ROUND(AVG(f.total_area)::integer, 2) AS last_avg_total_area
    FROM real_estate.advertisement AS a 
    JOIN filtered_id AS f ON f.id = a.id 
    WHERE a.days_exposition IS NOT NULL 
    	  AND EXTRACT(YEAR FROM first_day_exposition) BETWEEN 2015 AND 2018
    GROUP BY month
    ORDER BY month
   )
   SELECT *
   FROM first_month_exposition_stat AS fm 
   JOIN last_month_exposition_stat AS lm ON lm.MONTH = fm.MONTH

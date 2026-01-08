/*
 * OLIST E-COMMERCE ANALYSIS
 * -------------------------
 * Author: Anatoly Konoshonok
 * Database: PostgreSQL
 * Description: Ключевые метрики продаж, логистики и качества сервиса.
 */

-- 1. ДИНАМИКА ВЫРУЧКИ ПО МЕСЯЦАМ
-- Бизнес-вопрос: Как меняется объем продаж во времени? Есть ли сезонность?
SELECT 
	DATE_TRUNC('month', o.order_purchase_timestamp)::date as month, 
	ROUND(SUM(oi.price), 2) as total_revenue
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id 
WHERE o.order_status='delivered'
GROUP BY 1
ORDER BY 1;

-- 2. ДНИ С НАИБОЛЬШЕЙ ВЫРУЧКОЙ (ПИКИ ПРОДАЖ)
-- Бизнес-вопрос: В какие конкретные даты мы заработали больше всего? (например, Черная Пятница)
SELECT 
	DATE_TRUNC('day', o.order_purchase_timestamp)::date as day, 
	ROUND(SUM(oi.price), 2) as total_revenue
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id 
WHERE o.order_status='delivered'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 3. СРЕДНИЙ ЧЕК (AOV)
-- Бизнес-вопрос: Сколько в среднем тратит клиент за один заказ?
SELECT 
	DATE_TRUNC('month', o.order_purchase_timestamp)::date as month,
	ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) as aov
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id 
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- 4. ТОП-5 КАТЕГОРИЙ ПО ВЫРУЧКЕ
-- Бизнес-вопрос: Какие категории являются драйверами роста?
SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi 
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN category_translation ct ON p.product_category_name = ct.product_category_name 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. ГЕОГРАФИЯ ПРОДАЖ: ЛИДЕРЫ И АУТСАЙДЕРЫ
-- Бизнес-вопрос: Какие штаты приносят больше/меньше всего денег?
(
    SELECT
        'Top 5' AS ranking_type,
        c.customer_state AS state, 
        ROUND(SUM(oi.price), 2) AS total_revenue
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id 
    INNER JOIN customers c ON o.customer_id = c.customer_id 
    WHERE o.order_status = 'delivered'
    GROUP BY 2
    ORDER BY 3 DESC
    LIMIT 5
)
UNION ALL
(
    SELECT 
        'Bottom 5' AS ranking_type,
        c.customer_state AS state, 
        ROUND(SUM(oi.price), 2) AS total_revenue
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id 
    INNER JOIN customers c ON o.customer_id = c.customer_id 
    WHERE o.order_status = 'delivered'
    GROUP BY 2
    ORDER BY 3 ASC
    LIMIT 5
)
ORDER BY ranking_type DESC, total_revenue DESC;

-- 6. КАТЕГОРИИ С ВЫСОКИМ РЕЙТИНГОМ
-- Бизнес-вопрос: В каких категориях клиенты наиболее довольны?
-- (Включен фильтр: минимум 30 заказов, чтобы исключить статистический шум)
SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(r.review_score), 2) AS average_score,
    COUNT(r.review_id) AS reviews_count
FROM order_items oi
INNER JOIN order_reviews r ON oi.order_id = r.order_id 
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN category_translation ct ON p.product_category_name = ct.product_category_name 
GROUP BY 1 
HAVING COUNT(r.review_id) > 30 
ORDER BY 2 DESC
LIMIT 5;

-- 7. ШТАТЫ С ВЫСОКИМ РЕЙТИНГОМ
-- Бизнес-вопрос: В каких штатах клиенты наиболее довольны?
-- (Включен фильтр: минимум 30 заказов, чтобы исключить статистический шум)
SELECT
	c.customer_state as state,
	ROUND(AVG(r.review_score), 2) as average_score
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id 
INNER JOIN order_reviews r ON o.order_id = r.order_id 
GROUP BY 1
HAVING COUNT(r.review_id) > 30 
ORDER BY 2 DESC
LIMIT 5;

-- 8. ШТАТЫ С НИЗКИМ РЕЙТИНГОМ
-- Бизнес-вопрос: В каких штатах клиенты наименее довольны?
-- (Включен фильтр: минимум 50 заказов, чтобы исключить статистический шум)
SELECT
	c.customer_state as state,
	ROUND(AVG(r.review_score), 2) as average_score
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id 
INNER JOIN order_reviews r ON o.order_id = r.order_id 
GROUP BY 1
HAVING COUNT(r.review_id) > 30 
ORDER BY 2
LIMIT 5;

-- 9. ЭФФЕКТИВНОСТЬ ДОСТАВКИ
-- Бизнес-вопрос: Какая доля заказов доставляется вовремя и с опозданием?
SELECT
    CASE 
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NOT NULL
GROUP BY 1;
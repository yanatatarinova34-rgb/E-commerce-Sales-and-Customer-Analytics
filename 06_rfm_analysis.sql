-- RFM анализ. Recency - сколько дней прошло с последней покупки, Frequency - количество Completed-заказов, Monetary - Completed-выручка.
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.quantity * oi.price), 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id
),
rfm AS (
    SELECT
        customer_id,
        CAST(julianday('2025-01-01') - julianday(last_purchase_date) AS INTEGER) AS recency,
        frequency,
        monetary
    FROM customer_metrics
)
SELECT *
FROM rfm
ORDER BY monetary DESC;

-- rfm сегментация
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        CAST(
            julianday('2025-01-01') - julianday(MAX(o.order_date)) AS INTEGER) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.quantity * oi.price), 2 ) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM customer_metrics
)
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score
FROM rfm_scores
ORDER BY monetary DESC;

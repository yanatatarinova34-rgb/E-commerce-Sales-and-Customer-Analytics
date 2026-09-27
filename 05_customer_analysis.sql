with customer_order as (
						select c.customer_id,
						count(o.order_id) as orders_count
						from customers c
						left join orders o on c.customer_id = o.customer_id
						group by c.customer_id),
	customer_revenue as (
						select co.customer_id,
						co.orders_count,
						coalesce(sum(case
										when o.status = 'Completed' then oi.quantity * oi.price
										else 0
						end), 0) as completed_revenue						
						 from customer_order co
						 left join orders o on co.customer_id = o.customer_id
						 left join order_items oi on o.order_id = oi.order_id
						 group by co.customer_id, co.orders_count)		
select
    case
        when orders_count = 1 then 'Один заказ'
        else 'Повторный покупатель'
    end as customer_type,
    count(*) as customers_count,
    round(sum(completed_revenue), 2) as total_completed_revenue,
    round(avg(completed_revenue), 2) as avg_revenue_per_customer
from customer_revenue
where orders_count >= 1
group by customer_type
order by total_completed_revenue desc; 
--  разница между средней выручкой повторного покупателя и у клиента с одним заказом 40,3 рублей, общая выручка по 
-- сегментам покупателей 23 607 тыс 
-- посмотрю по датам 
select c.customer_id, 
min(o.order_date) as first_date,
max(o.order_date) as last_date, 
count(distinct o.order_id) as completed_orders
from customers c 
left join orders o on o.customer_id = c.customer_id
where o.status = 'Completed'
group by c.customer_id
order by first_date;
--
select c.customer_id, 
min(o.order_date) as first_date,
max(o.order_date) as last_date, 
count(distinct o.order_id) as completed_orders,
round(julianday(max(o.order_date)) - julianday(min(o.order_date)), 0) as difference_day
from customers c 
left join orders o on o.customer_id = c.customer_id
where o.status = 'Completed'
group by c.customer_id
order by first_date; -- посмотрели разницу 

with customer_activity as (
    						select c.customer_id,
        					count(distinct o.order_id) as completed_orders,
        					round(julianday(max(o.order_date)) - julianday(min(o.order_date)), 0) as customer_lifetime_days
    						from customers c
    						join orders o on c.customer_id = o.customer_id
    						where o.status = 'Completed'     
    						group by c.customer_id)
select
    case
        when completed_orders = 1 then 'Один заказ'
        else 'Повторный покупатель'
    end as customer_type,
    count(*) as customers_count,
    round(avg(customer_lifetime_days), 2) as avg_lifetime_days,
    min(customer_lifetime_days) as min_lifetime_days,
    max(customer_lifetime_days) as max_lifetime_days
from customer_activity
group by customer_type
order by avg_lifetime_days desc;with customer_order as (
						select c.customer_id,
						count(o.order_id) as orders_count
						from customers c
						left join orders o on c.customer_id = o.customer_id
						group by c.customer_id),
	customer_revenue as (
						select co.customer_id,
						co.orders_count,
						coalesce(sum(case
										when o.status = 'Completed' then oi.quantity * oi.price
										else 0
						end), 0) as completed_revenue						
						 from customer_order co
						 left join orders o on co.customer_id = o.customer_id
						 left join order_items oi on o.order_id = oi.order_id
						 group by co.customer_id, co.orders_count)		
select
    case
        when orders_count = 1 then 'Один заказ'
        else 'Повторный покупатель'
    end as customer_type,
    count(*) as customers_count,
    round(sum(completed_revenue), 2) as total_completed_revenue,
    round(avg(completed_revenue), 2) as avg_revenue_per_customer
from customer_revenue
where orders_count >= 1
group by customer_type
order by total_completed_revenue desc; 
--  разница между средней выручкой повторного покупателя и у клиента с одним заказом 40,3 рублей, общая выручка по 
-- сегментам покупателей 23 607 тыс 
-- посмотрю по датам 
select c.customer_id, 
min(o.order_date) as first_date,
max(o.order_date) as last_date, 
count(distinct o.order_id) as completed_orders
from customers c 
left join orders o on o.customer_id = c.customer_id
where o.status = 'Completed'
group by c.customer_id
order by first_date;
--
select c.customer_id, 
min(o.order_date) as first_date,
max(o.order_date) as last_date, 
count(distinct o.order_id) as completed_orders,
round(julianday(max(o.order_date)) - julianday(min(o.order_date)), 0) as difference_day
from customers c 
left join orders o on o.customer_id = c.customer_id
where o.status = 'Completed'
group by c.customer_id
order by first_date; -- посмотрели разницу 

with customer_activity as (
    						select c.customer_id,
        					count(distinct o.order_id) as completed_orders,
        					round(julianday(max(o.order_date)) - julianday(min(o.order_date)), 0) as customer_lifetime_days
    						from customers c
    						join orders o on c.customer_id = o.customer_id
    						where o.status = 'Completed'     
    						group by c.customer_id)
select
    case
        when completed_orders = 1 then 'Один заказ'
        else 'Повторный покупатель'
    end as customer_type,
    count(*) as customers_count,
    round(avg(customer_lifetime_days), 2) as avg_lifetime_days,
    min(customer_lifetime_days) as min_lifetime_days,
    max(customer_lifetime_days) as max_lifetime_days
from customer_activity
group by customer_type
order by avg_lifetime_days desc;
-- ценность клиентов
select
    c.customer_id,
    count(distinct o.order_id) as completed_orders,
    sum(oi.quantity) as units_sold,
    round(sum(oi.quantity * oi.price), 2) as revenue,
    round(sum(oi.quantity * oi.price) / count(distinct o.order_id), 2) as avg_order_value,
    min(o.order_date) AS first_purchase_date,
    max(o.order_date) AS last_purchase_date
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
where o.status = 'Completed'
group by c.customer_id
order by revenue desc;
-- TOP-клиентов
select 
    c.customer_id,
    count(distinct o.order_id) as completed_orders,
    round(sum(oi.quantity * oi.price), 2) as revenue
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
where o.status = 'Completed'
group by c.customer_id
order by revenue desc
limit 10;

-- доля выручки повторных покупателей 
WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT CASE
            WHEN o.status = 'Completed'
            THEN o.order_id
        END) AS completed_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),

customer_revenue AS (
    SELECT
        co.customer_id,
        co.completed_orders,

        COALESCE(
            SUM(
                CASE
                    WHEN o.status = 'Completed'
                    THEN oi.quantity * oi.price
                    ELSE 0
                END
            ),
            0
        ) AS revenue

    FROM customer_orders co

    LEFT JOIN orders o
        ON co.customer_id = o.customer_id

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        co.customer_id,
        co.completed_orders
)

SELECT
    CASE
        WHEN completed_orders = 1
            THEN 'Один заказ'
        WHEN completed_orders >= 2
            THEN 'Повторный покупатель'
        ELSE 'Нет заказов'
    END AS customer_type,

    COUNT(*) AS customers_count,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue) * 100.0 /
        SUM(SUM(revenue)) OVER (),
        2
    ) AS revenue_share_pct

FROM customer_revenue

GROUP BY customer_type
ORDER BY total_revenue DESC;

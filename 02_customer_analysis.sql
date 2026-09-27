-- разделим покупателей на новых\разовых и повторных
select c.customer_id, count(o.order_id) as order_count,
CASE 
	when count(o.order_id) = 0 then 'Нет заказов'
	when count(o.order_id) = 1 then 'Один заказ'
	else 'Повторный покупатель'
END AS customer_type
from customers c 
left join orders o on c.customer_id = o.customer_id
group by c.customer_id 
order by order_count desc;
-- получим итоговую структуру клиентской базы
with customer_orders as (
select c.customer_id, count(o.order_id) as orders_count
from customers c 
left join orders o on c.customer_id = o.customer_id 
group by c.customer_id
)
SELECT
CASE 
	when orders_count = 0 then 'Нет заказов'
	when orders_count = 1 then 'Один заказ'
	else 'Повторный покупатель'
END AS customer_type, 
count(*) as customers_count
from customer_orders
group by customer_type 
order by customers_count desc;
-- сколько заказов в среднем приходится на одного клиента в каждом сегменте?
with customer_orders as (
							select c.customer_id,
							count(o.order_id) as orders_count
							from customers c 
							left join orders o on c.customer_id = o.customer_id
							group by c.customer_id
							)
							select round(avg(orders_count), 2) as avg_orders_per_repeat_customer,
							min(orders_count) as min_orders,
							max(orders_count) as max_orders
							from customer_orders 
							where orders_count >= 2;
-- среди клиентов которые совершили 2 и более заказа среднее кол-во 3.91
-- какую долю всей выручки приносят повторные покупатели? (не включаем клиентов без заказов)
with customer_orders as (
    select
        c.customer_id,
        COUNT(o.order_id) as orders_count
    from customers c
    left join orders o on c.customer_id = o.customer_id
    group by c.customer_id
),
customer_revenue as (
    select
        co.customer_id,
        co.orders_count,
        COALESCE(SUM(oi.quantity * oi.price), 0) as revenue
    from customer_orders co
    left join orders o on co.customer_id = o.customer_id
    left join order_items oi on o.order_id = oi.order_id
    group by co.customer_id, co.orders_count
)
select
    case
        when orders_count = 1 then 'Один заказ'
        else 'Повторный покупатель'
    end as customer_type,
    count(*) as customer_count,
    round(sum(revenue), 2) as total_revenue,
    round(avg(revenue), 2) as avg_revenue_per_customer
from customer_revenue
where orders_count >= 1         
group by customer_type
order by total_revenue desc;
-- повторные покупатели дают 30374 из 32954 общей выручки. Средняя выручка на одного повторного покупателя - 123.47, против 66,15 у клиента
-- с одним заказом
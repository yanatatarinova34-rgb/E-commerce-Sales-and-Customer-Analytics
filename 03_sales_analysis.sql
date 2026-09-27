-- общие KPI ПРОЕКТА
select
    count(distinct case
        when o.status = 'Completed' then o.order_id
    end) as completed_orders,
    sum(case
        when o.status = 'Completed' then oi.quantity
        else 0
    end) as units_sold,
    round(
        sum(case
            when o.status = 'Completed' then oi.quantity * oi.price
            else 0
        end), 2
    ) as revenue,
    round(
        sum(case
            when o.status = 'Completed' then oi.quantity * oi.price
            else 0
        end)  / count(distinct case
            when o.status = 'Completed' then o.order_id
        end),
        2
    ) as avg_order_value,
    count(distinct o.customer_id) as customers_with_orders
from orders o
join order_items oi on o.order_id = oi.order_id;

-- посчитаю выручку только по комплитед
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
        COALESCE(sum(case
                    when o.status = 'Completed' then oi.quantity * oi.price
                    else 0
                end), 0) as completed_revenue
    from customer_orders co
    left join orders o on co.customer_id = o.customer_id
    left join order_items oi on o.order_id = oi.order_id
    group by co.customer_id, co.orders_count
)
select
    count(*) AS repeat_customers,
    round(sum(completed_revenue), 2) as total_completed_revenue,
    round(avg(completed_revenue), 2) as avg_revenue_per_repeat_customer
from customer_revenue
where orders_count >= 2; 
-- получилась чистая выручка по комплитед, то есть после исключения ретурнед и кэнселед средняя вырчука снизилась до 106, 45 

-- как менялись основные показатели продаж в течение 2024 года + средний чек? (смотрю месяц, кол-во уникальных заказов, кол-во проданных штук, выручка)
select 
		STRFTIME('%Y-%m', o.order_date) as month, 
		count(distinct o.order_id) as order_count,
		sum(oi.quantity) as unit_sold, 
		sum(oi.quantity * oi.price) as revenue,
		sum(oi.quantity * oi.price) / count(distinct o.order_id) as avg_order_value
from orders o 
join order_items oi on o.order_id = oi.order_id
group by STRFTIME('%Y-%m', o.order_date)
order by month;

-- рост\снижение выручки месяц к месяцу
with monthly_sales as (
    select
        STRFTIME('%Y-%m', o.order_date) as month,
        round(sum(oi.quantity * oi.price), 2) as revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    where o.status = 'Completed'
    group by STRFTIME('%Y-%m', o.order_date)
)
select
    month,
    revenue,
    LAG(revenue) over (order by month) as previous_month_revenue,
    round((revenue - LAG(revenue) over (order by month)) * 100.0 / LAG(revenue) over (order by month), 2) AS revenue_growth_pct
from monthly_sales
order by month;
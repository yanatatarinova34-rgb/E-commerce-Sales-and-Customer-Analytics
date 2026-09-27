-- продажи по категориям
SELECT 
		p.category,
		count(distinct o.order_id) as orders_count,
		sum(oi.quantity) as units_sold, 
		sum(oi.quantity * oi.price) as revenue
from orders o 
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where o.status = 'Completed'
group by p.category 
order by revenue desc;   
-- body лидер по выручке 8 295 при этом продано 124 единицы, makeup 8149 по выручке и 117 единиц, hair имеет наибольшее кол-во заказов - 41 
-- но по выручке занимает лишь третье место

-- средняя выручка на заказ и средняя цена единицы товара по категориям
select 
		p.category, 
		count(distinct o.order_id) as order_count,
		round(sum(oi.quantity * oi.price),2) as revenue, 
		round(sum(oi.quantity * oi.price) * 1.0 / count(distinct o.order_id), 2) as avg_revenue_per_order
from orders o 
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where o.status = 'Completed'
group by p.category 
order by avg_revenue_per_order desc;
-- кол-во заказов не всегда напрямую определяет выручку: категория make up при меньшем количестве заказов приносит больше выручки, чем 
-- hair, за счет более высокой выручки на один заказ.
-- средняя стоимость одной проданной единицы 
select 
		p.category, 
		sum(oi.quantity) as units_sold,
		round(sum(oi.quantity * oi.price),2) as revenue, 
		round(sum(oi.quantity * oi.price) * 1.0 / count(distinct o.order_id), 2) as avg_revenue_per_order
from orders o 
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where o.status = 'Completed'
group by p.category 
order by avg_revenue_per_order desc;

-- какие товары внутри категорий являются основными источниками выручки 
select 
		p.category,
		p.product_name,
		sum(oi.quantity) as units_sold,
		round(sum(oi.quantity * oi.price),2) as revenue
from orders o 
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where o.status = 'Completed'
group by p.category, p.product_name 
order by p.category, revenue desc;

-- в категории боди основной вклад делают продукты 32, 8, 31, 45. В скин два продукта - 50, 13. А вот мэйкап выглядит более равномерно
-- распределенной: крупнейшие товары дают меньшую долю выручки

-- насколько выручка каждой категории зависит от нескольких ключевых товаров?
select 
		p.category,
		p.product_name,
		round(SUM(oi.quantity * oi.price), 2) as revenue, 
		round(SUM(oi.quantity * oi.price) * 100.0 / SUM(sum(oi.quantity * oi.price)) over (partition by p.category), 2) as revenue_share_pct
from orders o 
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where o.status = 'Completed'
group by p.category, p.product_name
order by p.category, p.product_name desc;

-- концентрация выручки категорий через топ-3
with product_revenue as (
						select 
								p.category,
								p.product_name,
								sum(oi.quantity) as units_sold,
								round(sum(oi.quantity * oi.price),2) as revenue
						from orders o 
						join order_items oi on oi.order_id = o.order_id
						join products p on p.product_id = oi.product_id
						where o.status = 'Completed'
						group by p.category, p.product_name 
						),
	 ranked_categories as (
	 					select 
	 							category,
	 							product_name, 
	 							revenue, 
	 							row_number() over (partition by category order by revenue desc) as product_rank
	 							from product_revenue
	 							),
	category_revenue as (
						select category,
								sum(revenue) as total_revenue
								from product_revenue
								group by category)
	select r.category, 
	round(sum(r.revenue), 2) as top_3_revenue,
	round(sum(r.revenue) * 100.0 / c.total_revenue, 2) as top_3_revenue_share_pct
	from ranked_categories r
	join category_revenue c on r.category = c.category
	where product_rank <= 3
	group by r.category
	order by top_3_revenue desc;
	-- Skin самая концентрированная категория, где топ-3 товара формируют 63.66% выручки. Body топ-3 дают 50.61%. Makeup 38.41%. Hair 34.53%.
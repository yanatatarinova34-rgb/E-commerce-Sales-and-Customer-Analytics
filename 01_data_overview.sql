-- сколько клиентов?
SELECT COUNT(*) AS customers_count
FROM customers c ;
-- сколько заказов?
SELECT COUNT(*) AS orders_count
FROM orders o ;
-- сколько товаров?
SELECT COUNT(*) AS product_count
FROM products p ;
-- сколько позиций товаров было заказано?
SELECT COUNT(*) AS order_items_count
FROM order_items oi ;
-- сколько заказов сделал каждый клиент?
SELECT c.customer_id, count(o.order_id) as orders_count
from customers c 
left join orders o on o.customer_id = c.customer_id
group by c.customer_id 
order by orders_count desc;
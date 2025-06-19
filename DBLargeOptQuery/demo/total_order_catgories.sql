select c."name", count(oi.order_id) as total_order from products p 
join categories c on p.category_id = c.id
join order_items oi on p.id = oi.product_id
join orders o on o.id = oi.order_id
group by c."name" 

select c."name", count(oi.order_id) as total_order from products p 
join categories c on p.category_id = c.id
join order_items oi on p.id = oi.product_id
where exists (
	select 1 
	from orders o 
	where o.id = oi.order_id
)
group by c."name" 
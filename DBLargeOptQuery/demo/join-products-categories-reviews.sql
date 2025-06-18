select p.*, c.name, r.*  from products p 
join categories c on p.category_id = c.id
join reviews r  on p.id = r.product_id
where p.price > 10.5;

/*
                        [1] Nested Loop
                          /            \
               [2] Hash Join         [6] Memoize
                 /        \              \
     [3] Seq Scan    [4] Hash         [7] Index Scan
     on reviews         /             on categories (id = p.category_id)
                [5] Seq Scan
            on products (price > 10.5)

*/
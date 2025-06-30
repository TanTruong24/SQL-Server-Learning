##  **CÂU HỎI SQL NÂNG CAO (DẠNG TỰ LUẬN + TRUY VẤN THỰC TẾ)**

###  SẢN PHẨM VÀ DANH MỤC

1. **Tìm danh sách sản phẩm không có trong bất kỳ đơn hàng nào.**
   ```sql
   select p.* from products p 
   where p.id not in (
      select oi.product_id from order_items oi 
   );
   ```
   -> Có thể chậm với bảng lớn do dùng NOT IN. Trong thực tế, bạn nên dùng ```LEFT JOIN ... IS NULL``` để tối ưu
   ```sql
   select p.* from products p
   left join order_items oi on p.id = oi.product_id
   where oi.product_id is null;
   ```

2. **Liệt kê 5 sản phẩm có tỉ lệ đánh giá 5 sao cao nhất trên tổng số đánh giá.**
   ```sql
   select 
      p.id, 
      p.name,
      count(case when r.rating = 5 then 1 end) * 1.0 / count (r.id) as five_star_ratio
   from products p 
   join reviews r on r.product_id = p.id
   group by (p.id, p.name)
   order by five_star_ratio desc
   ```
   `CASE WHEN` trong SQL:

   **Cú pháp cơ bản**

   ```sql
   CASE 
   WHEN điều_kiện_1 THEN giá_trị_1
   WHEN điều_kiện_2 THEN giá_trị_2
   ...
   ELSE giá_trị_mặc_định
   END
   ```

   * `SELECT`: hiển thị giá trị điều kiện
   * `WHERE`, `ORDER BY`, `GROUP BY`, `UPDATE`, `HAVING`: xử lý logic nâng cao

   * Luôn kết thúc `CASE` bằng `END`
   * Các giá trị `THEN` nên cùng kiểu dữ liệu

3. **Tính trung bình giá sản phẩm theo từng danh mục, và sắp xếp giảm dần.**
   ```sql
   select c.*, avg(p.price) as avg_price from categories c 
   join products p on p.category_id = c.id
   group by(c.id)
   order by avg_price desc
   ```
4. **Tìm sản phẩm có trong cả wishlist lẫn được mua nhiều nhất trong tháng gần nhất.**
   ```sql
   select p.id, p.name, p.price, count(*) as count_purchase 
   from products p 
   join order_items oi on oi.product_id = p.id
   join orders o on o.id = oi.order_id
   where 
      p.id in (select w.product_id from wishlists w )
      and  Date_trunc('month', o.order_date ) = (
         select date_trunc('month', max(order_date)) from orders
         )
   group by p.id, p.name
   order by count_purchase desc
   limit 1

   --CREATE INDEX idx_order_date_month ON orders (order_date);
   --CREATE INDEX idx_oi_product_id ON order_items (product_id);
   --CREATE INDEX idx_wishlist_product_id ON wishlists (product_id);
   ```

   ```
   [Limit]
   │
   └── [Result]
      │
      └── [Limit]
         │
         └── [Index Only Scan] on orders
               (điều kiện: order_date IS NOT NULL)
               │
               └── [Sort]
                  │
                  └── [Aggregate] (Group By)
                     │
                     └── [Sort]
                           │
                           └── [Nested Loop]
                              │
                              ├── [Nested Loop]
                              │   │
                              │   ├── [Hash Join]
                              │   │   ├── [Seq Scan] on order_items
                              │   │   └── [Hash]
                              │   │       └── [Seq Scan] on orders
                              │   │           (điều kiện: date_trunc('month', order_date) = ...)
                              │   │
                              │   └── [Index Scan] on products
                              │       (id = oi.product_id)
                              │
                              └── [Index Only Scan] on wishlists
                                 (product_id = oi.product_id)
   ```
   
   | Bước | Node Type (Plan)                 | Ý nghĩa / Tác vụ thực thi                                                        |
   | ---- | -------------------------------- | -------------------------------------------------------------------------------- |
   | ①    | `Index Only Scan` on `orders`    | Thực thi **subquery**: `SELECT DATE_TRUNC('month', MAX(order_date)) FROM orders` |
   | ②    | `Seq Scan` on `orders`           | Quét toàn bộ `orders` để lọc theo `WHERE date_trunc(...) = ...`                  |
   | ③    | `Seq Scan` on `order_items`      | Quét toàn bộ `order_items` để JOIN với `orders` qua `order_id`                   |
   | ④    | `Hash`                           | Tạo bảng băm từ `orders` (từ bước ②) để hỗ trợ `Hash Join`                       |
   | ⑤    | `Hash Join`                      | Thực hiện `JOIN orders o ON o.id = oi.order_id`                                  |
   | ⑥    | `Index Scan` on `products`       | Tìm `products` phù hợp với `oi.product_id`                                       |
   | ⑦    | `Nested Loop`                    | JOIN `products` với kết quả JOIN `orders + order_items`                          |
   | ⑧    | `Index Only Scan` on `wishlists` | Thực thi điều kiện `p.id IN (SELECT product_id FROM wishlists)`                  |
   | ⑨    | `Nested Loop`                    | Áp dụng kết quả lọc `wishlists` vào kết quả JOIN trước đó                        |
   | ⑩    | `Aggregate` (Group + COUNT)      | Gom nhóm theo `p.id, p.name`, đếm số lần xuất hiện (`count(*)`)                  |
   | ⑪    | `Sort`                           | Sắp xếp kết quả theo `count_purchase DESC`                                       |
   | ⑫    | `Limit`                          | Trả về 1 dòng đầu tiên sau khi sắp xếp (`LIMIT 1`)                               |


   Diễn giải từng bước
   ```
   [Subquery: MAX(order_date)] → lọc orders
   ↓
   [JOIN orders + order_items] → Hash Join
   ↓
   [JOIN với products] → Index Scan + Nested Loop
   ↓
   [Filter by wishlists] → Index Only Scan + Nested Loop
   ↓
   [GROUP BY + COUNT]
   ↓
   [Sort DESC]
   ↓
   [Limit 1]
   ```

5. **Liệt kê các sản phẩm không có đánh giá nào nhưng có trong wishlist.**
   ```sql
   select p.* from products p 
   where p.id not in (
      select r.product_id from reviews r
      ) 
   and p.id in (
      select w.product_id from wishlists w
      )
   ```
   => `NOT IN` có thể gây lỗi nếu có `NULL` trong `reviews`.`product_id` và hiệu năng chậm nếu dữ liệu lớn.
   
   - Khi nào NOT IN gây lỗi?
   NOT IN sẽ không trả về kết quả đúng nếu tập con có chứa NULL — bởi vì trong SQL logic:
   ```sql
   x NOT IN (1, 2, NULL)
   ```
   → luôn trả về UNKNOWN → không có dòng nào được chọn, vì SQL không biết so sánh `x != NULL`.

   **Tại sao người ta vẫn tránh dùng NOT IN?**
   - Trong thực tế, nhiều hệ thống không đảm bảo 100% cột không `NULL` nếu không có `NOT NULL` ràng buộc.
   - Nếu có 1 dòng `NULL` trong `reviews.product_id`, câu truy vấn sẽ trả về rỗng, gây lỗi logic khó debug.
   - Nhiều người viết code không kiểm soát chặt schema, dễ dẫn đến bug ngầm. (`reviews.product_id` có thể `NULL`)

   **Tối ưu:**

   - Dùng LEFT JOIN ... IS NULL để kiểm tra không có đánh giá
   ```sql
   SELECT p.* 
   FROM products p
   JOIN wishlists w ON p.id = w.product_id
   LEFT JOIN reviews r ON p.id = r.product_id
   WHERE r.product_id IS NULL;
   ```

   - Dùng NOT EXISTS
   ```sql
   SELECT p.* 
   FROM products p
   WHERE NOT EXISTS (
   SELECT 1 FROM reviews r WHERE r.product_id = p.id
   )
   AND EXISTS (
   SELECT 1 FROM wishlists w WHERE w.product_id = p.id
   );
   ```
   **Vì sao PostgreSQL dùng Index Only Scan cho bảng reviews?**

   1. Điều kiện trong `NOT EXISTS`:
   ```sql
   SELECT 1 FROM reviews r WHERE r.product_id = p.id
   ```

   - Truy vấn con chỉ dùng reviews.product_id (không SELECT *, không filter phức tạp)
   - PostgreSQL phát hiện:
      - Cột product_id đã có index
      - Truy vấn không cần truy cập heap → chỉ cần xem index đã đủ xác nhận

   → Vì vậy, PostgreSQL chọn Index Only Scan để tránh đọc dữ liệu thực trong bảng (heap), giúp:
   - Ít I/O hơn
   - Thời gian nhanh hơn
   - Memory footprint thấp hơn

   **Điều kiện để PostgreSQL chọn được Index Only Scan**

   - Cột sử dụng trong SELECT và WHERE nằm trong index
   - Không cần truy cập heap (PostgreSQL đã biết tuple vẫn còn hợp lệ — thông qua visibility map)

   Ví dụ: nếu bạn có index này:
   ```sql
   CREATE INDEX idx_reviews_product_id ON reviews(product_id);
   ```
   Thì PostgreSQL sẽ tận dụng tốt cho Index Only Scan.

---

### KHÁCH HÀNG

6. **Tìm khách hàng chưa từng mua hàng, nhưng đã thêm vào wishlist.**
   ```sql
   select distinct  c.*
   from customers c 
   join wishlists w on w.customer_id = c.id 
   left join orders o on o.customer_id = c.id
   where o.customer_id is null
   ```

7. **Tính tuổi đời tài khoản trung bình của những khách hàng đã từng mua ít nhất 3 đơn.**
   ```sql
   select avg(current_date - c.created_at) as avg_acc_age
   from customers c 
   where exists (
      select 1 from orders o
      where o.customer_id = c.id
      group by (o.customer_id)
      having count(o.customer_id) >= 3
   )
   ```
   => `EXISTS` không cần `GROUP BY`, vì chỉ check điều kiện → nên thay bằng `JOIN` hoặc `IN`.

   ```sql
   -- select avg(AGE(CURRENT_DATE, c.created_at)) as avg_acc_age
   select avg(CURRENT_DATE - c.created_at) as avg_acc_age
   from customers c 
   where c.id in (
      select o.customer_id
      from orders o
      group by o.customer_id
      having count(*) >= 3
   )
   ```
8. **Tìm khách hàng mua hàng bằng ít nhất 2 phương thức thanh toán khác nhau.**
   ```sql
   select c.*
   from customers c 
   where c.id in (
      select o.customer_id
      from orders o
      group by o.customer_id
      having count(distinct o.payment_method_id) >= 2
   )
   ```
9. **Khách hàng nào có tổng chi tiêu cao nhất trong quý gần nhất?**
   ```sql
   select 
	c.*,
	SUM((p.price * oi.quantity) * (1 + pm.fee_percent / 100.0)) AS total_spending
   from customers c 
   join orders o on o.customer_id = c.id
   join payment_methods pm on pm.id = o.payment_method_id
   join order_items oi on oi.order_id  = o.id
   join products p on p.id = oi.product_id
   where extract(quarter from o.order_date) = extract(quarter from current_date)
      and extract(year from o.order_date) = extract(year from current_date)
   group by(c.id)
   order by total_spending desc
   limit 1
   ```

10. **Liệt kê khách hàng mua hàng nhưng chưa từng đánh giá sản phẩm.**
   ```sql
   create index idx_reviews_product_id on reviews (product_id);
   create index idx_orders_customer_id on orders (customer_id);
   create index idx_reviews_customer_id on reviews (customer_id);
   ```

   ```sql
   SELECT c.*
   FROM customers c
   WHERE EXISTS (
      SELECT 1 FROM orders o WHERE o.customer_id = c.id
   )
   AND NOT EXISTS (
      SELECT 1 FROM reviews r WHERE r.customer_id = c.id
   );
   ```

---

### ĐƠN HÀNG VÀ CHI TIẾT ĐƠN

11. **Tính tổng doanh thu mỗi ngày trong 1 tháng gần nhất (bao gồm `quantity * price`).**
   ```sql
   select o.order_date,
		sum(oi.quantity * p.price) as revenue
   from orders o
   join order_items oi on oi.order_id  = o.id
   join products p on p.id = oi.product_id
   where extract(month from o.order_date) = extract(month from current_date)
      and extract(year from o.order_date) = extract(year from current_date)
   group by o.order_date
   order by o.order_date 
   ```
12. **Tìm đơn hàng có nhiều sản phẩm nhất và tổng số tiền cao nhất.**
   ```sql
   select o.*, 
      sum(oi.quantity) as total_product, 
      sum(oi.quantity*p.price) as total_money
   from orders o 
   join order_items oi on oi.order_id = o.id
   join products p on p.id = oi.product_id
   group by o.id
   order by total_product desc, total_money desc
   limit 1
   ```
13. **Tìm các đơn hàng có ít nhất 1 sản phẩm trùng với wishlist của khách hàng đó.**
   ```sql
   select o.*
   from orders o
   join order_items oi on oi.order_id = o.id
   where oi.product_id in (
      select w.product_id
      from wishlists w
      where w.customer_id = o.customer_id
   )
   ```
14. **Tính trung bình số sản phẩm mỗi đơn theo từng khách hàng.**
   ```sql
   select o.customer_id, 
         avg(sub.total_quantity) as avg_product_order
   from (
      select o.id, o.customer_id, sum(oi.quantity) as total_quantity
      from orders o
      join order_items oi on oi.order_id = o.id
      group by o.id, o.customer_id
   ) sub
   group by sub.customer_id
   ```
15. **Tìm đơn hàng có thời gian giao hàng dài nhất so với ngày đặt hàng.**
   ```sql
   select o.*, (s.delivery_date - o.order_date) as time_shipping
   from orders o
   join shippings s on s.order_id = o.id
   order by time_shipping desc
   limit 1
   ```
---

### VẬN CHUYỂN & THANH TOÁN

16. **Thống kê số lượng đơn theo `shipping_status` và phương thức thanh toán.**
   ```sql
   select s.shipping_status, pm.name,  count(*) as quantity_order
   from shippings s 
   join orders o on o.id = s.order_id
   join payment_methods pm on pm.id = o.payment_method_id
   group by s.shipping_status, pm.name
   ```
17. **Tính tổng chi phí vận chuyển theo carrier và theo từng tháng.**
   ```sql
   select c.name, 
		c.code, 
		 TO_CHAR(s.shipped_date, 'YYYY-MM') AS month,
		 sum(s.shipping_cost) as total_cost
   from shippings s 
   join carriers c on c.id = s.carrier_id
   group by c.name, c.code, month
   order by month desc
   ```

   **Lưu ý?**
   - Mặc dù PostgreSQL cho phép, việc dùng alias trong GROUP BY vẫn không được khuyến khích trong code production lớn vì:
   - Dễ gây lỗi khi alias bị đổi tên
   - Không tương thích nếu chuyển DBMS (sang MySQL, SQL Server...)
   - Một số công cụ BI/reporting (như Metabase, Tableau) vẫn gợi ý dùng biểu thức gốc

   ```sql
   select c.name, 
		c.code, 
		 TO_CHAR(s.shipped_date, 'YYYY-MM') AS month,
		 sum(s.shipping_cost) as total_cost
   from shippings s 
   join carriers c on c.id = s.carrier_id
   group by c.name, 
         c.code, 
         TO_CHAR(s.shipped_date, 'YYYY-MM')
   order by month desc
   ```

18. **Tính thời gian giao hàng trung bình theo carrier và nhóm khách hàng.**
   ```sql
   select c.name, 
		c.code,
		cs.name,
		avg(s.delivery_date - s.shipped_date) as avg_delivery
   from shippings s 
   join carriers c on c.id = s.carrier_id
   join orders o on o.id = s.order_id
   join customers cs on cs.id = o.customer_id
   group by c.name, 
         c.code, 
         cs.id,
         cs.name
   order by avg_delivery desc
   ```
   **Nguyên nhân gây chậm**
   - GROUP BY nhiều cột (gồm cả cs.name) → PostgreSQL cần xử lý dữ liệu tạm nhiều hơn
   - AVG(delivery_date - shipped_date) trên nhiều dòng không tối ưu được push-down

   ```sql
   select c.name, 
		c.code,
		cs.name,
		AVG(DATE_PART('day', s.delivery_date - s.shipped_date)) AS avg_days
   from shippings s 
   join carriers c on c.id = s.carrier_id
   join orders o on o.id = s.order_id
   join customers cs on cs.id = o.customer_id
   group by c.name, 
         c.code, 
         cs.id
   order by avg_days desc
   ```

19. **Tìm những đơn hàng giao sai hẹn (giao sau hơn 5 ngày từ order\_date).**
   ```sql
   select     
	o.*, 
    s.delivery_date, 
    DATE_PART('day', s.delivery_date - o.order_date) AS days_diff
   from orders o
   join shippings s on s.order_id = o.id
   where DATE_PART('day', s.delivery_date - o.order_date) > 5
   order by days_diff 
   ```
   
   **Gợi ý mở rộng thêm (tuỳ chọn)**

   a. Tính riêng thời gian xử lý nội bộ và vận chuyển:
   ```sql
   DATE_PART('day', s.shipped_date - o.order_date) AS handling_days,
   DATE_PART('day', s.delivery_date - s.shipped_date) AS shipping_days
   ```
   → Cho phép phân tích:
   - Trễ do khâu nội bộ xử lý (handling_days)
   - Hay do đơn vị vận chuyển (shipping_days)

   ```sql
   SELECT 
    o.id AS order_id,
    o.order_date,
    s.shipped_date,
    s.delivery_date,
    DATE_PART('day', s.delivery_date - o.order_date) AS total_days,
    DATE_PART('day', s.shipped_date - o.order_date) AS handling_days,
    DATE_PART('day', s.delivery_date - s.shipped_date) AS shipping_days
   FROM orders o
   JOIN shippings s ON s.order_id = o.id
   WHERE DATE_PART('day', s.delivery_date - o.order_date) > 5
   ORDER BY total_days ;
   ```

20. **Phân tích xu hướng giao hàng (số đơn trễ, sớm, đúng hạn) theo tuần.**

---

### PHÂN TÍCH CHUYÊN SÂU

21. **Tìm sản phẩm có tỉ lệ hoàn thành vận chuyển thành công > 95%.**
22. **Với mỗi khách hàng, tính trung bình thời gian giao hàng thành công.**
23. **Với mỗi sản phẩm, tính tỉ lệ wishlist/đã mua.**
24. **Tìm top 3 danh mục có tốc độ tăng trưởng đơn hàng nhanh nhất qua từng tháng.**
25. **Tìm những ngày có doanh thu vượt quá trung bình tháng đó ít nhất 30%.**

---

### WINDOW FUNCTION & CTE

26. **Xếp hạng khách hàng theo chi tiêu trong từng tháng (`RANK() OVER PARTITION`).**
27. **Với mỗi đơn hàng, tính phần trăm đóng góp của từng sản phẩm (`quantity * price / total`).**
28. **Tìm khách hàng có đơn hàng liên tiếp mỗi tháng trong 6 tháng gần nhất (dùng `dense_rank`).**
29. **Tìm sản phẩm có xu hướng giảm doanh thu trong 3 tháng gần nhất.**
30. **Dùng CTE để tính số đơn và tổng chi phí giao hàng theo từng tuần.**

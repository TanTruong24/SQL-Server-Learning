`query_optimization_questions.md`** để luyện tập tối ưu truy vấn trong PostgreSQL:

---

# 🧠 DANH SÁCH CÂU HỎI TRUY VẤN TỐI ƯU HÓA (TRUNG BÌNH → NÂNG CAO)

Dựa trên cấu trúc cơ sở dữ liệu gồm các bảng: `categories`, `products`, `orders`, `order_items`, `reviews`.

---

## I. TRUY VẤN DỮ LIỆU TỔNG QUÁT

1. Lấy danh sách các sản phẩm có giá lớn hơn 10.5, gồm các danh mục và đánh giá tương ứng:
   ```sql
      EXPLAIN (ANALYZE, BUFFERS)
      SELECT p.*, c.name, r.*
      FROM products p
      JOIN categories c ON p.category_id = c.id
      JOIN reviews r ON p.id = r.product_id
      WHERE p.price > 10.5;
    ```

   ```
                           [1] Nested Loop
                          /            \
               [2] Hash Join         [6] Memoize
                 /        \              \
     [3] Seq Scan    [4] Hash         [7] Index Scan
     on reviews         /             on categories (id = p.category_id)      /
                
                [5] Seq Scan
            on products (price > 10.5)
   ```

2. Tìm tất cả sản phẩm có `price > 500`, sắp xếp theo giá giảm dần.

3. Lấy 10 đơn hàng mới nhất (gồm tên khách hàng và ngày đặt hàng).

4. Tìm tổng số đơn hàng trong từng tháng (`DATE_TRUNC`).

---

## II. TRUY VẤN TỔNG HỢP VÀ GROUP

5. Tổng số sản phẩm trong từng danh mục (`COUNT`).

6. Danh sách sản phẩm kèm số lần được đặt hàng (`JOIN order_items` + `COUNT`).

7. Sản phẩm nào có rating trung bình cao nhất (`AVG` từ bảng `reviews`).

8. Danh sách đơn hàng có tổng giá trị > 1 triệu:

   ```sql
   SELECT o.id, SUM(p.price * oi.quantity) AS total
   FROM orders o
   JOIN order_items oi ON o.id = oi.order_id
   JOIN products p ON p.id = oi.product_id
   GROUP BY o.id
   HAVING SUM(p.price * oi.quantity) > 1000000;
   ```

9. Tính tổng doanh thu từ đầu đến nay.

---

## III. SUBQUERY & CTE

10. Tìm sản phẩm chưa bao giờ có đơn hàng:

```sql
SELECT * FROM products 
WHERE id NOT IN (SELECT product_id FROM order_items);
```

11. Tìm sản phẩm có rating cao nhất trong mỗi danh mục.

12. Tìm sản phẩm có nhiều lượt đánh giá nhất.

13. Danh sách khách hàng có hơn 5 đơn hàng.

14. Tìm đơn hàng có nhiều hơn 3 sản phẩm.

---

## IV. JOIN PHỨC TẠP / LỒNG NHAU

15. Top 5 khách hàng mua nhiều sản phẩm nhất (theo quantity).
   ```sql
   select c.id, c.name, sum(oi.quantity) as purchase_quantity from customers c 
   join orders o on o.customer_id = c.id
   join order_items oi on oi.order_id = o.id
   group by c.id 
   order by purchase_quantity desc
   limit 5;
   ```
   ```
                              [Limit]             -- LIMIT 5
                              |
                              [Sort]              -- ORDER BY purchase_quantity DESC
                                 |
                              [Aggregate]         -- GROUP BY c.id, SUM(oi.quantity)
                                 |
                              [Hash Join]         -- ON o.customer_id = c.id
                              /           \                  
               [Hash Join]                [Hash]
               /           \                 |
   [Seq Scan] order_items    [Hash]         [Seq Scan] customers
   (oi.order_id = o.id)         |        
                        [Seq Scan] orders         
   ```

16. Sản phẩm tạo ra doanh thu cao nhất.

   - Query có vấn đề?
   ```sql
   select p.*, sum(oi.quantity)*p.price as revenue from products p 
   join order_items oi on oi.product_id = p.id
   group by p.id
   order by revenue desc
   limit 1
   ```

   => Trong PostgreSQL, khi bạn SELECT p.* và GROUP BY p.id, các cột khác của products phải là hàm tổng hợp hoặc nằm trong GROUP BY (trừ khi có GROUP BY p.*, nhưng đó không phải chuẩn ANSI và dễ gây lỗi nếu dùng ORM).
   PostgreSQL sẽ báo lỗi: column "p.name" must appear in the GROUP BY clause or be used in an aggregate function

   ```sql
   SELECT 
    p.id, p.name, p.description, p.price, 
      SUM(oi.quantity) * p.price AS revenue
   FROM products p
   JOIN order_items oi ON oi.product_id = p.id
   GROUP BY p.id, p.name, p.description, p.price
   ORDER BY revenue DESC
   LIMIT 1;
   ```

17. Tổng số đơn hàng cho mỗi danh mục:

   ```sql
   select c."name", count(oi.order_id) as total_order from products p 
   join categories c on p.category_id = c.id
   join order_items oi on p.id = oi.product_id
   where exists (
      select 1 
      from orders o 
      where o.id = oi.order_id
   )
   group by c."name" 
   ```

   ```sql
   select c."name", count(oi.order_id) as total_order from products p 
   join categories c on p.category_id = c.id
   join order_items oi on p.id = oi.product_id
   join orders o on o.id = oi.order_id
   group by c."name" 
   ```

   ```
      [Aggregate]
      |
   [Hash Join]  (oi.order_id = o.id)
      /    \
   [Nested Loop]         [Hash]
      /     \              |
   [Hash Join]        [Seq Scan]
      /    \              orders
   [Seq Scan] [Hash]
   order_items    |
               [Seq Scan]
               products
                  |
               [Memoize]
                     |
               [Index Scan]
                  categories

   ```

18. Tìm tất cả sản phẩm có rating thấp nhất trong hệ thống.

19. Tìm ngày có số đơn hàng nhiều nhất (`GROUP BY DATE(order_date)` + `COUNT`).

---

## V. THỰC HÀNH TỐI ƯU HÓA TRUY VẤN

20. Chạy `EXPLAIN ANALYZE` cho các truy vấn sau:

* Truy vấn có `JOIN` 3 bảng (`orders`, `order_items`, `products`)
* Truy vấn có `NOT IN` hoặc `LEFT JOIN ... IS NULL`
* Truy vấn tính doanh thu theo tháng

**Gợi ý khi phân tích `EXPLAIN ANALYZE`:**

* So sánh `rows planned` và `actual rows`
* Kiểm tra loại Scan: `Seq Scan`, `Index Scan`, `Bitmap Index Scan`
* Tối ưu bằng cách thêm `INDEX` rồi chạy lại để so sánh hiệu suất

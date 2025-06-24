##  **CÂU HỎI SQL NÂNG CAO (DẠNG TỰ LUẬN + TRUY VẤN THỰC TẾ)**

###  SẢN PHẨM VÀ DANH MỤC

1. **Tìm danh sách sản phẩm không có trong bất kỳ đơn hàng nào.**
   ```sql
   select p.* from products p 
   where p.id not in (
      select oi.product_id from order_items oi 
   );
   ```
2. **Liệt kê 5 sản phẩm có tỉ lệ đánh giá 5 sao cao nhất trên tổng số đánh giá.**
   ```sql
   select p.*, count( p.id) as count_rating from products p 
   join reviews r on r.product_id = p.id
   where r.rating = 5
   group by (p.id)
   order by count_rating desc
   limit 5
   ```
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

---

### KHÁCH HÀNG

6. **Tìm khách hàng chưa từng mua hàng, nhưng đã thêm vào wishlist.**
7. **Tính tuổi đời tài khoản trung bình của những khách hàng đã từng mua ít nhất 3 đơn.**
8. **Tìm khách hàng mua hàng bằng ít nhất 2 phương thức thanh toán khác nhau.**
9. **Khách hàng nào có tổng chi tiêu cao nhất trong quý gần nhất?**
10. **Liệt kê khách hàng mua hàng nhưng chưa từng đánh giá sản phẩm.**

---

### ĐƠN HÀNG VÀ CHI TIẾT ĐƠN

11. **Tính tổng doanh thu mỗi ngày trong 1 tháng gần nhất (bao gồm `quantity * price`).**
12. **Tìm đơn hàng có nhiều sản phẩm nhất và tổng số tiền cao nhất.**
13. **Tìm các đơn hàng có ít nhất 1 sản phẩm trùng với wishlist của khách hàng đó.**
14. **Tính trung bình số sản phẩm mỗi đơn theo từng khách hàng.**
15. **Tìm đơn hàng có thời gian giao hàng dài nhất so với ngày đặt hàng.**

---

### VẬN CHUYỂN & THANH TOÁN

16. **Thống kê số lượng đơn theo `shipping_status` và phương thức thanh toán.**
17. **Tính tổng chi phí vận chuyển theo carrier và theo từng tháng.**
18. **Tính thời gian giao hàng trung bình theo carrier và nhóm khách hàng.**
19. **Tìm những đơn hàng giao sai hẹn (giao sau hơn 5 ngày từ order\_date).**
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

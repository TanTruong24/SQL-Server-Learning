`query_optimization_questions.md`** để luyện tập tối ưu truy vấn trong PostgreSQL:

---

# 🧠 DANH SÁCH CÂU HỎI TRUY VẤN TỐI ƯU HÓA (TRUNG BÌNH → NÂNG CAO)

Dựa trên cấu trúc cơ sở dữ liệu gồm các bảng: `categories`, `products`, `orders`, `order_items`, `reviews`.

---

## I. TRUY VẤN DỮ LIỆU TỔNG QUÁT

1. Liệt kê toàn bộ sản phẩm và tên danh mục tương ứng:
   ```sql
   SELECT p.name, c.name 
   FROM products p
   JOIN categories c ON p.category_id = c.id;
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

16. Sản phẩm tạo ra doanh thu cao nhất.

17. Tổng số đơn hàng cho mỗi danh mục:

* Join `products`, `order_items`, `orders`

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

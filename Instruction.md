
## 💡 **Nhóm JOIN – Cách hai bảng được kết nối**

| Thuật ngữ       | Ý nghĩa                                                                      | Khi nào dùng                                           | Ưu / Nhược                               |
| --------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------- |
| **Nested Loop** | Duyệt từng dòng bảng A, và với mỗi dòng đó, đi tìm dòng phù hợp trong bảng B | Khi bảng B nhỏ hoặc có index phù hợp                   | Nhanh với dữ liệu nhỏ, chậm với bảng lớn |
| **Hash Join**   | Tạo bảng băm (hash table) từ bảng nhỏ → dò nhanh bảng lớn                    | Khi `JOIN ON` giữa hai bảng lớn                        | Cân bằng tốt giữa tốc độ và bộ nhớ       |
| **Merge Join**  | Duyệt tuần tự hai bảng đã sắp xếp theo khóa join                             | Khi hai bảng đã `ORDER BY` hoặc có index sẵn theo khóa | Rất nhanh nếu dữ liệu đã sắp             |

---

## 🔍 **Nhóm SCAN – Cách truy xuất dữ liệu từ 1 bảng**

| Thuật ngữ             | Ý nghĩa                                                     | Ưu / Nhược                                                      |
| --------------------- | ----------------------------------------------------------- | --------------------------------------------------------------- |
| **Seq Scan**          | Duyệt toàn bộ bảng (Sequential Scan)                        | Dễ xảy ra khi không có index phù hợp, tốn I/O                   |
| **Index Scan**        | Duyệt bảng theo index (có đọc heap)                         | Nhanh khi có điều kiện lọc, tốn hơn nếu cần nhiều random access |
| **Index Only Scan**   | Chỉ đọc từ index, **không truy cập bảng gốc**               | Rất nhanh, nhưng chỉ khi index chứa đủ dữ liệu cần select       |
| **Bitmap Index Scan** | Quét index theo nhiều điều kiện, sau đó gom lại bằng bitmap | Dùng cho nhiều điều kiện OR hoặc IN                             |

---

## 🧮 **Nhóm TÍNH TOÁN – Gom nhóm, sắp xếp, giới hạn...**

| Thuật ngữ       | Ý nghĩa                                                                    |
| --------------- | -------------------------------------------------------------------------- |
| **Aggregate**   | Thực hiện `SUM()`, `COUNT()`, `AVG()`, `GROUP BY`                          |
| **Sort**        | Thực hiện `ORDER BY`, có thể dùng memory hoặc disk                         |
| **Limit**       | Trả về n dòng đầu tiên (`LIMIT 10`)                                        |
| **Result**      | Kết quả tạm, thường để bao gói kết quả phụ                                 |
| **Materialize** | Cache kết quả trung gian để dùng nhiều lần (dễ thấy với CTE hoặc subquery) |

---

## 📦 **Nhóm KHÁC**

| Thuật ngữ         | Ý nghĩa                                    |
| ----------------- | ------------------------------------------ |
| **Hash**          | Dùng kèm `Hash Join`, lưu bảng tạm để dò   |
| **CTE Scan**      | Quét kết quả từ một `WITH` CTE đã thực thi |
| **Subquery Scan** | Scan dữ liệu từ subquery trong FROM        |

---

## 🔁 Ví dụ mô phỏng (thứ tự thực hiện):

```
Limit
└── Sort
    └── Aggregate (GROUP BY)
        └── Hash Join
            ├── Seq Scan on orders
            └── Index Scan on order_items
```

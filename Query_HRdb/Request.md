## MỨC DỄ – CƠ BẢN VỀ SELECT, WHERE, JOIN (1–10)
1. Liệt kê tất cả thông tin của nhân viên trong bảng `employees`.  
2. Hiển thị tên, họ và lương của các nhân viên.  
3. Tìm các nhân viên có mức lương lớn hơn 10,000.  
4. Hiển thị danh sách các công việc (`jobs`) cùng với mức lương tối thiểu và tối đa.  
5. Liệt kê tên và tiêu đề công việc của từng nhân viên.  
6. Hiển thị tên nhân viên và tên phòng ban họ đang làm việc.  
7. Tìm các nhân viên thuộc phòng ban có `department_id = 10`.  
8. Tìm các nhân viên làm việc tại thành phố “Seattle”.  
9. Liệt kê các nhân viên có số điện thoại bắt đầu bằng ‘515’.  
10. Liệt kê các nhân viên không có người quản lý.

---

## MỨC TRUNG BÌNH – GROUP BY, SUBQUERY, TỔNG HỢP (11–20)
11. Tính lương trung bình của tất cả nhân viên.  
12. Tính lương trung bình theo từng chức danh công việc.  
13. Đếm số nhân viên trong mỗi phòng ban.  
14. Liệt kê nhân viên có mức lương cao nhất công ty.  
15. Liệt kê các công việc có mức lương tối đa > 20,000.  
16. Tìm các nhân viên có mức lương bằng với mức lương cao nhất trong bảng `employees`.  
17. Liệt kê danh sách nhân viên và số người phụ thuộc (nếu có).  
18. Liệt kê các phòng ban không có nhân viên nào.  
19. Hiển thị tên quốc gia và khu vực nơi có ít nhất một phòng ban.  
20. Tìm tất cả nhân viên có cùng chức danh với người có `employee_id = 100`.

---

## MỨC KHÓ – NÂNG CAO, WINDOW FUNCTION, CASE, EXISTS (21–30)
21. Hiển thị danh sách nhân viên và phân loại mức lương: “Thấp”, “Trung bình”, “Cao”.  
22. Tìm tên các nhân viên có số người phụ thuộc lớn hơn mức trung bình toàn công ty.  
23. Hiển thị tên phòng ban có nhiều hơn 5 nhân viên.  
24. Tìm các nhân viên làm việc cùng phòng ban với người có `employee_id = 101`.  
25. Liệt kê top 3 nhân viên có mức lương cao nhất mỗi phòng ban.  
26. Tìm nhân viên có cùng mức lương với người có tên là ‘John’.  
27. Tính tổng lương công ty phải trả mỗi tháng theo từng khu vực (`regions`).  
28. Tìm tên quốc gia có số lượng phòng ban nhiều nhất.  
29. Tìm các chức danh công việc chưa được bất kỳ nhân viên nào đảm nhiệm.  
30. Với mỗi nhân viên, hiển thị tên quản lý trực tiếp của họ (nếu có).
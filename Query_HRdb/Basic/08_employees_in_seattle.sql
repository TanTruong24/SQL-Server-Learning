/* 
-- native writing
SELECT e.*
FROM employees AS e
INNER JOIN departments AS d ON e.department_id = d.department_id
INNER JOIN locations AS l on l.location_id = d.location_id
WHERE l.city = 'Seattle'
*/

-- USING WHERE EXIST NEST
/*
-> Truy vấn này có độ sâu 2 tầng.
	- SQL Server phải đánh giá từng tầng riêng biệt, và có thể không chia sẻ được thông tin giữa các tầng
	- Tăng độ sâu có thể tăng độ phức tạp logic và làm chậm khả năng tối ưu của optimizer.

-> SQL Server có thể phải dùng Nested Loop 2 lần: employees → loop departments → loop locations

*/
SELECT e.*
FROM employees AS e
WHERE EXISTS (
	SELECT d.department_id 
	FROM departments AS d
	WHERE EXISTS (
		SELECT l.location_id
		FROM locations AS l
		WHERE e.department_id = d.department_id 
			AND l.location_id = d.location_id 
			AND l.city = 'Seattle'
	)
)

-- USING WHERE EXIST JOIN OPTIMAL
/*
- Gộp điều kiện JOIN vào 1 cấp EXISTS → giảm độ sâu truy vấn
- Dễ hiểu, dễ bảo trì hơn
- SQL Server sẽ có cơ hội tối ưu hóa tốt hơn với JOIN thay vì EXISTS lồng nhau

SQL Server có thể chọn:
- Tối ưu JOIN d + l thành 1 bảng tạm → join ngược lại với e
- Tận dụng index city/location_id → lọc sớm
*/
SELECT e.*
FROM employees AS e
WHERE EXISTS (
	SELECT 1
	FROM departments d
	JOIN locations l ON d.location_id = l.location_id
	WHERE d.department_id = e.department_id
	  AND l.city = 'Seattle'
);

/*
- Actual Execution Plan -> phân tích hiệu suất truy vấn và kiểm chứng các tối ưu hóa bạn đã thực hiện.
*/
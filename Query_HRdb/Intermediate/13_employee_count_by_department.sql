--Đếm số nhân viên trong mỗi phòng ban.  
SELECT d.department_name, COUNT(e.employee_id) AS count
FROM employees AS e
JOIN departments AS d ON d.department_id = e.department_id
GROUP BY e.department_id, d.department_name
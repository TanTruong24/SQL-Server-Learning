--Liệt kê các phòng ban không có nhân viên nào. 
SELECT *
FROM departments
WHERE department_id NOT IN (SELECT department_id FROM employees)
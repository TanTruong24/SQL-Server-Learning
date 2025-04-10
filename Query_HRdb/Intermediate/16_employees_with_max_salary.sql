--Tìm các nhân viên có mức lương bằng với mức lương cao nhất trong bảng `employees`
SELECT * FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees)



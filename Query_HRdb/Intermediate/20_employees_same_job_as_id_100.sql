-- 20.Tìm tất cả nhân viên có cùng chức danh với người có `employee_id = 100`
SELECT * FROM employees AS e
WHERE e.job_id = (SELECT job_id FROM employees WHERE employee_id = 100)
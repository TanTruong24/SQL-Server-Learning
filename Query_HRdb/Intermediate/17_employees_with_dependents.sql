-- Liệt kê danh sách nhân viên và số người phụ thuộc (nếu có).
SELECT e.employee_id,e.first_name, e.last_name, COUNT(d.dependent_id) AS dependent_person
FROM employees AS e
LEFT JOIN dependents AS d ON d.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
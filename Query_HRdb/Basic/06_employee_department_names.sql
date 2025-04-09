SELECT employee_id, CONCAT(first_name,' ',last_name) as name, department_name 
FROM employees AS e
INNER JOIN departments AS d ON e.department_id = d.department_id
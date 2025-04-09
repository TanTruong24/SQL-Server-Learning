SELECT employee_id, CONCAT(first_name,' ',last_name) as name, job_title 
FROM employees AS e
INNER JOIN jobs AS j ON e.job_id = j.job_id
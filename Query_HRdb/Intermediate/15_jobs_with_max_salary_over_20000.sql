--Liệt kê các công việc có mức lương tối đa > 20,000.  
SELECT job_id, job_title, max_salary FROM jobs
WHERE max_salary > 20000
GROUP BY job_id, job_title, max_salary

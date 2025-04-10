--Tính lương trung bình theo từng chức danh công việc.  
SELECT job_title, (min_salary + max_salary)/2 AS avg_salary FROM jobs 
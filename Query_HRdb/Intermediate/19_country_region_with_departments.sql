--19. Hiển thị tên quốc gia và khu vực nơi có ít nhất một phòng ban.  

/*
- SELECT * ...	SELECT 1 ... (tối ưu hơn với EXISTS)
- departments JOIN locations	locations JOIN departments (hợp logic hơn: location xác định country, rồi đến department)
- c.country_id = l.country_id	Giữ nguyên, nhưng viết lại trong logic rõ ràng hơn
*/
SELECT c.country_name, r.region_name
FROM countries AS c
JOIN regions AS r ON r.region_id = c.region_id
WHERE EXISTS (
    SELECT 1
    FROM locations AS l
    JOIN departments AS d ON d.location_id = l.location_id
    WHERE l.country_id = c.country_id
);


SELECT DISTINCT c.country_name, r.region_name
FROM departments d
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
JOIN regions r ON c.region_id = r.region_id;

-- Weather Data Analytics | PostgreSQL
-- Synthetic weather observations for SQL practice; not a forecast or official climate record.
DROP TABLE IF EXISTS weather_daily;
CREATE TABLE weather_daily (
 observation_id INT PRIMARY KEY, city VARCHAR(30), observation_date DATE,
 min_temp_c NUMERIC(4,1), max_temp_c NUMERIC(4,1), rainfall_mm NUMERIC(6,1),
 humidity_pct INT, condition VARCHAR(20)
);
INSERT INTO weather_daily VALUES
(1,'Pune','2026-06-01',23,34,0,48,'Sunny'),
(2,'Pune','2026-06-02',22,31,8,66,'Rain'),
(3,'Pune','2026-06-03',21,29,18,78,'Rain'),
(4,'Mumbai','2026-06-01',26,33,5,72,'Cloudy'),
(5,'Mumbai','2026-06-02',25,31,22,84,'Rain'),
(6,'Mumbai','2026-06-03',25,32,0,70,'Cloudy'),
(7,'Nashik','2026-06-01',21,35,0,42,'Sunny'),
(8,'Nashik','2026-06-02',20,33,2,55,'Cloudy'),
(9,'Nashik','2026-06-03',21,30,12,68,'Rain'),
(10,'Nagpur','2026-06-01',28,41,0,35,'Sunny'),
(11,'Nagpur','2026-06-02',27,39,0,38,'Sunny'),
(12,'Nagpur','2026-06-03',26,36,4,51,'Cloudy');
-- 1. City-level weather summary
SELECT city,ROUND(AVG(max_temp_c),1) AS avg_max_temp,
 ROUND(AVG(min_temp_c),1) AS avg_min_temp,SUM(rainfall_mm) AS total_rainfall,
 ROUND(AVG(humidity_pct),1) AS avg_humidity
FROM weather_daily GROUP BY city ORDER BY total_rainfall DESC;
-- 2. Daily temperature range
SELECT city,observation_date,max_temp_c-min_temp_c AS temp_range_c
FROM weather_daily ORDER BY observation_date,city;
-- 3. Rainy-day count
SELECT city,COUNT(*) FILTER (WHERE rainfall_mm>0) AS rainy_days,
 SUM(rainfall_mm) AS rainfall_total
FROM weather_daily GROUP BY city;
-- 4. Hottest observations
SELECT city,observation_date,max_temp_c,
 DENSE_RANK() OVER (ORDER BY max_temp_c DESC) AS heat_rank
FROM weather_daily ORDER BY heat_rank;
-- 5. Condition distribution
SELECT condition,COUNT(*) AS days FROM weather_daily GROUP BY condition ORDER BY days DESC;
-- 6. High humidity alert days
SELECT * FROM weather_daily WHERE humidity_pct>=75 ORDER BY humidity_pct DESC;
-- 7. Rainfall contribution by city
SELECT city,SUM(rainfall_mm) AS rainfall_mm,
 ROUND(100.0*SUM(rainfall_mm)/SUM(SUM(rainfall_mm)) OVER (),2) AS rainfall_share_pct
FROM weather_daily GROUP BY city ORDER BY rainfall_mm DESC;
-- 8. Three-day rolling average of maximum temperature
SELECT city,observation_date,max_temp_c,
 ROUND(AVG(max_temp_c) OVER (PARTITION BY city ORDER BY observation_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),1) AS rolling_avg_max_temp
FROM weather_daily ORDER BY city,observation_date;

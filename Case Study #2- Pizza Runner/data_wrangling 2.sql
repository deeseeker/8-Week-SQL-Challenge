--CHECK Cleaned runner_order table
SELECT *
FROM pizza_runner.runner_orders
--inspect columns with missing value
SELECT DISTINCT pickup_time
FROM pizza_runner.runner_orders

SELECT DISTINCT distance
FROM pizza_runner.runner_orders

SELECT DISTINCT duration
FROM pizza_runner.runner_orders

SELECT DISTINCT cancellation
FROM pizza_runner.runner_orders

SELECT cancellation
FROM pizza_runner.runner_orders
WHERE cancellation = ''
--DATA TRANSFORMATION of runner table
SELECT order_id,runner_id,
	CASE 
        WHEN pickup_time like 'null' THEN null
		ELSE pickup_time END AS pickup_time_alt,
	CASE 
		WHEN distance in ('null', '') THEN null
		WHEN distance like '%km' THEN TRIM('km' from distance)
		ELSE distance END AS distance_alt,
    CASE 
		WHEN duration in ('null', NULL) THEN null
		WHEN duration like '%mins' THEN TRIM('mins' from duration)
		WHEN duration like '%minutes' THEN TRIM('minutes' from duration)
		WHEN duration like '%minute' THEN TRIM('minute' from duration)
		ELSE duration END AS duration_alt,
	CASE 
        WHEN cancellation in (null, '','null') THEN null
		ELSE cancellation END AS cancellation_alt
INTO TEMP TABLE runner_order
FROM pizza_runner.runner_orders



ALTER TABLE runner_order
ALTER COLUMN pickup_time_alt TYPE TIMESTAMP USING pickup_time_alt::TIMESTAMP,
ALTER COLUMN distance_alt TYPE double precision USING distance_alt::double precision,
ALTER COLUMN duration_alt TYPE INT USING duration_alt:: integer;

---view data
SELECT * 
FROM runner_order

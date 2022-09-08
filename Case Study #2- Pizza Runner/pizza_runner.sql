 --DATA CLEANING AND TRANSFORMATION of customer table

SELECT order_id, customer_id, pizza_id,
	CASE
		WHEN exclusions IN ('null' ,'') THEN NULL
		ELSE exclusions
		END AS exclusions,
	CASE 
		WHEN extras IN ('null', '') THEN NULL
		ELSE extras
		END AS extras,order_time 
INTO TEMP TABLE customer_orders
FROM pizza_runner.customer_orders
--CHECK Cleaned customer_order table
SELECT *
FROM customer_orders

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

-- check runner order table
SELECT *
FROM runner_order
--Questions : Pizza Metrics
-- Q1: How many pizzas were ordered?
SELECT count(pizza_id)
FROM customer_orders
--Q2: How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) as unique_order_count
FROM customer_orders
--Q3: How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) orders_delivered
FROM runner_order
WHERE cancellation_alt is NULL
GROUP BY 1
--Q4: How many of each type of pizza was delivered?
SELECT pizza_name, COUNT(c.pizza_id) pizza_count
FROM customer_orders c
JOIN runner_order r
ON c.order_id = r.order_id
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
WHERE cancellation_alt is NULL
GROUP BY pizza_name


--Q5: How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, count(pizza_name) total_order
FROM customer_orders c, pizza_runner.pizza_names p
WHERE c.pizza_id = p.pizza_id
GROUP BY 1,2
ORDER BY 1 

--Q6: What was the maximum number of pizzas delivered in a single order? study
--method 1
SELECT r.order_id, count(pizza_id) pizza_count
FROM customer_orders c
JOIN runner_order r
ON c.order_id = r.order_id
WHERE cancellation_alt is NULL
GROUP BY 1
ORDER BY 2 desc
LIMIT 1

--method 2
WITH pizza_cte AS(
SELECT r.order_id, count(pizza_id) no_pizza
FROM customer_orders c
JOIN runner_order r
ON c.order_id = r.order_id
WHERE cancellation_alt is NULL
GROUP BY 1)

SELECT MAX(no_pizza) max_delivered
FROM pizza_cte

--Q7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?  
SELECT c.customer_id,
SUM(CASE 
	WHEN c.exclusions IS NOT NULL or c.extras IS NOT NULL THEN 1
	ELSE 0 END)AS at_least_1_change,
SUM(CASE 
	WHEN c.exclusions is NULL AND  c.extras is NULL THEN 1
	ELSE 0 END) AS no_change
FROM customer_orders c
JOIN runner_order r
ON r.order_id = c.order_id
WHERE cancellation_alt is NULL
GROUP BY 1
ORDER BY 1
--Q8: How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(pizza_id)
FROM customer_orders c
JOIN runner_order r
ON r.order_id = c.order_id
WHERE (exclusions != NULL AND extras != NULL) AND cancellation_alt = NULL

--Q9: What was the total volume of pizzas ordered for each hour of the day?
SELECT DATE_PART('hour',order_time) hour_of_the_day, COUNT(order_id) pizza_vol
FROM customer_orders c
GROUP BY DATE_PART('hour',order_time);
--Q10: What was the volume of orders for each day of the week?
SELECT extract(isodow from order_time) day_of_the_week, COUNT(order_id) pizza_vol
FROM customer_orders
GROUP BY 1




-- Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
SELECT *
FROM pizza_runner.pizza_recipes
























 --DATA CLEANING AND TRANSFORMATION
--view data
SELECT *
FROM pizza_runner.customer_orders

--inspect the exclusions and extras column closely
SELECT DISTINCT exclusions
FROM pizza_runner.customer_orders

SELECT DISTINCT extras
FROM pizza_runner.customer_orders

SELECT DISTINCT extras
FROM pizza_runner.customer_orders
WHERE extras is NULL

SELECT DISTINCT exclusions
FROM pizza_runner.customer_orders
WHERE exclusions is NULL

SELECT DISTINCT exclusions
FROM pizza_runner.customer_orders
WHERE exclusions = ''

SELECT DISTINCT extras
FROM pizza_runner.customer_orders
WHERE extras = 'null'

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

--Questions : Pizza Metrics
-- Q1: How many pizzas were ordered?
SELECT count(pizza_id)
FROM customer_orders
--Q2: How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) as unique_order_count
FROM customer_orders
--Q3: How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id)
FROM runner_order..
WHERE cancellation_alt = ''
GROUP BY 1
--Q4: How many of each type of pizza was delivered?
SELECT pizza_name, COUNT(c.pizza_id) no_ofpizza
FROM customer_orders c
JOIN runner_order r
ON c.order_id = r.order_id
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
WHERE cancellation_alt = ''
GROUP BY pizza_name


--Q5: How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, count(pizza_name) tot_order
FROM customer_orders c, pizza_runner.pizza_names p
WHERE c.pizza_id = p.pizza_id
GROUP BY 1,2
ORDER BY 1 

--Q6: What was the maximum number of pizzas delivered in a single order? study
--method 1
SELECT r.order_id, count(pizza_id) no_pizza
FROM customer_orders c
JOIN runner_order r
ON c.order_id = r.order_id
WHERE cancellation_alt = ''
GROUP BY 1
ORDER BY 2 desc
LIMIT 1

--method 2
WITH pizza_cte AS(
SELECT r.order_id, count(pizza_id) no_pizza
FROM customer_orders c
JOIN runner_order r
ON c.order_id = r.order_id
WHERE cancellation_alt = ''
GROUP BY 1)

SELECT MAX(no_pizza) max_delivered
FROM pizza_cte

--Q7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?  
SELECT c.customer_id,
SUM(CASE 
	WHEN c.exclusions <> '' or c.extras <> '' THEN 1
	ELSE 0 END)AS at_least_1_change,
SUM(CASE 
	WHEN c.exclusions = '' AND  c.extras = '' THEN 1
	ELSE 0 END) AS no_change
FROM customer_orders c
JOIN runner_order r
ON r.order_id = c.order_id
WHERE cancellation_alt = ''
GROUP BY 1
ORDER BY 1
--Q8: How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(pizza_id)
FROM customer_orders c
JOIN runner_order r
ON r.order_id = c.order_id
WHERE (exclusions != '' AND extras != '') AND cancellation_alt = ''

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
























 --DATA CLEANING AND TRANSFORMATION (customer_table)
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
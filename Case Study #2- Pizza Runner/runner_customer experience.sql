--Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--conversion of ISO8601 to preferred starting week
SELECT EXTRACT(ISOYEAR FROM registration_date) ISO8601,EXTRACT(ISOYEAR FROM registration_date+3) desired_year,
	   registration_date, EXTRACT(WEEK FROM registration_date+3) desired_week
FROM pizza_runner.runners

SELECT EXTRACT(WEEK FROM registration_date+3) registration_week, COUNT(*) runner_signup
FROM pizza_runner.runners
GROUP BY 1
ORDER BY 1;
--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH time_cte as (
					SELECT runner_id, EXTRACT(MINUTE FROM pickup_time_alt - order_time) as pickuptime_min
					FROM runner_order r
					JOIN customer_orders c
					ON r.order_id = c.order_id)

SELECT runner_id, ROUND(AVG(time_min)::int,2) avg_pick_time
FROM time_cte 
GROUP BY 1

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizza_cte as (SELECT r.order_id, COUNT(r.order_id) no_of_pizza,EXTRACT(MINUTE FROM pickup_time_alt - order_time) prep_min
FROM runner_order r
JOIN customer_orders c
ON r.order_id = c.order_id
WHERE cancellation_alt = ''
GROUP BY r.order_id,3)

SELECT no_of_pizza, AVG(prep_min) avg_prep_time
FROM pizza_cte
GROUP BY 1
-- 4.What was the average distance travelled for each customer?
SELECT customer_id, ROUND(AVG(distance_alt)::int,2)
FROM runner_order r
JOIN customer_orders c
ON r.order_id = c.order_id
WHERE cancellation_alt = ''
GROUP BY customer_id

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration_alt) - MIN(duration_alt) diff_deliver_time
FROM runner_order r
--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT  runner_id, r.order_id,ROUND((distance_alt/duration_alt*60)::int,2) avg_speed
FROM runner_order r
JOIN customer_orders c 
USING order_id --r.order_id = c.order_id
ORDER BY 3 DESC 

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id, 
	   ROUND((100 * SUM(CASE
	   	   WHEN cancellation_alt != '' THEN 0
		   ELSE 1 END))/COUNT(*)) AS per_delivery
FROM runner_order
GROUP BY 1
ORDER BY per_delivery DESC

















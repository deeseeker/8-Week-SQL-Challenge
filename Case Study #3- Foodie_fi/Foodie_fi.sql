SELECT *
FROM foodie_fi.subscriptions f
JOIN foodie_fi.plans p
ON p.plan_id = f.plan_id
ORDER BY 3


--DATA ANALYSIS Questions
--1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT(customer_id)) customer_count
FROM foodie_fi.subscriptions f

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT cast(DATE_TRUNC('month',start_date) as date) month_date, TO_CHAR(start_date,'Month') month_name, COUNT(plan_name) frequency
FROM foodie_fi.subscriptions f
JOIN foodie_fi.plans p
ON p.plan_id = f.plan_id
WHERE plan_name like '%tr%'
GROUP BY DATE_TRUNC('month',start_date),2
ORDER BY 1 

--3.What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_name, DATE_PART('year',start_date), COUNT(plan_name) 
FROM foodie_fi.subscriptions f
JOIN foodie_fi.plans p
ON p.plan_id = f.plan_id
WHERE DATE_PART('year',start_date) > 2020
GROUP BY 2,1
ORDER BY 3 desc

--further exploration
SELECT  f.plan_id, plan_name,
	   SUM(CASE 
	   		WHEN DATE_PART('year',start_date) = 2020 THEN 1
			ELSE 0
	   END) as event_2020,
	   SUM(CASE 
	   		WHEN DATE_PART('year',start_date) = 2020 THEN 0
			ELSE 1
	   END) as event_2021
FROM foodie_fi.subscriptions f
JOIN foodie_fi.plans p
ON p.plan_id = f.plan_id
GROUP BY 1,2
ORDER BY 3 desc

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(*) churn_count, 
	   ROUND(100 * COUNT(*)::numeric / 
	   (SELECT COUNT(DISTINCT(customer_id))
	   FROM foodie_fi.subscriptions f),1) churn_percentage
FROM foodie_fi.subscriptions f
JOIN foodie_fi.plans p
ON p.plan_id = f.plan_id
WHERE plan_name = 'churn'
GROUP BY plan_name

5 How many customers have churned straight after their initial free trial - 
what percentage is this rounded to the nearest whole number?

WITH ranked_tab as (SELECT customer_id,plan_name,start_date,
	   DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY start_date) ranking
FROM foodie_fi.subscriptions f
JOIN foodie_fi.plans p
ON p.plan_id = f.plan_id)

SELECT COUNT(*) no_customers, ROUND(100*(COUNT(*)::numeric / 
			(SELECT COUNT(DISTINCT(customer_id))
	        FROM foodie_fi.subscriptions)),1) trial_perc_churn
FROM ranked_tab
WHERE ranking =2 and plan_name LIKE 'ch%'

6 What is the number and percentage of customer plans after their initial free trial? wrong


7.

8.How many customers have upgraded to an annual plan in 2020?

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
-- Question 1: What is the total amount each customer spent at the restaurant?
--Method 1
SELECT customer_id, SUM(price) total_amount
FROM dannys_diner.sales sales,dannys_diner.menu as menu
WHERE sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY total_amount desc;
--Method 2
SELECT customer_id customer, SUM(price) total_amount
FROM dannys_diner.sales sales JOIN dannys_diner.menu  as menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY total_amount desc;

--QUESTION 2: How many days has each customer visited the restaurant?
SELECT customer_id, count(distinct(order_date)) no_of_days
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY no_of_days desc;

--QUESTION 3: What was the first item from the menu purchased by each customer?
-- METHOD 1		  
SELECT DISTINCT customer_id,product_name		   
FROM dannys_diner.sales sales JOIN dannys_diner.menu menu
ON menu.product_id = sales.product_id
WHERE order_date IN (SELECT MIN(order_date)
FROM dannys_diner.sales
GROUP BY customer_id)
ORDER BY customer_id;

--METHOD 2
WITH ordered_sales_cte AS
(
 SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
 FROM dannys_diner.sales s
 JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rank = 1
GROUP BY customer_id, product_name;
--QUESTION 4: What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, COUNT(sales.product_id) most_purchased
FROM dannys_diner.sales sales, dannys_diner.menu menu
WHERE sales.product_id = menu.product_id 
GROUP BY product_name 
ORDER BY 2 desc
LIMIT 1

--QUESTION 5: Which item was the most popular for each customer?
WITH pop_cte as (SELECT customer_id, product_name, COUNT(s.product_id) purchased_no,COUNT(customer_id),
RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(customer_id) DESC) rank_no
FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON s.product_id = m.product_id 
GROUP BY 1,2)
SELECT customer_id, product_name, purchased_no
FROM pop_cte
WHERE rank_no =1
--QUESTION 6: Which item was purchased first by the customer after they became a member?

WITH purchased_hist AS (SELECT sales.customer_id,product_name,order_date,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date)
FROM dannys_diner.sales sales JOIN dannys_diner.members
ON members.customer_id = sales.customer_id
JOIN dannys_diner.menu menu
ON menu.product_id = sales.product_id
WHERE order_date >= join_date)
SELECT customer_id, product_name, order_date
FROM purchased_hist
WHERE rank=1

--QUESTION 7: Which item was purchased first by the customer before they became a member?

WITH purchased_hist AS (SELECT sales.customer_id,product_name,order_date,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date)
FROM dannys_diner.sales sales JOIN dannys_diner.members
ON members.customer_id = sales.customer_id
JOIN dannys_diner.menu menu
ON menu.product_id = sales.product_id
WHERE order_date < join_date)
SELECT customer_id, product_name, order_date
FROM purchased_hist
WHERE rank=1

--QUESTION 8: What is the total items and amount spent for each member before they became a member?
SELECT sales.customer_id, COUNT(sales.product_id) total_items, SUM(price) as total_sales
FROM dannys_diner.sales sales JOIN dannys_diner.members
ON members.customer_id = sales.customer_id
JOIN dannys_diner.menu menu
ON menu.product_id = sales.product_id
WHERE order_date < join_date
GROUP BY 1

--QUESTION 9:If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

SELECT a.customer_id, SUM(a.customer_points)
FROM (SELECT s.customer_id,
CASE 
	WHEN product_name = 'sushi' THEN 20*(price) 
	ELSE 10*(price)
END as customer_points
FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON m.product_id = s.product_id) a
GROUP BY 1
--QUESTION 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

SELECT s.customer_id,s.order_date, c.join_date, join_date + 6 valid_date, 
'2021-01-31' last_date, product_name,price,
SUM(CASE 
	WHEN product_name = 'sushi' THEN 20*(price)
	WHEN s.order_date BETWEEN join_date  AND join_date + 6  THEN 20*(price)
	ELSE 10*(price)
END )as customer_points	
FROM dannys_diner.menu m JOIN dannys_diner.sales s
ON m.product_id = s.product_id
JOIN dannys_diner.members c
ON c.customer_id = s.customer_id
WHERE s.order_date < '2021-01-31'
GROUP BY 1,2,3,4,5,6,7
--it is a good practice to include all these columns in order to confirm if the conditions were satisfied
--ANSWER
SELECT s.customer_id,
SUM(CASE 
	WHEN product_name = 'sushi' THEN 20*(price)
	WHEN s.order_date BETWEEN join_date  AND join_date + 6  THEN 20*(price)
	ELSE 10*(price)
END )as customer_points	
FROM dannys_diner.menu m JOIN dannys_diner.sales s
ON m.product_id = s.product_id
JOIN dannys_diner.members c
ON c.customer_id = s.customer_id
WHERE s.order_date < '2021-01-31'
GROUP BY 1

--BONUS QUESTION
SELECT s.customer_id,order_date,product_name,price,
CASE
	WHEN c.join_date > s.order_date THEN 'N'
	WHEN c.join_date <= s.order_date THEN 'Y'
	ELSE 'N' END as Members
FROM dannys_diner.sales s JOIN dannys_diner.menu m
ON m.product_id = s.product_id
LEFT JOIN dannys_diner.members c
ON c.customer_id = s.customer_id
ORDER BY 1,2


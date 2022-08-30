-- A. Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT COUNT(order_id) AS 'How Many Pizza Ordered' 
FROM cl_customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS 'Unique Customer Orders'
FROM cl_customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS 'Successful Orders' 
FROM cl_runner_orders
WHERE cancellation=''
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(p.pizza_id) AS 'Number of Delivered Pizza'
FROM cl_customer_orders c
INNER JOIN pizza_names p ON c.pizza_id = p.pizza_id
INNER JOIN cl_runner_orders r ON c.order_id = r.order_id
WHERE cancellation= ''
GROUP BY p.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_id) AS 'Number of Delivered Pizza'
FROM cl_customer_orders c
INNER JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH pizza_count_cte AS
(SELECT c.order_id, count(c.order_id) AS 'Number_of_Pizza'
FROM cl_customer_orders c
INNER JOIN cl_runner_orders r
ON c.order_id = r.order_id
WHERE distance!= 0
GROUP BY c.order_id)

SELECT max(Number_of_Pizza) AS 'Max Pizza pizzas delivered in a single order'
FROM pizza_count_cte;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id,
SUM(CASE
	WHEN c.exclusions != 0 or c.extras!=0 THEN 1
    ELSE 0
    END) AS '1 or more change',
SUM(CASE
	WHEN c.exclusions = 0 AND c.extras =0 THEN 1
    ELSE 0
    END) AS 'no changes'
FROM cl_customer_orders c
INNER JOIN cl_runner_orders r
ON c.order_id = r.order_id
WHERE r.distance!= 0
GROUP BY c.customer_id;
    
-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(c.customer_id) AS 'number of pizzas were delivered that had both exclusions and extras'
FROM cl_customer_orders c 
INNER JOIN cl_runner_orders r 
ON c.order_id = r.order_id
WHERE c.exclusions != 0 AND c.extras !=0 AND r.distance!= 0;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS 'Hour_of_the_day', COUNT(order_id) AS 'Number of pizza ordered' 
FROM cl_customer_orders
GROUP BY Hour_of_the_day
ORDER BY Hour_of_the_day;


-- 10. What was the volume of orders for each day of the week?
SELECT WEEKDAY(order_time) AS 'day_of_the_week', DAYNAME(order_time) AS 'day', COUNT(order_id) AS 'Number of pizza ordered' 
FROM cl_customer_orders
GROUP BY day_of_the_week
ORDER BY day_of_the_week;

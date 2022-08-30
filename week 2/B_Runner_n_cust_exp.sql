-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
Select registration_date, WEEK(registration_date) AS 'week_period', COUNT(registration_date) AS 'Number_runner_signup'
FROM runners
GROUP BY week_period;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH pickup_avg_cte AS
(SELECT c.order_id, c.order_time, r.pickup_time, r.runner_id,
TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS 'pickup_in_minutes'
FROM cl_runner_orders r
INNER JOIN cl_customer_orders c
ON r.order_id=c.order_id
WHERE r.distance != 0
GROUP BY c.order_time)

SELECT runner_id, ROUND(AVG(pickup_in_minutes)) AS 'Minutes of AVG runner arrive at the Pizza Runner HHQ'
FROM pickup_avg_cte
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH relation_cte AS
(SELECT COUNT(c.order_id) AS 'number_of_pizza', c.order_time, r.pickup_time, TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS 'prepare_time_in_minutes'
FROM cl_runner_orders r
INNER JOIN cl_customer_orders c
ON r.order_id=c.order_id
WHERE r.distance != 0
GROUP BY c.order_time)

SELECT number_of_pizza, ROUND(AVG(prepare_time_in_minutes)) AS 'avg_prepare'
FROM relation_cte
GROUP BY number_of_pizza;

-- 4. What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(r.distance)) AS 'avg_distance'
FROM cl_customer_orders c
INNER JOIN cl_runner_orders r
ON c.order_id=r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)-MIN(duration) AS 'the difference'
FROM cl_runner_orders
WHERE duration != 0;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT c.order_id, c.customer_id, r.runner_id, COUNT(c.order_id) 'Number_of_pizza', ROUND(distance/(duration/60),2) AS 'avg_speed'
FROM cl_customer_orders c
INNER JOIN cl_runner_orders r
ON c.order_id=r.order_id
WHERE r.distance != 0
GROUP BY c.order_id, r.runner_id
ORDER BY avg_speed DESC;

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id,
ROUND(100*SUM(CASE 
	WHEN cancellation = '' THEN 1
    ELSE 0
    END)/COUNT(*)) AS 'success'
FROM cl_runner_orders
GROUP BY runner_id;

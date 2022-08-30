-- Data Cleaning (MySql)

-- 1. for customer_orders table (cleaning)
CREATE TABLE cl_customer_orders; -- TEMPORARY TABLE
SELECT order_id, customer_id, pizza_id, 
  (CASE 
    WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
    ELSE exclusions
    END) AS exclusions,
  (CASE 
    WHEN extras IS NULL or extras LIKE 'null' THEN ' '
    ELSE extras 
    END) AS extras, order_time
FROM customer_orders;
-- exclusions and extras is still varchar not integer because them filled by topping id

-- 2. for runner_orders table (cleaning and data type correction)
DROP TABLE cl_runner_orders;
CREATE TABLE cl_runner_orders
SELECT order_id, runner_id,
  CASE 
    WHEN pickup_time LIKE 'null' THEN NULL
    ELSE pickup_time 
    END AS pickup_time,
  CASE 
    WHEN distance LIKE 'null' THEN NULL
    WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
    WHEN distance LIKE ' ' THEN TRIM(' ' from distance) 
    ELSE distance END AS distance,
  CASE 
    WHEN duration LIKE 'null' THEN NULL
    WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
    ELSE duration END AS duration,
  CASE 
    WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ''
    ELSE cancellation END AS cancellation
FROM runner_orders;

ALTER TABLE cl_runner_orders MODIFY pickup_time DATETIME NULL;
ALTER TABLE cl_runner_orders MODIFY distance DECIMAL(10,1) NULL;
ALTER TABLE cl_runner_orders MODIFY duration INT NULL;

DESCRIBE cl_runner_orders;
SELECT * FROM cl_runner_orders
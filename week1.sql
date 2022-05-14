-- Author : Mahmudin Rizal
-- Tools  : PostgreSQL

-- Challenge link : https://8weeksqlchallenge.com/case-study-1/

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- No 1 --
SELECT customer_id, SUM(price) AS total_spent
FROM dannys_diner.sales ds
INNER JOIN dannys_diner.menu dm
ON ds.product_id = dm.product_id
GROUP BY customer_id
ORDER BY total_spent DESC;

-- No 2 --
SELECT customer_id, COUNT(DISTINCT(order_date)) AS total_visit
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY total_visit DESC;

-- No 3 --
WITH date_sales_menu_cte AS(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY ds.customer_id ORDER BY ds.order_date) AS date_rank
	FROM dannys_diner.sales ds
	INNER JOIN dannys_diner.menu dm
	ON ds.product_id = dm.product_id
) 

SELECT customer_id, date_rank, product_name 
FROM date_sales_menu_cte
WHERE date_rank = 1
GROUP BY customer_id, date_rank, product_name;

-- No 4 --
SELECT product_name, COUNT(product_name) AS total_sales
FROM dannys_diner.sales ds
INNER JOIN dannys_diner.menu dm
ON ds.product_id = dm.product_id
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 1;

-- No 5 --
WITH favo_cte AS(
	SELECT customer_id, product_name, COUNT(product_name) AS total_sales
	FROM dannys_diner.sales ds
	INNER JOIN dannys_diner.menu dm
	ON ds.product_id = dm.product_id
	GROUP BY customer_id, product_name
),
favo_rank AS(
	SELECT *, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY total_sales DESC) AS menu_rank
	FROM favo_cte
)
SELECT customer_id, product_name, total_sales FROM favo_rank
WHERE menu_rank = 1
GROUP BY customer_id, product_name, total_sales;

-- No 6 --
WITH first_buy_member_cte AS(
	SELECT ds.customer_id, product_name , DENSE_RANK() OVER(PARTITION BY ds.customer_id ORDER BY ds.order_date)
	FROM dannys_diner.sales ds
	INNER JOIN dannys_diner.members dms
	ON ds.customer_id = dms.customer_id
	INNER JOIN dannys_diner.menu dm
	ON ds.product_id = dm.product_id
	WHERE order_date >= join_date
)
SELECT customer_id, product_name
FROM first_buy_member_cte
WHERE dense_rank = 1;

-- No 7 --
WITH first_buy_member_cte AS(
	SELECT ds.customer_id, product_name , DENSE_RANK() OVER(PARTITION BY ds.customer_id ORDER BY ds.order_date DESC)
	FROM dannys_diner.sales ds
	INNER JOIN dannys_diner.members dms
	ON ds.customer_id = dms.customer_id
	INNER JOIN dannys_diner.menu dm
	ON ds.product_id = dm.product_id
	WHERE order_date < join_date
)
SELECT customer_id, product_name
FROM first_buy_member_cte
WHERE dense_rank = 1;

-- No 8 --
SELECT ds.customer_id, COUNT(ds.product_id) AS total_items, SUM(price) AS total_spent
FROM dannys_diner.sales ds
INNER JOIN dannys_diner.members dms
ON ds.customer_id = dms.customer_id
INNER JOIN dannys_diner.menu dm
ON ds.product_id = dm.product_id
WHERE order_date < join_date
GROUP BY ds.customer_id;


-- No 9 --
WITH points_cte AS(
	SELECT *, 
		(CASE
			WHEN product_name = 'sushi' THEN price * 20
			ELSE price * 10 
			END) AS total_points
	FROM dannys_diner.menu
)

SELECT customer_id, SUM(total_points) AS total_points
FROM points_cte cte
INNER JOIN dannys_diner.sales ds
ON ds.product_id = cte.product_id
GROUP BY customer_id
ORDER BY total_points DESC;

-- No 10 --
WITH date_add_cte AS(
	SELECT *,
	join_date+interval '6 day' AS first_week
	FROM dannys_diner.members
)

SELECT cte.customer_id, 
	SUM(CASE
		WHEN order_date BETWEEN join_date AND first_week THEN price * 20
	 	WHEN product_name = 'sushi' THEN price * 20
		ELSE price * 10 
		END) AS total_points
FROM date_add_cte cte
INNER JOIN dannys_diner.sales ds
ON cte.customer_id = ds.customer_id
INNER JOIN dannys_diner.menu dm
ON ds.product_id = dm.product_id
WHERE order_date <= '2021-01-31'
GROUP BY cte.customer_id;

-- BONUS QUESTION 1 --
SELECT ds.customer_id, 
  ds.order_date, 
  dm.product_name, 
  dm.price,
  (CASE WHEN ds.order_date < dmm.join_date THEN 'N'
	  WHEN ds.order_date >= dmm.join_date THEN 'Y'
	  ELSE 'N' 
   	  END) AS member
FROM dannys_diner.sales AS ds
LEFT JOIN dannys_diner.menu AS dm
ON ds.product_id = dm.product_id
LEFT JOIN dannys_diner.members AS dmm
ON ds.customer_id = dmm.customer_id
ORDER BY ds.customer_id, ds.order_date;

-- BONUS QUESTION 2 --
WITH sumary_member AS(
	SELECT ds.customer_id, 
	  ds.order_date, 
	  dm.product_name, 
	  dm.price,
	  (CASE WHEN ds.order_date < dmm.join_date THEN 'N'
		  WHEN ds.order_date >= dmm.join_date THEN 'Y'
		  ELSE 'N' 
		  END) AS member_stat
	FROM dannys_diner.sales AS ds
	LEFT JOIN dannys_diner.menu AS dm
	ON ds.product_id = dm.product_id
	LEFT JOIN dannys_diner.members AS dmm
	ON ds.customer_id = dmm.customer_id
	ORDER BY ds.customer_id, ds.order_date
)
SELECT *,
	(CASE 
	 WHEN member_stat = 'N' THEN null
	 ELSE RANK() OVER(PARTITION BY customer_id, member_stat ORDER BY order_date)
	 END) AS rank_stat
FROM sumary_member

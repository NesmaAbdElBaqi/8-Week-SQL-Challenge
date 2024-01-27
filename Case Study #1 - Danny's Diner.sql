-- create database
CREATE database dannys_diner
------------------------------------------------

-- create tables
use dannys_diner
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER,
)

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
  ('C', '2021-01-07', '3')
 

CREATE TABLE menu (
  "product_id" INTEGER not null primary key,
  "product_name" VARCHAR(5),
  "price" INTEGER
)

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12')
  
CREATE TABLE members (
  "customer_id" VARCHAR(1) not null primary key,
  "join_date" DATE
)

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09')
-------------------------------------------------------

-- Made a diagram and solved a problems
-- Add to the member's table a new column to make a relation and FK between tables : ('C', '2021-01-12') 
-------------------------------------------------------

-- Case Studies: --

-- (1) What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as total_amount
from sales s
join menu m on s.product_id = m.product_id
group by (s.customer_id)
-------------------------------------------------------

-- (2) How many days has each customer visited the restaurant?
select s.customer_id, COUNT(distinct(s.order_date)) as visited_number
from sales s
group by (s.customer_id)
-------------------------------------------------------

-- (3) What was the first item from the menu purchased by each customer?
with first_purchased as (
select s.customer_id, s.order_date, m.product_name,
rank() over (partition by s.customer_id order by s.order_date) as first_item
from sales s
join menu m on s.product_id = m.product_id
)
select customer_id, product_name
from first_purchased 
where first_item = 1
group by customer_id, product_name
-------------------------------------------------------

-- (4) What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 m.product_name, count(s.product_id) as number_purchased
from menu m
join sales s on m.product_id = s.product_id
group by m.product_name
ORDER BY number_purchased desc
-------------------------------------------------------

-- (5) Which item was the most popular for each customer?
with most_popular as (
select s.customer_id , m.product_name, count(s.product_id) as number_orders,
rank() over (partition by s.customer_id order by s.product_id desc ) as most_item
from sales s 
join menu m on s.product_id = m.product_id
group by s.customer_id , m.product_name, s.product_id
)
select customer_id, product_name
from most_popular
where most_item = 1
-------------------------------------------------------

-- (6) Which item was purchased first by the customer after they became a member?
with first_item as ( 
select s.customer_id, b.join_date, m.product_name, s.order_date,
rank() over (partition by s.customer_id order by s.order_date desc ) as first_item
from sales s
join members b  on b.customer_id = s.customer_id
join menu m on s.product_id = m.product_id
where s.order_date < b.join_date
)

select customer_id, product_name
from first_item
where first_item =  1
group by customer_id, product_name
-------------------------------------------------------

-- (7) Which item was purchased just before the customer became a member?
with first_item as ( 
select s.customer_id, b.join_date, m.product_name, s.order_date,
rank() over (partition by s.customer_id order by s.order_date desc ) as first_item
from sales s
join members b  on b.customer_id = s.customer_id
join menu m on s.product_id = m.product_id
where s.order_date > b.join_date
)

select customer_id, product_name
from first_item
where first_item =  1
group by customer_id, product_name
-------------------------------------------------------

-- (8) What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(m.product_name) as total_product, sum(m.price) as total_price
from sales s
join menu m on s.product_id = m.product_id
join members b on s.customer_id = b.customer_id
where s.order_date > b.join_date
group by s.customer_id
order by s.customer_id
-------------------------------------------------------

-- (9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as (
select * ,case when product_name = ' Sushi ' then price * 10 * 2  else price * 10  end as points_culc
from menu
group by menu.product_id, menu.product_name, menu.price
)

select s.customer_id , sum(p.points_culc) as points
from sales s
join points p on s.product_id = p.product_id
group by s.customer_id 
-------------------------------------------------------

-- (10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -
-- how many points do customer A and B have at the end of January?
select s.customer_id, 
sum
(
case
when
(DATEDIFF (day , b.join_date, s.order_date) between 0 and 7 ) or (m.product_name) = ' Sushi ' then price * 10 * 2 
else price * 10 end ) as points
from sales s
join members b on b.customer_id = s.customer_id
join menu m on m.product_id = s.product_id
where s.order_date >= b.join_date and s.order_date <= CAST('2021-01-31' AS DATE)
group by s.customer_id
-------------------------------------------------------


-- Bonus Questions: --

-- (11) Join All The Things
select s.customer_id, s.order_date, m.product_name, m.price,
case
when b.join_date > s.order_date then ' N '
when b.join_date is null then ' N '
else ' Y ' end  as member
from sales s
join menu m on s.product_id = m.product_id
join members b on s.customer_id = b.customer_id
order by s.customer_id 
-------------------------------------------------------

-- (12) Rank All The Things
with rank_cte as (
select s.customer_id, s.order_date, m.product_name, m.price,
case
when b.join_date > s.order_date then ' N '
when b.join_date is null then ' N '
else ' Y ' end  as member
from sales s
join menu m on s.product_id = m.product_id
join members b on s.customer_id = b.customer_id

)

select customer_id, order_date, product_name, price, member,
case when member = ' N ' then null
else rank() over (partition by customer_id order by order_date desc ) end as rank
from rank_cte




-- End of Case Study #1 - Danny's Diner

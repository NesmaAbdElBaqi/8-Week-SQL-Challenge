-- create database
CREATE database pizza_runner

-- create tables
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15')


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" VARCHAR(19)
)

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49')


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
)

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null')


CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
)
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
)
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
)
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce')
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

-- Cleaning Data -- 

-- (1) Table: runner_order
-- Changing all the null and blank to Null
-- Removing 'km' from distance coulmn
-- Removing anything after the numbers from duration coulmn
-- Creating a clean temporary table
-- Changing data types
select order_id, runner_id,
  case when pickup_time = 'null' then null else pickup_time end as pickup_time,
  case when distance = 'null' then null
       when distance like '%km' then TRIM('km' from distance)
       else distance end as distance,
  case when duration = 'null' then null
	   when duration like '%mins' then TRIM('mins' from duration)
	   when duration like '%minutes' then TRIM('minutes' from duration)
	   when duration like '%minute' then TRIM('minute' from duration)
       else duration end as duration,
  case when cancellation = 'null' then null
       when cancellation = ' ' then null
       else cancellation end as cancellation
into #runner_order_temp
from runner_orders
  
 select * from  #runner_order_temp
 -------------
 alter table #runner_order_temp alter column pickup_time datetime
 alter table #runner_order_temp alter column distance float
 alter table #runner_order_temp alter column duration float
---------------------------------------------------------

-- (2) Table: customer_orders
-- Changing all the null and blank to Null
-- Changing data types
select order_id, customer_id, pizza_id,
   case
      when exclusions = 'null' or exclusions = ' ' then null else exclusions end as exculusions,
   case
      when extras = 'null' or extras = ' ' then null else extras end as extras
	  ,order_time
into #customer_order_temp
from customer_orders

 select * from  #customer_order_temp
-------------
with cte as (
select c.order_id, c.pizza_id, c.customer_id, value as extra
from #customer_order_temp c
CROSS APPLY  string_split(c.extras, ',')
)

select order_id, pizza_id, customer_id, cast(trim( ' ' from extra) as int) as extra
into #extra_temp from cte

select * from #extra_temp
-------------
with cte as (
select c.order_id, c.pizza_id, c.customer_id, value as exculusions
from #customer_order_temp c
CROSS APPLY  string_split(c.exculusions, ',')
)

select order_id, pizza_id, customer_id, cast(trim( ' ' from exculusions) as int) as exculusions
into #exculusions_temp from cte

select * from #exculusions_temp
-------------
alter table  #customer_order_temp alter column order_time datetime
alter table #extra_temp add record_id int not null IDENTITY(1, 1) 
alter table #exculusions_temp add record_id int not null IDENTITY(1, 1) 
alter table #customer_order_temp add record_id int not null IDENTITY(1, 1) 
---------------------------------------------------------

--(3) Table: pizza_names
-- Changing data types
alter table pizza_names alter column pizza_name varchar(1000)
---------------------------------------------------------

--(4) Table: pizza_recipes
-- Changing data types
alter table pizza_recipes alter column toppings varchar(1000)
-------------
with cte as (
select pr.pizza_id, pr.toppings, value as topping_id
from pizza_recipes pr
CROSS APPLY  string_split(pr.toppings, ',')
)

select pizza_id, cast(trim( ' ' from topping_id) as int) as topping_id
into #pizza_recipes_temp
from cte


select * from #pizza_recipes_temp
---------------------------------------------------------

--(5) Table: pizza_toppings
-- Changing data types
alter table pizza_toppings alter column topping_name varchar(1000)
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

-- Case Studies: --


-- A. Pizza Metrics --

-- (1) How many pizzas were ordered?
select count(pizza_id) as total_orderes_pizza
from #customer_order_temp
---------------------------------------------------------

-- (2) How many unique customer orders were made?
select count(distinct(order_id)) as total_uniqe_customer
from #customer_order_temp
---------------------------------------------------------

-- (3) How many successful orders were delivered by each runner?
select runner_id ,count(order_id) as seccessful_orders 
from #runner_order_temp
where cancellation is null
group by runner_id
order by runner_id 
---------------------------------------------------------

-- (4) How many of each type of pizza was delivered?
select p.pizza_name, count(c.pizza_id) as piza_delivred
from #customer_order_temp c
join pizza_names p on p.pizza_id = c.pizza_id
join #runner_order_temp r on c.order_id = r.order_id
where r.distance is not null
group by p.pizza_name
---------------------------------------------------------

-- (5) How many Vegetarian and Meatlovers were ordered by each customer?
with cte as (
select c.customer_id,
case when c.pizza_id = 1 then 1 else 0 end as Meatlovers,
case when c.pizza_id = 2 then 1 else 0 end as Vegetarian
from #customer_order_temp c
)

select customer_id, sum(Meatlovers) as Meatlovers, sum(Vegetarian) as Vegetarian
from cte
group by customer_id
---------------------------------------------------------

-- (6) What was the maximum number of pizzas delivered in a single order?
with cte as (
select c.order_id ,count(c.order_id) as total_single_order
from #customer_order_temp c
join #runner_order_temp r on c.order_id = r.order_id
group by c.order_id
)

select order_id, max( total_single_order) as total_single_order
from cte
group by order_id
order by order_id
---------------------------------------------------------

--(7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
with cte as (
select c.customer_id,
case when c.exculusions is not null or c.extras is not null then 1 else 0 end as changed_pizza,
case when c.exculusions is null and c.extras is  null then 1 else 0 end as unchanged_pizza
from #customer_order_temp c
join #runner_order_temp r on c.order_id = r.order_id
where r.distance is not null
)
select customer_id, sum(changed_pizza) as change_pizza, sum(unchanged_pizza) as nochange_pizza
from cte
group by customer_id
---------------------------------------------------------

-- (8) How many pizzas were delivered that had both exclusions and extras?
select count(c.order_id) as delivered_pizza
from #customer_order_temp c 
join #runner_order_temp r on c.order_id = r.order_id
where c.exculusions is not null and c.extras is not null and r.cancellation is not null
---------------------------------------------------------

-- (9) What was the total volume of pizzas ordered for each hour of the day?
select DATEPART(hour, c.order_time) as total_hours, count(c.pizza_id) as pizza_volumn
from #customer_order_temp c
group by DATEPART(hour, c.order_time)
---------------------------------------------------------

-- (10) What was the volume of orders for each day of the week?
select DATEname(WEEKDAY, c.order_time) as weekdayy, count(c.order_id) as order_volumn
from #customer_order_temp c
group by DATEname(WEEKDAY, c.order_time)
---------------------------------------------------------
---------------------------------------------------------


-- B. Runner and Customer Experience --

-- (1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select count(runner_id) as reunner_signed, dATEPART(week, registration_date) as week_signed
from runners
group by dATEPART(week, registration_date)
---------------------------------------------------------

-- (2) What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select r.runner_id, avg(datediff(MINUTE,  c.order_time , r.pickup_time)) as arrive_time
from #runner_order_temp r
join #customer_order_temp c on r.order_id = c.order_id
group by r.runner_id
---------------------------------------------------------

-- (3) Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte as (
select c.order_id, count(c.order_id) as pizza_number, 
avg(DATEDIFF(MINUTE, c.order_time , r.pickup_time)) as prepare_time
from #customer_order_temp c
join #runner_order_temp r on r.order_id = c.order_id
where r.cancellation is null
group by c.order_id
)
select order_id, pizza_number, prepare_time, avg(prepare_time / pizza_number) as time_per_pizza
from cte
group by pizza_number, prepare_time,order_id
order by pizza_number
---------------------------------------------------------

-- (4) What was the average distance travelled for each customer?
select c.customer_id, round(avg(r.distance), 1) as distance
from #customer_order_temp c
join #runner_order_temp r on r.order_id = c.order_id
group by c.customer_id
---------------------------------------------------------

-- (5) What was the difference between the longest and shortest delivery times for all orders?
with cte as (
select r.order_id, avg(datediff(MINUTE,  c.order_time , r.pickup_time)) as arrive_time
from #runner_order_temp r
join #customer_order_temp c on r.order_id = c.order_id
group by r.order_id
)

select max(arrive_time) as longest_time, min(arrive_time) as shortest_time,
(max(arrive_time) - min(arrive_time)) as diffrence_time

from cte
---------------------------------------------------------

-- (6) What was the average speed for each runner for each delivery and do you notice any trend for these values?
select r.runner_id, r.order_id, round((r.distance/r.duration*60),1) as speed
from #runner_order_temp r
where r.cancellation is null
order by r.runner_id
---------------------------------------------------------

-- (7) What is the successful delivery percentage for each runner?
select r.runner_id, count(r.pickup_time) /  count(order_id)* 100 as successful_delivery
from #runner_order_temp r
group by r.runner_id
---------------------------------------------------------
---------------------------------------------------------


-- C. Ingredient Optimisation --

-- (1) What are the standard ingredients for each pizza?
-- Here we encountered a problem, and to solve the problem, we have two solutions
-- We normalize Pizza_recipes in a new table
-- Or create another temporary table from Pizza_recipes and create a split for the toppings column
-- We created a temporary table above in the Data Cleaning pane
with cte as (
select pn.pizza_name, pt.topping_name
from pizza_names pn
join #pizza_recipes_temp pr on pn.pizza_id = pr.pizza_id
join pizza_toppings pt on pr.topping_id = pt.topping_id
)

select pizza_name, string_agg(topping_name, ',') as topping
from cte
group by pizza_name
---------------------------------------------------------

-- (2) What was the most commonly added extra?
with cte as (
select value as extra
from #customer_order_temp c
CROSS APPLY  string_split(c.extras, ',')
)
select count(extra) as cextra_namuber, pt.topping_name
from cte 
join pizza_toppings pt on pt.topping_id = cte.extra
group by extra, pt.topping_name
---------------------------------------------------------

-- (3) What was the most common exclusion?
with cte as (
select value as exclusions
from #customer_order_temp c
CROSS APPLY string_split(c.exculusions, ',')
)
select count(exclusions) as exclusions_namuber, pt.topping_name
from cte 
join pizza_toppings pt on pt.topping_id = cte.exclusions
group by exclusions, pt.topping_name
order by exclusions_namuber desc
---------------------------------------------------------

-- (4) Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
with cte1 as (
select t.record_id , t.order_id, ' Extra ' + pt.topping_name as record
from #extra_temp t
join pizza_toppings pt on t.extra = pt.topping_id
)
,
cte2 as (
select s.record_id, s.order_id, ' Exclude ' + pt.topping_name as record
from #exculusions_temp s
join pizza_toppings pt on s.exculusions = pt.topping_id
)
,
cte3 as (
select * from cte1
union 
select * from cte2
)

select c.record_id, c.order_id, c.customer_id, CONCAT_WS(' ' , pn.pizza_name, STRING_AGG(cte3.record, ' - ')) as information
from #customer_order_temp c
left join cte3 on c.record_id = cte3.record_id
join pizza_names pn on pn.pizza_id = c.pizza_id
group by c.order_id, c.customer_id, pn.pizza_name, c.record_id
order by c.order_id
---------------------------------------------------------

-- (5) Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
with cte as (
select c.record_id, c.order_id, c.customer_id, c.pizza_id, pn.pizza_name,
case when pr.topping_id in ( select extra from #extra_temp e where c.record_id = e.record_id) then '2x' + pt.topping_name else pt.topping_name end as topping
from #customer_order_temp c
join pizza_names pn on c.pizza_id = pn.pizza_id
join #pizza_recipes_temp pr on c.pizza_id = pr.pizza_id
join pizza_toppings pt on pr.topping_id = pt.topping_id
WHERE pr.topping_id NOT IN (SELECT s.exculusions from #exculusions_temp s WHERE c.record_id = s.record_id)
)

select record_id, pizza_name, order_id, pizza_id,customer_id, CONCAT(pizza_name + ':' + ' ' , STRING_AGG(topping, ', ')) AS ingredients_list
from cte
group by pizza_name, order_id, pizza_id, customer_id, record_id
order by order_id
---------------------------------------------------------

-- (6) What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
with cte as (
select c.record_id, pt.topping_name, pn.pizza_name,
case when pr.topping_id in ( select extra from #extra_temp e where c.record_id = e.record_id) then 2 else 1 end as used_topping_number
from #customer_order_temp c
join pizza_names pn on c.pizza_id = pn.pizza_id
join #pizza_recipes_temp pr on c.pizza_id = pr.pizza_id
join pizza_toppings pt on pr.topping_id = pt.topping_id
join #runner_order_temp r on c.order_id = r.order_id
WHERE pr.topping_id NOT IN (SELECT s.exculusions from #exculusions_temp s WHERE c.record_id = s.record_id and r.cancellation is NULL )
)

select topping_name, sum(used_topping_number) as used_topping_number
from cte
group by topping_name
order by used_topping_number desc
---------------------------------------------------------
---------------------------------------------------------


-- D. Pricing and Ratings --

-- (1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
with cte as ( 
select case when c.pizza_id = 1 then 10 else 20 end as total_revenue
from #customer_order_temp c
join #runner_order_temp r on r.order_id = c.order_id
where r.cancellation is null
)
select sum(total_revenue) as total_revenue
from cte
---------------------------------------------------------

-- (2) What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
with cte1 as ( 
select x.extra,
case when c.pizza_id = 1 then 10 else 20 end as total_revenue
from #customer_order_temp c
join #runner_order_temp r on r.order_id = c.order_id
join #extra_temp x on x.order_id = c.order_id
where r.cancellation is null
),
cte2 as(
select extra, sum(total_revenue) as total_revenue from cte1
group by extra
),
cte3 as(
select case when extra is null then total_revenue
            when DATALENGTH(extra) = 1 then total_revenue + 1 
			else total_revenue + 2 end as total_earn 
from cte2
)

select sum(total_earn) as total_earn from cte3
---------------------------------------------------------

-- (3) The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
create table rating (
order_id int, rate int
)
insert into rating values
(1,5), (2,5),(3,2),(4,4),(5,1),(6,3),(7,4), (8,1),(9,3),(10,5)

select * from rating
---------------------------------------------------------

-- (4) Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id / order_id / runner_id / rating / order_time / pickup_time / Time between order and pickup / Delivery duration / Average speed / Total number of pizzas
select r.order_id, r.runner_id, r.pickup_time, c.customer_id,c.order_time, t.rate, r.duration,
DATEPART(minute, c.order_time - r.pickup_time ) total,
round(avg(r.distance/r.duration * 60),1) as speed,
count(c.pizza_id) as total_pizzas
from #runner_order_temp r
join #customer_order_temp c on r.order_id = c.order_id
join rating t on t.order_id = r.order_id
where r.cancellation is null
group by r.order_id, r.runner_id, r.pickup_time, c.customer_id,c.order_time, t.rate, r.duration
---------------------------------------------------------

-- (5) If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
with cte as ( 
select c.order_id, r.distance
,sum(case when c.pizza_id = 1 then 12 else 10 end )as total_revenue
from #customer_order_temp c
join #runner_order_temp r on r.order_id = c.order_id
where r.cancellation is null
group by c.order_id, r.distance, c.pizza_id
)
select sum(total_revenue) as total_revenue, sum(distance)*0.3 as cost_runner,
(sum(total_revenue)) - (sum(distance)*0.3) as final_gain
from cte
---------------------------------------------------------
---------------------------------------------------------


-- E. Bonus Questions --
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
insert into pizza_names
(pizza_id, pizza_name)
values (3, ' Supreme ' )

insert into pizza_recipes
(pizza_id, toppings)
values (3, '1,2,3,4,5,6,7,8,9,10,11,12')

select * from pizza_recipes





-- End of Case Study #1 - Danny's Diner

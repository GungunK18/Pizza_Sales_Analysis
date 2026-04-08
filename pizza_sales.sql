-- creating database
create database pizza_sales;
use pizza_sales;
-- creating tables for larger dataset (orders and order_details table)
-- smaller tables like pizza and pizza_types are directly imported
CREATE TABLE orders (
    order_id INT PRIMARY KEY NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);
SELECT 
    *
FROM
    orders;
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY NOT NULL,
    order_id INT NOT NULL,
    pizza_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL
);

-- Q_1:Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_number_of_orders
FROM
    orders;
-- Q_2:Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
-- Q-3:Identify the highest-priced pizza
SELECT 
    name
FROM
    pizzas p1
        JOIN
    pizza_types p2 ON p2.pizza_type_id = p1.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q_4:Identify the most common pizza size ordered
SELECT 
    size AS most_common_size
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY COUNT(quantity) DESC
LIMIT 1;

-- Q 5:List the top 5 most ordered pizza types along with their quantities
SELECT 
    name, SUM(quantity) AS quantity
FROM
    order_details o
        JOIN
    pizzas p1 ON o.pizza_id = p1.pizza_id
        JOIN
    pizza_types p2 ON p1.pizza_type_id = p2.pizza_type_id
GROUP BY name
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- Q-6: Join the necessary tables to find the total quantity of each pizza category ordered
SELECT 
    category, SUM(quantity) AS quantity
FROM
    pizzas p1
        JOIN
    order_details o ON o.pizza_id = p1.pizza_id
        JOIN
    pizza_types p2 ON p1.pizza_type_id = p2.pizza_type_id
GROUP BY category
ORDER BY category DESC;

-- Q-7: Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS no_of_orders
FROM
    orders
GROUP BY hours
ORDER BY hours DESC;

-- Q-8: Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS number_of_pizzas
FROM
    pizza_types
GROUP BY category
ORDER BY number_of_pizzas DESC;
-- Q-9 : Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0) AS pizzas_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders o1
    JOIN order_details o2 ON o1.order_id = o2.order_id
    GROUP BY order_date) AS temp;
    
-- Q-10: Determine the top 3 most ordered pizza types based on revenue
SELECT 
    name, SUM(price * quantity) AS revenue
FROM
    pizzas p1
        JOIN
    pizza_types p2 ON p1.pizza_type_id = p2.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p1.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- Q-11: Calculate the percentage contribution of each pizza type to total revenue
with cte as (select category,sum(price*quantity) as revenue from pizzas p1
join pizza_types p2
on p1.pizza_type_id=p2.pizza_type_id
join order_details o 
on o.pizza_id=p1.pizza_id
group by category)
select category,concat(round((revenue/(select sum(revenue) from cte))*100,2),' %') as percentage_revenue from cte
order by percentage_revenue desc;

-- Q-12: Analyze the cumulative revenue generated over time
set @revenue_till_date:=0;
with cte as (
select order_date,sum(price*quantity) as revenue from  pizzas p1
join pizza_types p2
on p1.pizza_type_id=p2.pizza_type_id
join order_details o1
on o1.pizza_id=p1.pizza_id
join orders o2
on o1.order_id=o2.order_id
group by order_date
)
select order_date,revenue,(@revenue_till_date:=revenue+@revenue_till_date) as total_revenue_till_date from cte;

-- Q-13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as(select  category,name, sum(price*quantity) as revenue ,dense_rank() over (partition by category order by sum(price*quantity) desc) as dr
 from pizzas p1
 join pizza_types p2
 on p1.pizza_type_id=p2.pizza_type_id
 join order_details o 
 on o.pizza_id=p1.pizza_id
 group by name,category
 order by category,revenue desc)
 select category as Category,name as Name,round(revenue,2) as Revenue from cte where dr<=3;
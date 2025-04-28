use pizzahut;
-- retrive the total number of orders placed
select count(order_id)as total_orders from orders;

-- calculate the total revenue generated from pizza sales 
SELECT 
   round (sum(order_details.quantity * pizzas.price),
   2)
            AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    
    -- identify the highest priced pizza 
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

--  identify the most common pizza size ordered
SELECT 
    pizzas.size,
    sum(order_details.quantity) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- list the top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5; 


-- join the necessary tables to find the
-- total quantity of each pizza category ordered
select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity;


-- determine the distribution of ordersby hour of the day
select hour(order_time),count(order_id)from orders as order_count
group by hour(order_time);


-- join relevant tables to find the catrgory wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;


-- group theorders by date and calculate the average number of pizzas ordered per day
select round(avg(quantity),0) as avg_pizza_ordered_per_day
from
(select orders.order_date, sum(order_details.quantity)as quantity
from orders
join order_details on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;


-- determine the top 3 most ordered pizza types based on revenue
select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;


-- calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category,
round(sum(order_details.quantity * pizzas.price)/ (select
round(sum(order_details.quantity * pizzas.price),2) as total_sales
from
order_details 
join
pizzas on pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc ;


-- analyze the cumulative revenue generated over time
select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- determine the top 3 most ordered pizza types based on revenue for each pizza category
select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from

(select pizza_types.category,pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as A) as b;

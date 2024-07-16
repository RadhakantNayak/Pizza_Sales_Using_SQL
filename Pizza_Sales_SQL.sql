-- 1.Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) Total_order
FROM
    orders;
    
-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    round(sum(order_details.quantity * pizzas.price),2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3.Identify the highest-priced pizza.

SELECT 
    pizza_id, price AS highest_price_pizza
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;

-- 4.Identify the most common pizza size ordered.

SELECT 
    pizzas.size, SUM(order_details.quantity) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_Qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    DATE_FORMAT(orders.time, '%H') AS Order_hour,
    count(order_id) Total_Coount
FROM
    orders
GROUP BY Order_hour
ORDER BY Order_hour;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(category)
FROM
    pizza_types
GROUP BY category;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

CREATE VIEW Date_WIse_Order_Quantity AS
    SELECT 
        orders.date, SUM(order_details.Quantity) Sum_Quantity
    FROM
        orders
            JOIN
        order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date;
    
SELECT 
    round(AVG(sum_quantity),0) AS Date_Wise_Avg_Order
FROM
    Date_WIse_Order_Quantity;
    
-- 10.Determine the top 3 most ordered pizza types based on revenue.

create view  Vw_Pizza_Type_id as   # Created a view on the basis of Pizza_Type 
SELECT 
    pizzas.pizza_type_id,
    COUNT(order_details.quantity) AS Order_count,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) Total_Revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.pizza_type_id;


SELECT   # Retrived from view 
    *
FROM
    Vw_pizza_type_id
ORDER BY Total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

CREATE VIEW Vw_TotalRevenue AS
    SELECT 
        SUM(order_details.quantity * pizzas.price) AS Total_Revenue
    FROM
        order_details
            JOIN
        pizzas ON order_details.pizza_id = pizzas.pizza_id;
        
        
SELECT 
    pizza_type_id,
    Total_Revenue AS Type_Wise_Revenue,
    ROUND(Total_Revenue / (SELECT 
                    *
                FROM
                    vw_totalrevenue) * 100,
            2) AS Percentage
FROM
    vw_pizza_type_id order by Percentage desc;
    
-- 12. Analyze the cumulative revenue generated over time.

CREATE VIEW Vw_DateWise_Revenue AS
    SELECT 
        orders.date,
        round(sum(order_details.quantity * pizzas.price),2) Todays_Sale_Price
    FROM
        orders
            JOIN
        order_details ON orders.order_id = order_details.order_id
            JOIN
        pizzas ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY orders.date;
    
select 
	date,
    Todays_sale_price,
    round(sum(todays_sale_price) over( order by date),2) as cumulative_Revenue 
from vw_datewise_revenue;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select pizza_types.category,pizza_types.name,pizza_types.pizza_type_id, sum(order_details.quantity)  over(partition by pizza_types.pizza_type_id) as Quantity,
sum(order_details.quantity*pizzas.price) over(partition by pizza_types.pizza_type_id )as Revenue  from pizza_types join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on pizzas.pizza_id = order_details.pizza_id;



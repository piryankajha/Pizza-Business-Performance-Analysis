-- ==========================================================
-- Project: Pizza Sales Analysis (MySQL)
-- Database: pizzas
-- Description: Basic, Intermediate, and Advanced SQL queries
--              for analyzing pizza sales data.
-- Author: Priyanka Jha
-- ==========================================================

-- ------------------------------
-- Database Selection
-- ------------------------------
USE pizzas;


-- ==========================================================
-- BASIC ANALYSIS
-- ==========================================================

-- 1. Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders 
FROM orders;


-- 2. Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM order_details od
JOIN pizzas p 
    ON p.pizza_id = od.pizza_id;


-- 3. Identify the highest-priced pizza
SELECT 
    pt.name AS pizza_name, 
    p.price
FROM pizza_types pt
JOIN pizzas p 
    ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered
SELECT 
    p.size, 
    COUNT(od.order_details_id) AS order_count
FROM pizzas p
JOIN order_details od 
    ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;


-- 5. List the top 5 most ordered pizza types along with their quantities
SELECT 
    pt.name AS pizza_name, 
    SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p 
    ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od 
    ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- ==========================================================
-- INTERMEDIATE ANALYSIS
-- ==========================================================

-- 6. Determine the distribution of orders by hour of the day
SELECT 
    HOUR(time) AS order_hour, 
    COUNT(order_id) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;


-- 7. Find the category-wise distribution of pizzas
SELECT 
    category, 
    COUNT(name) AS pizza_count
FROM pizza_types
GROUP BY category;


-- 8. Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pt.name AS pizza_name,
    SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p 
    ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od 
    ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


-- ==========================================================
-- ADVANCED ANALYSIS
-- ==========================================================

-- 9. Calculate the percentage contribution of each pizza category to total revenue
SELECT 
    pt.category,
    ROUND(
        SUM(od.quantity * p.price) 
        / (
            SELECT SUM(od2.quantity * p2.price)
            FROM order_details od2
            JOIN pizzas p2 
                ON p2.pizza_id = od2.pizza_id
        ) * 100, 2
    ) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p 
    ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od 
    ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;


-- 10. Analyze the cumulative revenue generated over time
SELECT 
    order_date,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        o.date AS order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    JOIN pizzas p 
        ON p.pizza_id = od.pizza_id
    GROUP BY o.date
) revenue_by_date;


-- 11. Determine the top 3 most ordered pizza types based on revenue for each category
SELECT 
    category,
    pizza_name,
    revenue
FROM (
    SELECT 
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_in_category
    FROM pizza_types pt
    JOIN pizzas p 
        ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od 
        ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
) ranked_pizzas
WHERE rank_in_category <= 3
ORDER BY category, revenue DESC;

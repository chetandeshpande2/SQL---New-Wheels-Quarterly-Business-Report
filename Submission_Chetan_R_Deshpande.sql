use New_Wheels;

SELECT * FROM customer_t;
SELECT * FROM order_t;
SELECT * FROM product_t;
SELECT * FROM shipper_t;


#/*-- QUESTIONS RELATED TO CUSTOMERS

# [Q1] What is the distribution of customers across states?
     
SELECT state, count(*) AS no_of_customers
FROM customer_t
GROUP BY state
ORDER BY no_of_customers DESC;


# [Q2] What is the average rating in each quarter?

SELECT YEAR(order_date) AS year, quarter_number AS quarter, AVG(case 
	WHEN customer_feedback = 'very bad' THEN 1
	WHEN customer_feedback = 'bad' THEN 2
	WHEN customer_feedback = 'okay' THEN 3
	WHEN customer_feedback = 'good' THEN 4
	WHEN customer_feedback = 'very good' THEN 5
  end) AS rating FROM order_t
GROUP BY year, quarter;


# [Q3] Are customers getting more dissatisfied over time? 
   
SELECT YEAR(order_date) AS year, quarter_number AS quarter, 
(SUM(CASE WHEN customer_feedback IN ('Very Good') THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS good_feedback
FROM order_t
GROUP BY year, quarter
ORDER BY year, quarter;
      
      
      
# [Q4] Which are the top 5 vehicle makers preferred by the customer?	

SELECT p.vehicle_model, COUNT(o.customer_id) AS customer_count
FROM product_t p
JOIN order_t o ON p.product_id = o.product_id
GROUP BY p.vehicle_model
ORDER BY customer_count DESC
LIMIT 5;
		
        
# [Q5] What is the most preferred vehicle make in each state?

SELECT state, vehicle_maker FROM (select c.state AS state, p.vehicle_maker AS vehicle_maker,
RANK() OVER (PARTITION BY c.state ORDER BY COUNT(c.customer_id) DESC) AS r
FROM customer_t c
 JOIN
	order_t o ON c.customer_id = o.customer_id
 JOIN
	product_t p ON o.product_id = p.product_id
GROUP BY c.state, p.vehicle_maker) rank_data
WHERE r = 1;
        

/*QUESTIONS RELATED TO REVENUE and ORDERS 

[Q6] What is the trend of number of orders by quarters? */

SELECT
    YEAR(order_date) AS year,
    QUARTER(order_date) AS quarter,
    COUNT(*) AS num_orders
FROM order_t
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY year, quarter;
    

# [Q7] What is the quarter over quarter % change in revenue? */

WITH QuarterRevenue AS (
    SELECT
        quarter_number AS quarter,
        SUM(vehicle_price) AS total_revenue
    FROM order_t
    GROUP BY quarter
),
QuarterlyChange AS (
    SELECT
        quarter,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY quarter) AS prev_total_revenue
    FROM QuarterRevenue
)
SELECT
    qr1.quarter,
    qr1.total_revenue,
    qr2.total_revenue AS prev_total_revenue,
    CASE
        WHEN qr2.total_revenue <> 0 THEN ((qr1.total_revenue - qr2.total_revenue) * 100.0 / qr2.total_revenue)
        ELSE NULL
    END AS qoq_percentage_change
FROM QuarterlyChange qr1
JOIN
    QuarterlyChange qr2 ON qr1.quarter = qr2.quarter + 1;
    
    
# [Q8] What is the trend of revenue and orders by quarters? */

SELECT
    year(order_date) as year,
    quarter(order_date) as quarter,
    COUNT(*) AS order_count,
    SUM(vehicle_price) AS total_revenue
FROM order_t
GROUP BY year, quarter
ORDER BY year, quarter;


/* QUESTIONS RELATED TO SHIPPING 

[Q9] What is the average discount offered for different types of credit cards? */

SELECT credit_card_type, AVG(o.discount) AS average_discount
FROM customer_t c
JOIN
	order_t o ON c.customer_id = o.customer_id
GROUP BY c.credit_card_type;


# [Q10] What is the average time taken to ship the placed orders for each quarters? */

SELECT
    year(order_date) as year,
    quarter(order_date) as quarter,
    AVG(DATEDIFF(ship_date, order_date)) AS avg_shipping_time
FROM order_t
GROUP BY year, quarter
ORDER BY year, quarter;
    
--
--
 
#Total Revenue
SELECT SUM(vehicle_price) AS Total_Revenue FROM order_t;

#Total Orders
SELECT COUNT(order_id) AS Total_Orders FROM order_t;

#Total Customers
SELECT COUNT(customer_id) AS Total_Customers FROM order_t;

#Average Rating
SELECT YEAR(order_date) AS year,
    AVG(CASE
        WHEN customer_feedback = 'Very Bad' THEN 1
        WHEN customer_feedback = 'Bad' THEN 2
        WHEN customer_feedback = 'Okay' THEN 3
        WHEN customer_feedback = 'Good' THEN 4
        WHEN customer_feedback = 'Very Good' THEN 5
    END) AS average_rating
FROM order_t
GROUP BY year;

#Average Time to Ship
SELECT AVG(DATEDIFF(ship_date, order_date)) AS avg_time_to_ship
FROM order_t;
    
#Top Selling Car
SELECT p.vehicle_model, SUM(o.quantity) AS total_units_sold
FROM product_t p
JOIN
    order_t o ON p.product_id = o.product_id
GROUP BY p.vehicle_model
ORDER BY total_units_sold DESC
LIMIT 1;

# % Good Feedback
SELECT  year(order_date) AS year, 
(SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS good_feedback_percentage
FROM order_t
GROUP BY year(order_date);


    
    



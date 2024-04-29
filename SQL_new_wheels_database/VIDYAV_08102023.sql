/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
USE new_wheels;  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
SELECT 
	state as State, 
    count(customer_id) as Customer_Distribution
FROM customer_t
GROUP BY State
ORDER BY Customer_Distribution DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. -- ---------------------------------------------------------------------------------------------------------------------------------*/
WITH order_rating AS(
SELECT *,
    CASE 
		WHEN upper(customer_feedback) = 'VERY BAD' THEN 1
		WHEN upper(customer_feedback) = 'BAD' THEN 2
		WHEN upper(customer_feedback) = 'OKAY' THEN 3
		WHEN upper(customer_feedback) = 'GOOD' THEN 4
		WHEN upper(customer_feedback) = 'VERY GOOD' THEN 5
    END AS Rating
FROM order_t)

SELECT quarter_number as Quarter_Number, round(avg(Rating),2) as Avg_rating
FROM order_rating
GROUP BY Quarter_Number
ORDER BY Quarter_Number;
    

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
-- ---------------------------------------------------------------------------------------------------------------------------------*/
WITH categorywise_feedback AS(
SELECT 
	quarter_number as Qtr_number,
    customer_feedback,
    count(customer_feedback) as Category_feedback_count 
from order_t
GROUP BY Qtr_number, customer_feedback
ORDER BY quarter_number),

quarterwise_feedback AS(
SELECT
	Qtr_Number,
    sum(Category_feedback_count) as Total_feedback_count
FROM categorywise_feedback
GROUP BY Qtr_Number)

SELECT 
	q.Qtr_Number,
    c.customer_feedback,
    c.Category_feedback_count,
    q.Total_feedback_count,
    round(((Category_feedback_count / Total_feedback_count)*100),2) as Feedback_Percentage
FROM 
	quarterwise_feedback q
JOIN 
	categorywise_feedback c
USING(Qtr_Number);
    

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT 
	p.vehicle_maker, 
    count(o.order_id) as Number_of_orders
FROM 
	product_t p
JOIN 
	order_t o
USING(product_id)
GROUP BY p.vehicle_maker
ORDER BY Number_of_orders DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

WITH customer_order_product AS(
SELECT 
	c.state as State, 
    p.vehicle_maker as Make, 
    count(o.order_id) as No_of_Orders
FROM
	customer_t c 
JOIN 
	order_t o
ON 
	c.customer_id=o.customer_id
JOIN
	product_t p
ON
	o.product_id=p.product_id
GROUP BY State, Make
ORDER BY State),
make_order_rank AS(
SELECT State, Make, No_of_Orders,
RANK() OVER(PARTITION BY State ORDER BY No_of_Orders DESC) as Rnk
FROM customer_order_product)

SELECT State, Make, No_of_Orders 
FROM make_order_rank
WHERE Rnk=1;



-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/
SELECT
	quarter_number as Qtr,
    count(order_id) as Number_of_Orders
FROM
	order_t
GROUP BY Qtr
ORDER BY Qtr;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
WITH qtr_revenue_tb AS(
SELECT 
	quarter_number as Qtr,
	sum((vehicle_price * quantity)) as Qtr_Revenue
FROM
	order_t
GROUP BY Qtr	
ORDER BY Qtr)

SELECT Qtr,
Qtr_Revenue,
round((((Qtr_Revenue-LAG(Qtr_Revenue)OVER(ORDER BY Qtr))/(LAG(Qtr_Revenue)OVER(ORDER BY Qtr)))*100),2) as QoQ_percentage_change_in_Revenue
FROM qtr_revenue_tb
GROUP BY Qtr
ORDER BY Qtr;
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT 
	quarter_number as Qtr,
    count(order_id) as Number_of_Orders,
	sum((vehicle_price * quantity)) as Qtr_revenue
FROM
	order_t
GROUP BY Qtr
ORDER BY Qtr;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/
SELECT 
	c.credit_card_type as Card_type,
    round(avg(o.discount),3) as Avg_Discount
FROM
	order_t o
JOIN
	customer_t c
USING(customer_id)
GROUP BY Card_type
ORDER BY Avg_Discount DESC;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
SELECT
	quarter_number as Qtr,
	round(AVG(DATEDIFF(ship_date,order_date)),2) as Avg_days_for_shipment
FROM order_t
GROUP BY Qtr
ORDER BY Qtr;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM
	customer_t c
JOIN
	order_t o
ON
	c.customer_id=o.customer_id
JOIN
	product_t p
ON
	o.product_id=p.product_id
JOIN
	shipper_t s
ON 
	s.shipper_id=o.shipper_id;
    
SELECT DISTINCT state from customer_t
ORDER BY state;


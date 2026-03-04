CREATE DATABASE Walmartsales;
USE Walmartsales;

CREATE TABLE sales(
  Invoice_id VARCHAR(30) NOT NULL,
  Branch VARCHAR(5) NOT NULL,
  City VARCHAR(30) NOT NULL,
  Customer_type VARCHAR(30) NOT NULL,
  Gender VARCHAR(10) NOT NULL,
  Product_line VARCHAR(100) NOT NULL,
  Unit_price DECIMAL(10,2) NOT NULL,
  Quantity INT NOT NULL,
  VAT DECIMAL(6,4) NOT NULL,
  Total DECIMAL(12,4),
  Date DATETIME NOT NULL,
  time TIME NOT NULL,
  Payment_method VARCHAR(15) NOT NULL,
  Cogs DECIMAL(10,2) NOT NULL,
  Gross_margin_pct DECIMAL(11,9) NOT NULL,
  Gross_income DECIMAL(12,4) NOT NULL,
  Rating DECIMAL(2,1) NOT NULL
);

SELECT Count(*) FROM sales;

-- -----------------------------------------------------------------------------------------------------------------
-- ----------------------------------FUTURE ENGINEERING-----------------------------------------------------------------------------------
-- Time_of_day
SELECT 
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day=(
CASE
	WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
	ELSE 'Evening'
END
);

SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

-- Day_name
SELECT 
    date, DAYNAME(date) AS Day_name
FROM
    sales;
    
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales 
SET 
    Day_name = DAYNAME(date);

-- Month_name

SELECT 
    date, MONTHNAME(date)
FROM
    sales;
ALTER TABLE sales ADD COLUMN Month_name VARCHAR(10);
UPDATE sales 
SET 
    Month_name = MONTHNAME(date);
-- --------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------Generic Question-----------------------------------------------------------------
-- How many unique cities does the data have?
SELECT DISTINCT
    city
FROM
    sales;

-- In which city is each branch?
SELECT DISTINCT
    branch
FROM
    sales;
SELECT DISTINCT
    city, branch
FROM
    sales;

-- ----------------------------------------Product---------------------------------------------------------------------------
-- How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;
SELECT COUNT(DISTINCT product_line) FROM sales;

-- What is the most common payment method?
SELECT DISTINCT
    payment_method
FROM
    sales;
    
SELECT 
    payment_method, COUNT(payment_method) AS cnt
FROM
    sales
GROUP BY payment_method
ORDER BY cnt DESC;
 
 -- What is the most selling product line?
SELECT DISTINCT
    product_line, COUNT(product_line) AS Popular_product
FROM
    sales
GROUP BY product_line
ORDER BY Popular_product DESC;
 
 -- What is the city with the largest revenue?
 SELECT 
    city, SUM(total) AS Largest_revenue
FROM
    sales
GROUP BY city
ORDER BY Largest_revenue DESC;

 -- What is the total revenue by month?
 SELECT 
    month_name AS Month, SUM(total) AS Total_Revenue
FROM
    sales
GROUP BY month
ORDER BY total_Revenue DESC;

-- Classify each product line as 'Good' or 'Bad' based on average sales.
SELECT 
    product_line,
    AVG(total) AS Avg_sales,
    CASE
        WHEN
            AVG(total) > (SELECT 
                    AVG(total)
                FROM
                    sales)
        THEN
            'GOOD'
        ELSE 'BAD'
    END AS Performanance
FROM
    sales
GROUP BY product_line;

-- Retrieve the top three products by total revenue within each city.
WITH city_product_revenue AS (
    SELECT 
        city,
        product_line,
        SUM(total) AS total_revenue
    FROM sales
    GROUP BY city, product_line
)

SELECT *
FROM (
    SELECT 
        city,
        product_line,
        total_revenue,
        RANK() OVER (
            PARTITION BY city 
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM city_product_revenue
) ranked_data
WHERE revenue_rank <= 3
ORDER BY city, revenue_rank ;

-- Which branch sold more products than average product sold?
SELECT branch, total_products
FROM (
    SELECT 
        branch,
        SUM(quantity) AS total_products,
        AVG(SUM(quantity)) OVER() AS avg_products
    FROM sales
    GROUP BY branch
) t
WHERE total_products > avg_products;

--------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------Sales-----------------------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday
SELECT 
    time_of_day, COUNT(*) AS Total_sales
FROM
    sales
WHERE
    day_name = 'Saturday'
GROUP BY time_of_day
ORDER BY Total_sales DESC;

-- Which city has the largest VAT percent?
SELECT 
    city, ROUND(AVG(VAT), 2) AS avg_VAT
FROM
    sales
GROUP BY city
ORDER BY avg_VAT DESC;

-- Which of the customer types brings the most revenue?
SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    sales
GROUP BY customer_type
ORDER BY total_revenue;

------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------ Customers------------------------------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- What is the most common customer type?
SELECT 
    customer_type, COUNT(*) AS count
FROM
    sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which time of the day do customers give most ratings per branch?
 WITH rating_counts AS (
    SELECT 
        branch,
        time_of_day,
        COUNT(rating) AS total_ratings
    FROM sales
    GROUP BY branch, time_of_day
)
SELECT branch, time_of_day, total_ratings
FROM (
    SELECT 
        branch,
        time_of_day,
        total_ratings,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY total_ratings DESC
        ) AS rating_rank
    FROM rating_counts
) ranked_data
WHERE rating_rank = 1;

-- -- Which day fo the week has the best avg ratings?
SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC;

SHOW DATABASES;

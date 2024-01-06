-- count the number of sales 
SELECT COUNT(*)
FROM sales;

-- calculate the total number of unit sales the company has done 
-- for each state
	-- get state, show total amount in state
SELECT c.state, SUM(s.sales_amount) as total_sales_amount
	-- sales data in sales table
FROM sales as s
	-- combine sales table with customer table
INNER JOIN customers as c ON c.customer_id = s.customer_id
GROUP BY 1 
ORDER BY 1;

-- Identify the top 5 best dealerships in terms of the most units
-- sold 
	-- identify who, then get units sold
SELECT s.dealership_id, COUNT(*) as units_sold 
	-- data from sales table
FROM sales AS s
	-- exclude internet sales
WHERE channel = 'dealership'
	-- our groups are based on WHO or the ID of the dealer
GROUP BY 1
	-- top 5 so we need to sort descending thus use DESC
ORDER BY 2 DESC
	-- To ensure the top 5 are shown 
LIMIT 5;

-- average sales amount for each channel, as seen in the sales 
-- table, and look at the average sales amount FIRST by channel
-- sales, THEN by product_id, and then by both together 
SELECT s.channel, AVG(s.sales_amount) as avg_sales_amount
FROM sales s
GROUP BY 
GROUPING SETS(
(s.channel), (s.product_id),
(s.channel, s.product_id)
)
ORDER BY 1, 2;


SELECT 
-- step 5 
customers.*, 
products.*,

-- step 6 
COALESCE(sales.dealership_id, - 1),

-- step 7 
CASE WHEN 
	products.base_msrp - sales.sales_amount > 500 
	THEN 1 ELSE 0 END AS high_savings
FROM customers
-- step 2 
INNER JOIN sales ON customers.customer_id = sales.customer_id

-- step 3 
INNER JOIN products ON products.product_id = sales.product_id

-- step 4
LEFT JOIN dealerships ON dealerships.dealership_id = sales.dealership_id;
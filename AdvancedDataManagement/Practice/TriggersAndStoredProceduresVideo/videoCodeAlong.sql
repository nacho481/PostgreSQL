-- ========== CREATE TABLE large_sales ==========

CREATE TABLE IF NOT EXISTS large_sales (
	channel VARCHAR(30),
	customer_id bigint,
	sales_amount float
);


-- ========== Insert Data into large_sales ==========
INSERT INTO large_sales
(SELECT channel, customer_id, sales_amount 
FROM sales
WHERE sales_amount > 100000
ORDER BY sales_amount DESC);

SELECT * FROM large_sales LIMIT 20; 

-- ========== CREATE TABLE large_sales_by_channel ==========
CREATE TABLE IF NOT EXISTS large_sales_by_channel (
	channel VARCHAR(30),
	number_of_sales BIGINT
);

-- ========== INSERT INTO large_sales_by_channel ==========
INSERT INTO large_sales_by_channel
SELECT channel, COUNT(customer_id)
FROM large_sales
GROUP BY channel; 

	-- check data  	
SELECT * FROM large_sales_by_channel;

-- ========== TRIGGER function - detect inserts ==========

-- When you're editing functions you need to do it a bunch of
-- times vs having to drop it
CREATE OR REPLACE FUNCTION insert_trigger_function()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
	-- we want to update our large sales by channel table easiest way is to delete the table, and reinsert all + new data
	-- clear data from this table 
	DELETE FROM large_sales_by_channel;
	INSERT INTO large_sales_by_channel
		SELECT channel, COUNT(customer_id)
		FROM large_sales
		GROUP BY channel;
	
	RETURN NEW;
END;
$$

-- ========== TRIGGER - to detect inserts ==========
CREATE TRIGGER new_large_sale 
	AFTER INSERT
	ON large_sales
	FOR EACH STATEMENT
	EXECUTE PROCEDURE insert_trigger_function();
	-- count how many records there are in each table before inserting 
SELECT COUNT(*) FROM large_sales;
SELECT SUM(number_of_sales) FROM large_sales_by_channel;

	-- insert data 
INSERT INTO large_sales VALUES('call center', 57, 125000);

	-- count how many records there are in each table after inserting
SELECT COUNT(*) FROM large_sales;
SELECT SUM(number_of_sales) FROM large_sales_by_channel;
	-- observe results 
SELECT * FROM large_sales_by_channel; 

-- ========== CREATE TRIGGER FUNCTION - on update ==========
-- update our large sales by channel 
CREATE OR REPLACE FUNCTION update_trigger_function()
RETURNS TRIGGER 
LANGUAGE PLPGSQL
AS $$
BEGIN 
	DELETE FROM large_sales_by_channel;
	INSERT INTO large_sales_by_channel
	SELECT channel, COUNT(customer_id)
	FROM large_sales
	GROUP BY channel;
	
	RETURN NEW;
END;
$$;

-- ========== CREATE TRIGGER ==========
CREATE TRIGGER large_sales_update 
AFTER UPDATE 
ON large_sales 
FOR EACH STATEMENT 
EXECUTE PROCEDURE update_trigger_function(); 

	-- process to create new channel 
	-- find who has an id > 20000
SELECT * FROM large_sales WHERE customer_id > 20000;
	-- see how many have an id > 20000
SELECT COUNT(*) FROM large_sales WHERE customer_id > 20000;
	-- we'll update customers with a higher ID to VIP 
SELECT * FROM large_sales_by_channel;
	-- if id > 2000 then channel = VIP, essentially 
UPDATE large_sales SET channel = 'VIP' WHERE customer_id > 20000;

	-- you should see 4 records with 1 channnel saying VIP 
SELECT * FROM large_sales_by_channel;

-- How to drop a trigger 
-- remember, triggers are bounded to a table which is why we use the ON clause followed
-- by a table name 
-- DROP TRIGGER IF EXISTS large_sales_update ON large_sales;
-- DROP TRIGGER IF EXISTS new_large_sale ON large_sales;

-- ========== CREATE TABLE - Detailed ==========
SELECT s.dealership_id, d.street_address, d.city, d.state, d.postal_code,
s.product_id, p.model, p.year, p.product_type, p.base_msrp, 
s.customer_id, s.sales_amount, s.channel
FROM sales s 
LEFT JOIN dealerships d ON s.dealership_id = d.dealership_id
LEFT JOIN products p ON s.product_id = p.product_id; 

-- ========== CREATE TABLE - Summary ==========
SELECT s.dealership_id, d.street_address, p.product_type,
	SUM(p.base_msrp)::numeric(20,2)::money AS total_retail_value,
	SUM(s.sales_amount)::numeric(20,2)::money AS sales_total,
	((1 - (SUM(s.sales_amount) / SUM(p.base_msrp)))*100)::numeric(4, 1) 
		AS discount_percentage
FROM sales AS s
LEFT JOIN dealerships AS d ON s.dealership_id = d.dealership_id
LEFT JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1, 2, 3
ORDER BY 1, SUM(s.sales_amount) DESC; 

-- ========== CREATE PROCEDURE ==========
CREATE OR REPLACE PROCEDURE create_sales_tables()
LANGUAGE PLPGSQL
AS $$ 
BEGIN 
	DROP TABLE IF EXISTS detailed_sales_report;
	DROP TABLE IF EXISTS discount_report;
	
	-- Create 1st table, the DETAILED table
	CREATE TABLE detailed_sales_report AS 
		SELECT s.dealership_id, d.street_address, d.city, d.state, d.postal_code,
		s.product_id, p.model, p.year, p.product_type, p.base_msrp, 
		s.customer_id, s.sales_amount, s.channel
		FROM sales s 
		LEFT JOIN dealerships d ON s.dealership_id = d.dealership_id
		LEFT JOIN products p ON s.product_id = p.product_id; 

	-- Create 2nd table, the SUMMARY table\
	CREATE TABLE discount_report AS 
		SELECT s.dealership_id, d.street_address, p.product_type,
		SUM(p.base_msrp)::numeric(20,2)::money AS total_retail_value,
		SUM(s.sales_amount)::numeric(20,2)::money AS sales_total,
		((1 - (SUM(s.sales_amount) / SUM(p.base_msrp)))*100)::numeric(4, 1) 
			AS discount_percentage
		FROM sales AS s
		LEFT JOIN dealerships AS d ON s.dealership_id = d.dealership_id
		LEFT JOIN products AS p ON s.product_id = p.product_id
		GROUP BY 1, 2, 3
		ORDER BY 1, SUM(s.sales_amount) DESC; 
RETURN; 
END;
$$;

-- should show as it does not exist AT FIRST
SELECT * FROM detailed_sales_report; 
SELECT * FROM discount_report; 

-- Run this, then the SELECT statements again, there should be some data. 
CALL create_sales_tables();

-- ========== CREATE 2nd PROCEDURE ==========
-- Detailed table will get data -> then update the summary table 
CREATE OR REPLACE PROCEDURE refresh_sales_tables()
LANGUAGE PLPGSQL
AS $$
BEGIN 
	DELETE FROM detailed_sales_report;
	DELETE FROM discount_report;
	
	-- REFRESH DATA - into detailed sales report 
	INSERT INTO detailed_sales_report
		SELECT s.dealership_id, d.street_address, d.city, d.state, d.postal_code,
		s.product_id, p.model, p.year, p.product_type, p.base_msrp, 
		s.customer_id, s.sales_amount, s.channel
		FROM sales s 
		LEFT JOIN dealerships d ON s.dealership_id = d.dealership_id
		LEFT JOIN products p ON s.product_id = p.product_id; 
	
	-- REFRESH DATA - summary table 
	INSERT INTO discount_report
		SELECT dealership_id, street_address, product_type,
		SUM(base_msrp)::numeric(20,2)::money AS total_retail_value,
		SUM(sales_amount)::numeric(20,2)::money AS sales_total,
		((1 - (SUM(sales_amount) / SUM(base_msrp)))*100)::numeric(4, 1) 
			AS discount_percentage
		-- we don't need to do the LEFT JOINs since the detailed sales report 
		-- already does that for us. 
		FROM detailed_sales_report
		GROUP BY 1, 2, 3
		ORDER BY 1, SUM(sales_amount) DESC; 
RETURN;
END;
$$;


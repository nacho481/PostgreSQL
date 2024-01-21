SELECT * FROM sales LIMIT 20; 

CREATE TABLE IF NOT EXISTS large_sales (
	channel VARCHAR(30),
	customer_id bigint,
	sales_amount float
);

INSERT INTO large_sales
(SELECT channel, customer_id, sales_amount 
FROM sales
WHERE sales_amount > 100000
ORDER BY sales_amount DESC);

SELECT * FROM large_sales LIMIT 20; 

CREATE TABLE IF NOT EXISTS large_sales_by_channel (
	channel VARCHAR(30),
	number_of_sales BIGINT
);

INSERT INTO large_sales_by_channel
SELECT channel, COUNT(customer_id)
FROM large_sales
GROUP BY channel; 


SELECT * FROM large_sales_by_channel;

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

CREATE TRIGGER new_large_sale 
	AFTER INSERT
	ON large_sales
	FOR EACH STATEMENT
	EXECUTE PROCEDURE insert_trigger_function();
	
SELECT COUNT(*) FROM large_sales;
SELECT SUM(number_of_sales) FROM large_sales_by_channel;

INSERT INTO large_sales VALUES('call center', 57, 125000);

SELECT COUNT(*) FROM large_sales;
SELECT SUM(number_of_sales) FROM large_sales_by_channel;
SELECT * FROM large_sales_by_channel; 


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

CREATE TRIGGER large_sales_update 
AFTER UPDATE 
ON large_sales 
FOR EACH STATEMENT 
EXECUTE PROCEDURE update_trigger_function(); 

SELECT * FROM large_sales WHERE customer_id > 20000;
SELECT COUNT(*) FROM large_sales WHERE customer_id > 20000;
-- we'll update customers with a higher ID to VIP 
SELECT * FROM large_sales_by_channel;

UPDATE large_sales SET channel = 'VIP' WHERE customer_id > 20000;

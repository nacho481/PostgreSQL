-- ==================== CREATE - Detailed Table ==================== 
CREATE TABLE IF NOT EXISTS genre_sales(
	title VARCHAR(50),
	genre VARCHAR(50),
	number_of_rentals BIGINT,
	-- this creates a MONEY data type explicitly stating to only allow 2 to the left and 
	-- 2 floating points
	payment MONEY
);

-- ==================== INSERT INTO - Detailed Table ==================== 
INSERT INTO genre_sales
	SELECT
		film.title,
		category.name AS genre,
		COUNT(rental.rental_id) AS number_of_rentals,
		(SUM(payment.amount))::NUMERIC(5,2)::MONEY AS total_revenue
	FROM inventory
		-- link (inventory) to (rental) table
	LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
		-- link (rental) to (payment) table
	LEFT JOIN payment ON payment.rental_id = rental.rental_id
		-- get genere's through the following tables 
		-- inventory -> film -> film_category -> category
		-- link (inventory) to (film)
	LEFT JOIN film ON film.film_id = inventory.film_id
		-- link (film) to (film_category)
	LEFT JOIN film_category ON film_category.film_id = film.film_id
		-- link (film_category) to (category)
	LEFT JOIN category 
		ON category.category_id = film_category.category_id
	GROUP BY 
		film.title, 
		category.name
	ORDER BY genre, total_revenue DESC;

SELECT * FROM genre_sales;
DELETE FROM genre_sales;
DROP TABLE genre_sales;
-- ==================== CREATE - Summary Table ==================== 
DROP TABLE genre_sales_summary;
CREATE TABLE IF NOT EXISTS genre_sales_summary(
	genre VARCHAR(50),
	number_of_rentals BIGINT,
		-- 6 points of precision, 2 floating points, convert to $$
	total_revenue MONEY,
	UNIQUE(genre, number_of_rentals, total_revenue)
);

-- ==================== INSERT INTO - Summary Table ==================== 
DELETE FROM genre_sales_summary;
INSERT INTO genre_sales_summary
	SELECT 
		genre,
		COUNT(number_of_rentals) AS number_of_rentals,
		SUM(payment) AS total_revenue
	FROM genre_sales
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 5; 	

SELECT * FROM genre_sales_summary;

-- ==================== CREATE TRIGGER FUNCTION ==================== 
CREATE OR REPLACE FUNCTION insert_trigger_genre_sale()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
	-- we want to update our large sales by channel table easiest way is to delete the table, and reinsert all + new data
	-- clear data from this table 
	DELETE FROM genre_sales_summary;
	INSERT INTO genre_sales_summary
		SELECT genre, COUNT(number_of_rentals) AS number_of_rentals, SUM(payment) AS total_revenue
		FROM genre_sales
		GROUP BY 1
		ORDER BY 3 DESC
		LIMIT 5; 	
	RAISE NOTICE 'Trigger fired!';
	RETURN NEW;
	COMMIT;
END;
$$;

-- ==================== CREATE TRIGGER ==================== 
DROP TRIGGER genre_sales_summary_insert_trigger ON genre_sales;
CREATE TRIGGER genre_sales_summary_insert_trigger
	AFTER INSERT OR DELETE
	ON genre_sales
	FOR EACH STATEMENT
	EXECUTE PROCEDURE insert_trigger_genre_sale();
-- Demo 
	-- Show detailed summary 
SELECT * FROM genre_sales_summary;
SELECT * FROM genre_sales; 
SELECT * FROM genre_sales WHERE title = 'Kickass';

INSERT INTO genre_sales
VALUES ('Kickass', 'Comedy', 24, 360);

DELETE FROM genre_sales WHERE title = 'Kickass';

SELECT * FROM genre_sales_summary;

-- ========== CREATE PROCEDURE ==========
CREATE OR REPLACE PROCEDURE refresh_genre_tables()
LANGUAGE PLPGSQL
AS $$ 
BEGIN 
	ALTER TABLE genre_sales DISABLE TRIGGER genre_sales_summary_insert_trigger;
	DELETE FROM genre_sales;
	DELETE FROM genre_sales_summary;
	
	-- refresh genre_sales table FIRST 
	INSERT INTO genre_sales 
		SELECT
			film.title,
			category.name AS genre,
			COUNT(rental.rental_id) AS number_of_rentals,
			(SUM(payment.amount))::NUMERIC(5,2)::MONEY AS total_revenue
		FROM inventory
			-- link (inventory) to (rental) table
		LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
			-- link (rental) to (payment) table
		LEFT JOIN payment ON payment.rental_id = rental.rental_id
			-- get genere's through the following tables 
			-- inventory -> film -> film_category -> category
			-- link (inventory) to (film)
		LEFT JOIN film ON film.film_id = inventory.film_id
			-- link (film) to (film_category)
		LEFT JOIN film_category ON film_category.film_id = film.film_id
			-- link (film_category) to (category)
		LEFT JOIN category 
			ON category.category_id = film_category.category_id
		GROUP BY 
			film.title, 
			category.name
		ORDER BY genre, total_revenue DESC;
		ALTER TABLE genre_sales ENABLE TRIGGER genre_sales_summary_insert_trigger;

RETURN;
END;
$$;
	
-- Demo procedure 
SELECT * FROM genre_sales;
SELECT * FROM genre_sales_summary;
DELETE FROM genre_sales;
DELETE FROM genre_sales_summary;

CALL refresh_genre_tables();



-- Detailed table 
SELECT
    film.title,
    category.name AS genre,
    COUNT(rental.rental_id) AS number_of_rentals,
    (SUM(payment.amount))::NUMERIC(5,2)::MONEY AS total_revenue
FROM inventory
	-- link (inventory) to (rental) table
LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
	-- link (rental) to (payment) table
LEFT JOIN payment ON payment.rental_id = rental.rental_id
	-- get genere's through the following tables 
	-- inventory -> film -> film_category -> category
	-- link (inventory) to (film)
LEFT JOIN film ON film.film_id = inventory.film_id
	-- link (film) to (film_category)
LEFT JOIN film_category ON film_category.film_id = film.film_id
	-- link (film_category) to (category)
LEFT JOIN category 
	ON category.category_id = film_category.category_id
GROUP BY 
	film.title, 
	category.name
ORDER BY genre, total_revenue DESC;


-- Summary table of genere and total-
SELECT 
	genre,
	COUNT(number_of_rentals) AS number_of_rentals,
	SUM(payment) AS total_revenue
FROM genre_sales
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5; 




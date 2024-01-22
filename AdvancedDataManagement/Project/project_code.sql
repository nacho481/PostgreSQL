-- ==================== CREATE - Detailed Table ==================== 
CREATE TABLE IF NOT EXISTS genre_sales(
	title VARCHAR(50),
	genre VARCHAR(50),
	rental_id BIGINT,
	-- this creates a MONEY data type explicitly stating to only allow 2 to the left and 
	-- 2 floating points
	payment NUMERIC(4,2)::MONEY 
);

-- ==================== INSERT INTO - Detailed Table ==================== 



-- ==================== CREATE - Summary Table ==================== 
CREATE TABLE IF NOT EXISTS genre_sales_summary(
	genre VARCHAR(50),
	number_of_rentals BIGINT,
		-- 6 points of precision, 2 floating points, convert to $$
	total_revenue NUMERIC(6,2)::MONEY
);

-- ==================== INSERT INTO - Summary Table ==================== 


-- Detailed table 
SELECT
    film.title,
    category.name AS genre,
    COUNT(rental.rental_id) AS number_of_rentals,
    (SUM(payment.amount))::NUMERIC(4,2)::MONEY AS total_revenue
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
ORDER BY total_revenue DESC;




-- Summary table of genere and total-
SELECT 
	category.name AS genre,  -- get genre 
	COUNT(rental.rental_id) as number_of_rentals,
	(SUM(payment.amount))::NUMERIC(6,2)::MONEY AS total_revenue  -- find total_revenue
FROM inventory 
	-- link (inventory) to (rental) table
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
	-- link (rental) to (payment) table
INNER JOIN payment ON payment.rental_id = rental.rental_id
	-- get genere's through the following tables 
	-- inventory -> film -> film_category -> category
	-- link (inventory) to (film)
INNER JOIN film	ON film.film_id = inventory.film_id
	-- link (film) to (film_category)
INNER JOIN film_category ON film_category.film_id = film.film_id
	-- link (film_category) to (category)
INNER JOIN category ON category.category_id = film_category.category_id
GROUP BY genre
	-- descending order put's top earners at top! 
ORDER BY total_revenue DESC
LIMIT 20;





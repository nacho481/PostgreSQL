-- ==================== CREATE - Detailed Table ==================== 
CREATE TABLE IF NOT EXISTS genre_sales(
	genre VARCHAR(50),
	
	
	
);


-- Detailed table 
SELECT
    film.title,
    category.name AS genre,
    COUNT(rental.rental_id) AS number_of_rentals,
    SUM(payment.amount) AS total_revenue
FROM inventory
	-- link (inventory) to (rental) table
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
	-- link (rental) to (payment) table
INNER JOIN payment ON payment.rental_id = rental.rental_id
	-- get genere's through the following tables 
	-- inventory -> film -> film_category -> category
	-- link (inventory) to (film)
INNER JOIN film ON film.film_id = inventory.film_id
	-- link (film) to (film_category)
INNER JOIN film_category ON film_category.film_id = film.film_id
	-- link (film_category) to (category)
INNER JOIN category 
	ON category.category_id = film_category.category_id
GROUP BY 
	film.title, 
	category.name
ORDER BY total_revenue DESC;




-- Summary table of genere and total-
SELECT 
	category.name AS genre,  -- get genre 
	COUNT(rental.rental_id) as number_of_rentals,
	SUM(payment.amount) AS total_revenue  -- find total_revenue
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





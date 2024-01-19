SELECT 
	inventory.inventory_id, 
	film.film_id, 
	film.title,
	film.release_year AS release_date,
	category.name AS genre, 
	COUNT(rental.rental_id) AS number_of_rentals
FROM inventory 
INNER JOIN rental 
	ON rental.inventory_id = inventory.inventory_id
INNER JOIN film 
	ON film.film_id = inventory.film_id
INNER JOIN film_category 
	ON film_category.film_id = film.film_id
INNER JOIN category 
	ON category.category_id = film_category.category_id
GROUP BY 
	inventory.inventory_id, 
	film.film_id, 
	release_date,
	genre, 
	film_category.film_id
-- HAVING COUNT(rental.rental_id) >= 5
ORDER BY number_of_rentals DESC;

-- Summary table of genere and total_revenue 
SELECT 
	category.name AS genre,
	SUM(payment.amount) AS total_revenue
FROM inventory 
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
INNER JOIN film	ON film.film_id = inventory.film_id
INNER JOIN film_category ON film_category.film_id = film.film_id
INNER JOIN category ON category.category_id = film_category.category_id
GROUP BY genre
ORDER BY total_revenue DESC;

SELECT COUNT(*) AS number_of_documentaries
FROM film
INNER JOIN film_category 
	ON film.film_id = film_category.film_id
INNER JOIN category 
	ON category.category_id = film_category.category_id
WHERE category.name = 'Documentary';


-- summary table 
SELECT 
	inventory.inventory_id, 
	COUNT(rental.rental_id) AS number_of_rentals
FROM inventory
INNER JOIN rental 
	ON rental.inventory_id = inventory.inventory_id
GROUP BY inventory.inventory_id
HAVING COUNT(rental.rental_id) >= 5
ORDER BY number_of_rentals DESC;
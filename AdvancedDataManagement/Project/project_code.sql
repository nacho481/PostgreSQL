

-- Summary table of genere and total-
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




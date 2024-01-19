SELECT * FROM film LIMIT 5;
SELECT * FROM inventory LIMIT 5; 
SELECT * FROM film_category LIMIT 5;
SELECT * FROM category LIMIT 5;

-- figure out how many times a movie was rented
SELECT inventory.inventory_id, COUNT(rental.rental_id) AS number_of_rentals
FROM inventory
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY inventory.inventory_id
ORDER BY number_of_rentals DESC;
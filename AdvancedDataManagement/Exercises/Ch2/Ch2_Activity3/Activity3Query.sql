SELECT first_name, last_name, email, city, state
FROM customers
WHERE city = 'New York City' AND state = 'NY'
ORDER BY last_name, first_name;
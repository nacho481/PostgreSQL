(
SELECT state, NULL as gender, COUNT(*)
FROM customers
GROUP BY 1, 2
ORDER BY 1, 2
)

UNION ALL
(
	(
		SELECT state, gender, COUNT(*)
		FROM CUSTOMER 
		GROUP BY 1, 2
		ORDER BY 1, 2
	)
)
ORDER BY 1, 2
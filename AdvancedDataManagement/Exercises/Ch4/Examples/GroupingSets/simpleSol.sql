SELECT state, gender, COUNT(*)
FROM customers 
GROUP BY GROUPING SETS(
	(state),
	(gender),
	(state, gender)
)
ORDER BY 1, 2
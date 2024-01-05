SELECT SUM(CASE WHEN state is NULL OR state IN ('') THEN 1 ELSE 0
		  END)::FLOAT/COUNT(*) AS missing_state
FROM customers;

-- output is 0.10934 meaning it's 10.9% missing. 
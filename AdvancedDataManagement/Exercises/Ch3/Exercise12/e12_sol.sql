SELECT c.customer_id,
CASE WHEN c.state IN ('MA', 'NH', 'VT', 'ME', 'CT', 'RI') THEN 
	'New England'
WHEN c.state in ('GA', 'FL', 'MS', 'AL', 'LA', 'KY', 'VA', 'NC', 'SC'
				'TN', 'VI', 'AR') THEN 'SouthEast'
ELSE 'Other' END as region
FROM customers as c 
ORDER BY 1; 
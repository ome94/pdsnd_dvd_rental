
/*QUERY 1 - Which movie categories are families watching?*/
WITH family_rentals AS (
	SELECT name category, COUNT(*) rental_count
	FROM rental r
	JOIN inventory i ON i.inventory_id = r.inventory_id
	JOIN film f ON f.film_id = i.film_id
	JOIN film_category fc ON fc.film_id = f.film_id
	JOIN category c ON c.category_id = fc.category_id
	GROUP BY category ORDER BY category
)
SELECT * FROM family_rentals
WHERE category IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');

/*QUERY 2 - What is the rental duration of family categories?*/
WITH rental_durations AS (
	SELECT  name category, rental_duration,
			NTILE(4) OVER (ORDER BY rental_duration) rent_dur_standard_quartile
	FROM film f
	JOIN film_category fc ON fc.film_id = f.film_id
	JOIN category c ON c.category_id = fc.category_id
)
SELECT category, rent_dur_standard_quartile, COUNT(*) rent_count FROM rental_durations
WHERE category IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1, 2;



/*QUERY 3 - How can we compare the two stores?*/
SELECT  DATE_PART('month', rental_date) rental_month,
		DATE_PART('year', rental_date) rental_year,
		s.store_id,
		COUNT(*) month_rentals_count
FROM rental r
JOIN staff sf ON r.staff_id = sf.staff_id
JOIN store s ON s.store_id = sf.store_id
GROUP BY 1, 2, 3
ORDER BY 2, 1, 4 DESC;


/*QUERY 4 - Who are the top payers and how did they spend on rentals in 2007?*/
WITH top_payers AS (
	SELECT  c.customer_id,
			first_name || ' ' || last_name fullname,
			SUM(amount) amount
	FROM payment p
	JOIN customer c ON c.customer_id = p.customer_id
	GROUP BY 1, 2 ORDER BY 3 DESC
	LIMIT 10
)
SELECT	DISTINCT DATE_TRUNC('month', payment_date) pay_mon,
		fullname,
		COUNT(payment_id) OVER payment_window AS pay_count_permon,
		SUM(p.amount) OVER payment_window AS pay_amount_permon
FROM payment p
JOIN top_payers tp ON tp.customer_id = p.customer_id
WHERE DATE_PART('year', payment_date) = 2007
WINDOW payment_window AS (PARTITION BY fullname, DATE_TRUNC('month', payment_date) ORDER BY DATE_TRUNC('month', payment_date))
ORDER BY fullname;

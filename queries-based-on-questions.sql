/* Q1) Who is the senior most employee based on job title? */

SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2) Which countries have the most Invoices? */

SELECT billing_country AS Country, COUNT(billing_country) as Invoices
FROM invoice
GROUP BY billing_country
ORDER BY Invoices DESC
LIMIT 1
 
/* Q3) What are top 3 values of total invoice? */

SELECT total AS Top_Invoice_Value
FROM invoice
ORDER BY Top_Invoice_Value DESC
LIMIT 3 

/* Q4) Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals. */

SELECT billing_city AS City, FLOOR(SUM(total)) AS Total_Invoice
FROM invoice
GROUP BY City
ORDER BY Total_Invoice DESC
LIMIT 1

/* Q5) Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money. */

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC
LIMIT 1

/* Q6) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.  */

SELECT DISTINCT C.email, C.first_name, C.last_name
FROM customer C
JOIN invoice I ON C.customer_id = I.customer_id
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
WHERE IL.track_id IN  (
      SELECT T.track_id FROM track T
      JOIN genre G
      ON T.genre_id = G.genre_id
      WHERE G.name LIKE 'Rock'
)
ORDER BY C.email

/* Q7) Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.  */

SELECT DISTINCT AR.name AS artist_Name, count(T.track_id) AS number_of_songs
FROM artist AR
JOIN album AL ON AR.artist_id = AL.artist_id
JOIN track T ON AL.album_id = T.album_id
JOIN genre G ON T.genre_id = G.genre_id
WHERE G.name = 'Rock'
GROUP BY AR.artist_id 
ORDER BY number_of_songs DESC
LIMIT 10

/* Q8) Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.  */

SELECT name AS track_name, milliseconds AS song_length
FROM track
WHERE milliseconds > ( 
	SELECT AVG(milliseconds) FROM track 
)
ORDER BY milliseconds DESC


/* Q9) Find out how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.  */

SELECT C.customer_id, C.first_name AS customer_fname, C.last_name AS customer_lname, AR.name AS artist_name, SUM(IL.unit_price * IL.quantity) AS total_spent
FROM customer C
JOIN invoice I ON C.customer_id = I.customer_id
JOIN invoice_line IL ON I.invoice_id = IL.invoice_id
JOIN track T ON IL.track_id = T.track_id
JOIN album AL ON T.album_id = AL.album_id
JOIN artist AR ON AL.artist_id = AR.artist_id
GROUP BY C.customer_id, AR.artist_id
ORDER BY total_spent DESC


/* Q10) We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns to each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.  */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_no
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE row_no <= 1

/* Q11) Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

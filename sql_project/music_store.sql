-- easy 1

-- Q1 : Who is the senior most employee based on job title ? 

SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1

-- Q2 : Which countries have the most invoices ? 

SELECT COUNT(*), billing_country
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC

-- Q3 : What are top 3 values of total invoice ?

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3

-- Q4: Which city has the best customers? We would like to throw a 
-- promotional Music Festival in the city we made the most money. Write a 
-- query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals

SELECT billing_city, SUM(total) as invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1

-- Q5: Who is the best customer? The customer who has spent the most 
-- money will be declared the best customer. Write a query that returns 
-- the person who has spent the most money.

SELECT customer.customer_id,customer.first_name, customer.last_name,SUM(total) AS money
FROM invoice JOIN customer
USING (customer_id)
GROUP BY customer.customer_id
ORDER BY money DESC
LIMIT 1

-- moderate 2

-- Q1: Write query to return the email, first name, last name, & Genre 
-- of all Rock Music listeners. Return your list ordered alphabetically 
-- by email starting with A

SELECT DISTINCT email, first_name, last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN (
	SELECT track_id 
	FROM track
	JOIN genre
	ON genre.genre_id = track.genre_id
	WHERE genre.name = 'Rock'
)
ORDER BY email

-- Q2 : Let's invite the artists who have written the most rock music in 
-- our dataset. Write a query that returns the Artist name and total 
-- track count of the top 10 rock bands.

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10


-- Q3: Return all the track names that have a song length longer than 
-- the average song length. Return the Name and Milliseconds for 
-- each track. Order by the song length with the longest song listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC

-- advance 3

-- Q1: Find how much amount spent by each customer on artists? Write a 
-- query to return customer name, artist name and total spent

WITH artists_names AS(
	SELECT ar.artist_id AS artist_id, ar.name AS artist_name, il.invoice_id, SUM(il.unit_price * il.quantity) AS total_spent
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album a ON a.album_id = t.album_id
	JOIN artist ar ON ar.artist_id = a.artist_id
	GROUP BY 1,3
	ORDER BY 1,3
)

SELECT an.artist_name, c.first_name, c.last_name, SUM(an.total_spent) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN artists_names an ON an.invoice_id = i.invoice_id
GROUP BY c.customer_id, an.artist_name
ORDER BY c.customer_id, an.artist_name


-- Q2: We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest 
-- amount of purchases. Write a query that returns each country along with 
-- the top Genre. For countries where the maximum number of purchases 
-- is shared return all Genres.

WITH all_country AS(
	
	SELECT COUNT(il.quantity) purchases, i.billing_country AS country, g.name AS genre_name,
	ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS RowNo
	FROM invoice_line il 
	JOIN invoice i ON i.invoice_id = il.invoice_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY 2,3
	ORDER BY 2 ASC, 1 DESC
)

SELECT purchases, country, genre_name FROM all_country WHERE RowNo = 1


-- Q3: Write a query that determines the customer that has spent the most 
-- on music for each country. Write a query that returns the country along 
-- with the top customer and how much they spent. For countries where 
-- the top amount spent is shared, provide all customers who spent this amount

WITH all_row AS(
SELECT c.customer_id, c.first_name, c.last_name, c.country, SUM(total) AS total_invoice,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(total) DESC) AS row
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.country
ORDER BY c.customer_id
)
 
SELECT * FROM all_row WHERE row = 1

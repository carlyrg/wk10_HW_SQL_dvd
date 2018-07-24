-- 1a Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT concat(first_name, ' ', last_name) AS 'Actor Name'
	FROM actor ;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
	FROM actor
    WHERE first_name IN ('Joe');
    
-- 2b. Find all actors whose last name contain the letters GEN
SELECT first_name, last_name
	FROM actor
    WHERE last_name LIKE ('%GEN%');

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
	FROM actor
    WHERE last_name LIKE ('%LI%')
    ORDER BY last_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
	FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
	ADD middle_name varchar(20)
    AFTER first_name;

-- change data type to blob
ALTER TABLE actor
	modify COLUMN middle_name blobs;
    
-- 3c. Now delete the middle_name column
ALTER TABLE actor
	DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT first_name, last_name, COUNT(last_name) AS how_many FROM actor
	GROUP BY last_name
    ORDER BY how_many DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select * FROM(
    SELECT first_name, last_name, COUNT(last_name) AS how_many FROM actor
	GROUP BY last_name
    ) as n
WHERE n.how_many >= 2
ORDER BY how_many DESC;

-- 4c.  The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO', last_name = 'WILLIAMS'
WHERE actor_id = 172;

-- 4d. change 'groucho' to 'mucho groucho' and 'harpo' to 'groucho'
UPDATE actor 
SET first_name = 
CASE 
	WHEN first_name = 'HARPO' 
		THEN 'GROUCHO'
	ELSE 'MUCHO GROUCHO'
END
WHERE actor_id = 172;
	

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE actor

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, 
		a.address, c.city
	FROM staff AS s
	JOIN address AS a on a.address_id = s.address_id
    JOIN city AS c on c.city_id = a.city_id
    
        

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
CREATE VIEW `august_sales` AS(
	SELECT p.payment_date, p.amount, s.first_name, s.last_name, s.staff_id
		FROM payment AS p
		JOIN staff AS s on p.staff_id = s.staff_id
        WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 12:59:59'
		GROUP BY p.payment_date)
        
SELECT first_name, last_name, SUM(amount) AS total_sales_aug
	FROM august_sales
	GROUP BY first_name, last_name

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(distinct a.actor_id) as number_actors
	FROM film AS f
	JOIN film_actor AS a ON a.film_id = f.film_id
	GROUP BY f.title

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(f.title) AS copies, f.title
	FROM film AS f
	JOIN inventory AS i on f.film_id = i.film_id
    WHERE title IN ('Hunchback Impossible')

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_paid
	FROM customer AS c
    JOIN payment AS p ON c.customer_id = p.customer_id
    GROUP BY c.last_name, c.first_name
    ORDER BY c.last_name;
    

-- 7a display the titles of movies starting with the letters K and Q whose language is English.    
SELECT t.title, t.name AS language FROM(
	SELECT l.language_id, l.name, f.title
		FROM language AS l
		JOIN film AS f ON f.language_id = l.language_id
		) as t
	WHERE title LIKE ('Q%') OR title LIKE ('K%');
        

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT actor_id, first_name, last_name, title FROM(
    SELECT a.first_name, a.last_name, a.actor_id, fa.film_id, f.title
		FROM actor AS a
		JOIN film_actor AS fa ON a.actor_id = fa.actor_id
		JOIN film AS f ON fa.film_id = f.film_id
        ) AS x
	WHERE x.title IN ('Alone Trip')

-- 7c. names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT loc.first_name, loc.last_name, loc.email, country FROM(
	SELECT c.first_name, c.last_name, c.email, 
		a.address, a.district, country.country
		FROM customer AS c
		JOIN address AS a ON c.address_id = a.address_id
		JOIN city AS city on city.city_id  = a.city_id
		JOIN country AS country ON country.country_id = city.country_id
        ) as loc
	WHERE country = 'Canada'
    ORDER BY loc.last_name, first_name;

-- 7d.  Identify all movies categorized as family films.
SELECT c.name, f.title
	FROM category AS c
	JOIN film_category as fc ON c.category_id = fc.category_id
	JOIN film AS f ON f.film_id = fc.film_id
    WHERE name = 'Family'

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.inventory_id) AS times_rented
FROM rental AS r
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f on f.film_id = i.film_id
GROUP BY f.title
ORDER BY times_rented DESC 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT concat('$', format(sum(p.amount),2)) AS total, a.address
FROM payment AS p
JOIN staff AS s ON p.staff_id = s.staff_id
JOIN store AS st on s.store_id = st.store_id
JOIN address as a on a.address_id = st.address_id
GROUP BY address
ORDER by total

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country
	FROM store AS s
    JOIN address AS a ON a.address_id = s.address_id
    JOIN city AS c ON c.city_id = a.city_id
    JOIN country AS co ON co.country_id = c.country_id

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT concat('$', format(sum(p.amount),2)) AS gross_revenue, c.name
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON fc.film_id = i.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY gross_revenue DESC

-- 8a viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
CREATE VIEW `top_5_grossing_genres` AS (
	SELECT concat('$', format(sum(p.amount),2)) AS gross_revenue, c.name
	FROM category AS c
	JOIN film_category AS fc ON fc.category_id = c.category_id
	JOIN inventory AS i ON fc.film_id = i.film_id
	JOIN rental AS r ON r.inventory_id = i.inventory_id
	JOIN payment AS p ON p.rental_id = r.rental_id
	GROUP BY c.name
	ORDER BY gross_revenue DESC)
SELECT TOP 5* FROM top_5_grossing_genres

-- 8b. How would you display the view that you created in 8a
SELECT * FROM top_5_grossing_genres

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_grossing_genres
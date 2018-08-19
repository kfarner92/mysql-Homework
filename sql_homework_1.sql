--Homework for sql
-- Kristian F. 10/19/2018
USE sakila;
-- 1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name 
FROM actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT CONCAT(first_name , ' ', last_name) AS 'full_name' 
FROM actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = 'Joe'; 	
-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name like '%gen%';
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name like '%li%'
ORDER BY last_name asc, first_name asc;
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(255);
ALTER TABLE actor
CHANGE COLUMN middle_name middle_name VARCHAR(50) AFTER first_name;
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
CHANGE COLUMN middle_name middle_name blob;
-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor
DROP middle_name;
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1;
-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'Harpo'
AND last_name = 'Williams';
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'MUCHO GROUCHO'
WHERE actor_id = 172;
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 
DESCRIBE address;
CREATE TABLE address (
    address_id SMALLINT(5) AUTO_INCREMENT NOT NULL,
    address VARCHAR(50),
    address2 VARCHAR(50),
    district VARCHAR(20),
    city_id SMALLINT(5),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    location GEOMETRY,
    last_update TIMESTAMP,
);
-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT k.first_name, k.last_name, f.address
FROM  staff k
JOIN address f
ON k.address_id = f.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT k.first_name, k.last_name, SUM(f.amount) AS 'Total Amount ($)'
FROM staff k
JOIN payment f
ON k.staff_id = f.staff_id
GROUP BY k.first_name, k.last_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT k.title, COUNT(f.actor_id) AS 'Actors in film'
FROM film k
INNER JOIN film_actor f
ON k.film_id = f.film_id
GROUP BY k.title
ORDER BY COUNT(f.actor_id) DESC;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(k.film_id) as 'Copies of Hunchback Impossible'
FROM inventory k
JOIN film f 
ON k.film_id = f.film_id
WHERE k.film_id = (
  SELECT film_id
  FROM film
  WHERE title = 'Hunchback Impossible'
)
GROUP BY f.title;
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT k.first_name, k.last_name, SUM(f.amount) AS 'Total Paid'
FROM customer k 
JOIN payment f
ON k.customer_id = f.customer_id
GROUP BY k.first_name, k.last_name
ORDER BY k.last_name ASC;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title
FROM film
WHERE film_id IN (
  SELECT film_id
  FROM film
  WHERE title LIKE 'K%'
  OR title LIKE 'Q%'
  AND language_id = (
    SELECT language_id
    FROM language
    WHERE name = 'English'
  )
);
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
 SELECT k.first_name, k.last_name
 FROM actor k
 WHERE  k.actor_id IN (
   SELECT actor_id
   FROM film_actor
   WHERE film_id = (
     SELECT film_id
     FROM film
     WHERE title = 'Alone Trip'
   )
 );
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT k.first_name, k.last_name, k.email
FROM customer k
JOIN address f 
ON k.address_id = f.address_id
JOIN city t 
ON f.city_id = t.city_id
JOIN country a 
ON t.country_id = a.country_idWHERE a.country = 'Canada'; 
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT k.film_id, k.title
FROM film k 
JOIN film_category f 
ON k.film_id = f.film_id
JOIN category t 
ON f.category_id = t.category_id
WHERE t.name = 'family';
-- 7e. Display the most frequently rented movies in descending order.
SELECT k.title, COUNT(t.rental_id) AS 'Times Rented'
FROM film k
JOIN inventory f 
ON k.film_id = f.film_id
JOIN rental t 
ON f.inventory_id = t.inventory_id
GROUP BY k.title 
ORDER BY COUNT(t.rental_id) DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT k.store_id, SUM(a.amount) AS 'Store Rental Revenue'
FROM store k 
JOIN inventory f 
ON k.store_id = f.store_id
JOIN rental t 
ON f.inventory_id = t.inventory_id
JOIN payment a 
ON  t.rental_id = a.rental_id
GROUP BY k.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT k.store_id, t.city, a.country
FROM store k 
JOIN address f 
ON k.address_id = f.address_id
JOIN city t 
ON f.city_id = t.city_id
JOIN country a 
ON t.country_id = a.country_id;
-- 7h. List the top five genres in gross revenue in descending order. (----Hint----: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT k.name , SUM(b.amount) as 'Top Grossing'
FROM category k 
JOIN film_category f 
ON k.category_id = f.category_id
JOIN inventory t 
ON f.film_id = t.film_id
JOIN rental a 
ON t.inventory_id = a.inventory_id
JOIN payment b 
ON a.rental_id = b.rental_id
GROUP BY k.name
Order BY SUM(b.amount) DESC
LIMIT 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_By_Genre AS
SELECT k.name , SUM(b.amount)
FROM category k 
JOIN film_category f 
ON k.category_id = f.category_id
JOIN inventory t 
ON f.film_id = t.film_id
JOIN rental a 
ON t.inventory_id = a.inventory_id
JOIN payment b 
ON a.rental_id = b.rental_id
GROUP BY k.name
Order BY SUM(b.amount) DESC
LIMIT 5;	
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_Five_By_Genre;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_Five_By_Genre;
--### Appendix: List of Tables in the Sakila DB

-- A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

--```sql
--	'actor'
--	'actor_info'
--	'address'
--	'category'
--	'city'
--	'country'
--	'customer'
--	'customer_list'
--	'film'
--	'film_actor'
--	'film_category'
--	'film_list'
--	'film_text'
--	'inventory'
--	'language'
--	'nicer_but_slower_film_list'
--	'payment'
--	'rental'
--	'sales_by_film_category'
--	'sales_by_store'
--	'staff'
--	'staff_list'
--	'store'
--```

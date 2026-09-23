 
 -- 1.0 MySQL Stored Procedures: IN Parameters 
 /*-- Example1 */
 DROP PROCEDURE
 IF EXISTS GetFilmsByRating;
 CREATE PROCEDURE
     GetFilmsByRating(
                      IN filmRating VARCHAR(10)
                      )
 BEGIN
     SELECT
             film_id,
             title,
             rating,
             release_year,
             rental_rate
         FROM film
         WHERE rating = filmRating
         ORDER BY
             title;
 
 END;
 
 /* Example 2*/
 CREATE PROCEDURE
     GetCustomersByLocation(
                            IN cityName    VARCHAR(50),
                            IN countryName VARCHAR(50)
                            )
 BEGIN
     SELECT
             c.customer_id,
             CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
             ci.city,
             co.country,
             c.email
         FROM customer AS c
         INNER JOIN address a  ON c.address_id = a.address_id
         INNER JOIN city ci    ON a.city_id = ci.city_id
         INNER JOIN country co ON ci.country_id = co.country_id
         WHERE ci.city = cityName
             AND co.country = countryName;
 
 END;
 

/*Example 3*/ 
 CREATE PROCEDURE
     check_of_rental_names (IN input_rental_duration INT)
 BEGIN
     SELECT
             film_id,
             title,
             rental_duration
         FROM film
         WHERE rental_duration = input_rental_duration;
 END;


 /*Example 4*/
 CREATE  PROCEDURE
     rentalDurationCheck
                         ( IN duration_input INT)
 BEGIN
     SELECT
             c.first_name,
             c.last_name,
             p.amount,
             YEAR(p.payment_date) AS payment_year,
             MONTH(p.payment_date) AS payment_month,
             r.return_date,
             f.title,
             f.rental_duration
         FROM customer AS c
         JOIN rental AS r       ON r.customer_id = c.customer_id
         JOIN inventory AS i    ON i.inventory_id = r.inventory_id
         JOIN film AS f         ON f.film_id = i.film_id
         LEFT JOIN payment AS p ON p.rental_id = r.rental_id
         WHERE f.rental_duration = duration_input;
  
 END; 
      
      
      
     
-- 2.0 MySQL Stored Procedures: OUT Parameters











-- 3.0 MySQL Stored Procedures: INOUT Parameters





























      
      
      
      
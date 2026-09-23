 /*-- 1.0 MySQL Stored Procedures: IN Parameters*/
 /* Example 1: */
 CREATE PROCEDURE
     GetEmployees()
 BEGIN
     SELECT
             firstName,
             lastName,
             city,
             state,
             country
         FROM employees
         INNER JOIN offices
         USING (officeCode);
 
 END;
 /* Example 2:*/
 CREATE PROCEDURE
     GetCustomerOrders(
                       IN p_customer_id INT
                       )
 BEGIN
     SELECT
             *
         FROM orders
         WHERE customerNumber = p_customer_id;
 
 END;
 /* Example 3*/
 CREATE PROCEDURE
     GetOfficeByCountry(
                        IN countryName VARCHAR(255)
                        )
 BEGIN
     SELECT
             *
         FROM offices
         WHERE country = countryName;
 
 END;
 /*Example 4*/
 CREATE PROCEDURE
     Highspender(
                 IN country_input VARCHAR(50))
 BEGIN
     SELECT
             c.customerNumber,
             c.customerName,
             SUM(p.amount) AS total_spent
         FROM customers c
         JOIN payments p ON p.customerNumber = c.customerNumber
         WHERE c.country = country_input
         GROUP BY
             c.customerNumber,
             c.customerName
         HAVING SUM(p.amount) > 100000
         ORDER BY
             total_spent DESC;
 
 END;



-- 2.0 MySQL Stored Procedures: OUT Parameters

 /* Example 1: */
 CREATE PROCEDURE 
     GetTotalOrders ( OUT p_total_orders INT)
 BEGIN
     SELECT 
             COUNT(*)
         INTO 
             p_total_orders
         FROM orders;
     END;


 /* Example 2: */
 CREATE PROCEDURE
     GetOrderSummary(OUT p_order_count   INT,
                     OUT p_total_revenue DECIMAL(10,2)
                     )
 BEGIN
     SELECT
             COUNT(*),
             SUM(amount)
         INTO
             p_order_count,
             p_total_revenue
         FROM orders;
 
 END;















-- 3.0 MySQL Stored Procedures: INOUT Parameters























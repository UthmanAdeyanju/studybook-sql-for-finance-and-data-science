 /*-- Database: HR_db*/
 
 
 /*-- 1. Write a MySQL query to find the name (first_name, last_name) and the salary of the 
 -- employees*/
 /*-- who have a higher salary than the employee whose last_name='Bull'.*/
 SELECT
         first_name,
         last_name,
         salary
     FROM employees
     WHERE salary >
         ( SELECT
                 salary
             FROM HR_db.employees
             WHERE last_name ='Bull');


-- 2. Write a MySQL query to find the name (first_name, last_name) of all employees who works in the IT department.
 SELECT 
         CONCAT(FIRST_NAME, " ", LAST_NAME) AS name, 
         d.DEPARTMENT_NAME
     FROM employees AS e
     JOIN HR_db.departments AS d 
     USING(DEPARTMENT_ID)
     WHERE d.DEPARTMENT_NAME ='IT';
     
     
     
     -- Selecting the first name and last name of employees 
SELECT first_name, last_name 
-- Selecting data from the employees table
FROM employees 
-- Filtering the result set to include only employees whose department_id is in the set of department_ids where the department_name is 'IT'
WHERE department_id 
IN (SELECT department_id FROM departments WHERE department_name='IT');




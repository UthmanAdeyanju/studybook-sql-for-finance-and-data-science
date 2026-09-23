 
 -- 1.0 MySQL Stored Procedures: IN Parameters 
 /* Example 1*/
 CALL GetEmployees()
 
 /* Example 2*/
 CALL GetCustomerOrders(363)
 CALL GetCustomerOrders(145)
 
 /*Example 3*/
 CALL GetOfficeByCountry('USA');
 CALL GetOfficeByCountry('France');
 
 /*Example 4*/
 CALL Highspender('UK');
 CALL Highspender('France');
 CALL Highspender('USA');


-- 2.0 MySQL Stored Procedures: OUT Parameters

 /* Example 1: */
CALL GetTotalOrders(@total_orders);
SELECT @total_orders as result;



 /* Example 2: */
CALL GetOrderSummary(@order_count, @total_revenue);
SELECT @order_count, @total_revenue;








-- 3.0 MySQL Stored Procedures: INOUT Parameters
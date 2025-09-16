-- Customers table
CREATE TABLE customers123 (
    cust_id NUMBER PRIMARY KEY,
    cust_name VARCHAR2(100),
    city VARCHAR2(50),
    credit_limit NUMBER(10,2)
);

-- Orders table
CREATE TABLE orders123 (
    order_id NUMBER PRIMARY KEY,
    cust_id NUMBER REFERENCES customers123(cust_id),
    order_date DATE,
    amount NUMBER(10,2)
);
select * from CUSTOMERS123;
-- Sample Data
INSERT INTO customers123 VALUES (1, 'John Electronics', 'New York', 5000);
INSERT INTO customers123 VALUES (2, 'Alice Retail', 'Chicago', 3000);
INSERT INTO orders123 VALUES (101, 1, TO_DATE('15-JAN-2023','DD-MON-YYYY'), 1500);
INSERT INTO orders123 VALUES (102, 2, TO_DATE('20-FEB-2023','DD-MON-YYYY'), 2000);

select * from orders123;


CREATE OR REPLACE VIEW csor AS
SELECT c.cust_id, c.cust_name, SUM(o.amount) AS total_spent
FROM customers123 c
JOIN orders123 o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_name;

-- updating view
CREATE OR REPLACE VIEW high_value_orders AS
SELECT o.order_id, c.cust_name, o.amount, c.city
FROM orders123 o
JOIN customers123 c ON o.cust_id = c.cust_id
WHERE o.amount > 500;  -- Changed criteria

select * from HIGH_VALUE_ORDERS;

-- inline view
SELECT c.cust_name, ord_stats.total
FROM customers123 c
JOIN (
    SELECT cust_id, COUNT(*) as total, SUM(amount) as total_amt
    FROM orders123
    GROUP BY cust_id
) ord_stats ON c.cust_id = ord_stats.cust_id;


CREATE OR REPLACE VIEW customer_orders AS
SELECT c.cust_id, c.cust_name, o.amount
FROM customers123 c
JOIN orders123 o ON c.cust_id = o.cust_id;

select * from CUSTOMER_ORDERS;

-- Update a record in the view
UPDATE customer_orders
SET amount = 200
WHERE cust_id = 1 AND amount = 1500;  -- Assuming cust_id 1 has an order with amount 150

-- Delete a record from the view
DELETE FROM customer_orders
WHERE cust_id = 1 AND amount = 200;  -- This will delete the order from the orders table

CREATE TABLE sales (
    sale_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    amount NUMBER,
    sale_date DATE
);

CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    category VARCHAR2(50)
);
-- using inline views
SELECT p.category, total_sales.total_amount
FROM products p
JOIN (
    SELECT product_id, SUM(amount) AS total_amount
    FROM sales
    GROUP BY product_id
) total_sales ON p.product_id = total_sales.product_id;

-- using Create a temporary table
CREATE GLOBAL TEMPORARY TABLE temp_sales_summary (
    product_id NUMBER,
    total_amount NUMBER
) ON COMMIT PRESERVE ROWS;

-- Insert aggregated data into the temporary table
INSERT INTO temp_sales_summary (product_id, total_amount)
SELECT product_id, SUM(amount)
FROM sales
GROUP BY product_id;

-- Query using the temporary table
SELECT p.category, ts.total_amount
FROM products p
JOIN temp_sales_summary ts ON p.product_id = ts.product_id;

-- Drop the temporary table (optional, if needed)
DROP TABLE temp_sales_summary;

-- Insert sample products
INSERT INTO products VALUES (101, 'Wireless Headphones', 'Electronics');
INSERT INTO products VALUES (102, 'Bluetooth Speaker', 'Electronics');
INSERT INTO products VALUES (201, 'Coffee Maker', 'Appliances');
INSERT INTO products VALUES (202, 'Toaster', 'Appliances');
INSERT INTO products VALUES (301, 'Yoga Mat', 'Fitness');

-- Insert sample sales
INSERT INTO sales VALUES (1, 101, 99.99, TO_DATE('10-JAN-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (2, 101, 89.99, TO_DATE('15-JAN-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (3, 102, 59.99, TO_DATE('20-JAN-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (4, 201, 129.99, TO_DATE('05-FEB-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (5, 202, 49.99, TO_DATE('12-FEB-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (6, 301, 29.99, TO_DATE('18-MAR-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (7, 101, 79.99, TO_DATE('25-MAR-2023','DD-MON-YYYY'));
INSERT INTO sales VALUES (8, 301, 34.99, TO_DATE('02-APR-2023','DD-MON-YYYY'));

/* Explanation of the Example
Inline View:

The subquery (SELECT product_id, SUM(amount) AS total_amount FROM sales GROUP BY product_id) is the inline view.
 It calculates the total sales amount for each product.
Main Query:

The main query selects the product category from the products table and joins it with the inline view to get the 
total sales amount for each category.
Benefits:

This approach simplifies the main query by encapsulating the aggregation logic in the inline view,
 making it easier to read and maintain.
Summary
Inline Views: Subqueries in the FROM clause that act as temporary tables.
Use Cases: Simplifying complex queries, performing aggregations, filtering data, and encapsulating logic.
Advantages: Improved readability, maintainability, and reduced need for temporary tables. */


-- Oracle automatically creates clustered index for PRIMARY KEY
-- To create an index-organized table (clustered):
CREATE TABLE employees_iot (
    emp_id NUMBER,
    emp_name VARCHAR2(100),
    dept_id NUMBER,
    PRIMARY KEY (emp_id)
) ORGANIZATION INDEX;


-- Create the accounts table
CREATE TABLE accounts (
    account_id NUMBER PRIMARY KEY,  -- Unique identifier for each account
    account_name VARCHAR2(100),      -- Name of the account holder
    balance NUMBER(10,2)             -- Balance amount in the account
);

-- Insert sample data into the accounts table
INSERT INTO accounts VALUES (101, 'John Doe', 5000.00);
INSERT INTO accounts VALUES (102, 'Jane Smith', 3000.00);
INSERT INTO accounts VALUES (103, 'Mike Johnson', 2000.00);
INSERT INTO accounts VALUES (104, 'Emily Davis', 1500.00);
INSERT INTO accounts VALUES (105, 'Chris Brown', 2500.00);

-- Commit the changes to the database
COMMIT;

SET TIMING ON;

-- Example query
SELECT * FROM accounts WHERE account_name = 'John Doe';


CREATE INDEX idx_account_name ON accounts(account_name);

SET TIMING ON;

-- Example query
SELECT * FROM accounts WHERE account_name = 'John Doe';

-- Before creating the index
EXPLAIN PLAN FOR SELECT * FROM accounts WHERE account_name = 'John Doe';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- After creating the index
EXPLAIN PLAN FOR SELECT * FROM accounts WHERE account_name = 'John Doe';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
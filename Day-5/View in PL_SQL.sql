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


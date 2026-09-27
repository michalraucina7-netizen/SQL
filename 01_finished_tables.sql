DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    profit DECIMAL(10,2)
);

/*
Úloha 2

SELECT o.order_id, c.customer_name, o.sales AS sales_value 
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.sales > 500
ORDER BY o.sales DESC;

Úloha 3

SELECT o.order_id, c.customer_name , p.category, o.sales AS sales_value 
FROM orders o 
JOIN products p ON p.product_id = o.product_id 
JOIN customers c ON c.customer_id = o.customer_id;

Úloha 4

SELECT c.region, SUM(o.sales) AS sales_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region;

Úloha 5

SELECT p.product_name, SUM(o.sales) AS sales_value
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name;

Úloha 6

SELECT c.customer_name, o.order_id, o.sales AS sales_value
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id; 

Úloha 7

SELECT o.sales AS sales_value, c.region 
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY region;

Úloha 8

SELECT c.customer_name, COUNT(o.order_id) AS order_count
FROM customer c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_name ;

Úloha 9 

SELECT p.category, AVG(o.discount) AS average_discount 
FROM products p
JOIN orders o ON o.product_id = p.product_id
GROUP BY p.category;

Úlohga 10 

SELECT c.customer_name, SUM(o.sales) AS order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_name
HAVING order_value > 2000;

Úloha 11

SELECT SUM(o.sales) AS sales_value, AVG(o.discount) AS average_discount, COUNT(o.orders) AS order_count, c.regoin
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region;

Úloha 12

SELECT 
    c.region, COUNT(CASE WHEN o.sales > 1000 THEN 1 END) AS high_value_count,
    COUNT(CASE WHEN o.sales <= 1000 THEN 1 END) AS low_value_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region;

Úloha 13

SELECT 
    c.customer_name, SUM(o.sales) AS total_sales, AVG(o.discount) AS avg_discount, COUNT(o.order_id) AS order_count,
    CASE 
        WHEN SUM(o.sales) > 2500 THEN 'VIP'
        ELSE 'REGULAR'
    END AS customer_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

*/
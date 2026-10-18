CREATE TABLE flourmills_sales (
    sales_id INT PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INT,
    quantity_sold INT,
    unit_price DECIMAL(10, 2),
    discount_rate INT,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INT,
    production_date DATE,
    total_amount DECIMAL(10, 2)
);
/*Uloha 1*/
WITH daily_sales AS (
    SELECT 
        sale_date,
        SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT 
    sale_date,
    total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

/*Uloha 2*/

WITH category_sales AS (
    SELECT 
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT 
    product_category,
    total_sales
FROM category_sales
ORDER BY total_sales DESC;

/*Úloha 3*/

WITH product_sales AS (
    SELECT 
        product_category,
        product_name,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT 
        product_category,
        product_name,
        total_product_sales,
        RANK() OVER (PARTITION BY product_category ORDER BY total_product_sales DESC) AS category_rank
    FROM product_sales
)
SELECT 
    product_category,
    product_name,
    total_product_sales,
    category_rank
FROM ranked_products
WHERE category_rank BETWEEN 1 AND 3
ORDER BY product_category, category_rank;

/*Úloha 4*/

WITH customer_sales AS (
    SELECT 
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
customer_percentage AS (
    SELECT 
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND((revenue * 100.0) / SUM(revenue) OVER (), 2) AS revenue_percentage
    FROM customer_sales
)
SELECT 
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM customer_percentage
ORDER BY revenue DESC;

/*Úloha 5*/

WITH ranked_transactions AS (
    SELECT 
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) as row_num
    FROM flourmills_sales
)
SELECT 
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM ranked_transactions
WHERE row_num = 1
ORDER BY customer_id ASC;

/*Úloha 6*/
WITH RECURSIVE date_bounds AS (
    SELECT 
        MIN(sale_date) AS start_date,
        MAX(sale_date) AS end_date
    FROM flourmills_sales
),
calendar AS (
    SELECT start_date AS sale_date, end_date
    FROM date_bounds
    UNION ALL
    SELECT CAST(sale_date + INTERVAL '1 day' AS DATE), end_date
    FROM calendar
    WHERE sale_date < end_date
)
SELECT sale_date
FROM calendar
ORDER BY sale_date ASC;

/*Úloha 7*/
WITH RECURSIVE monthly_revenue AS (
  SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT 
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1
    
    UNION ALL

    SELECT 
        om.rn,
        om.month,
        om.revenue,
        ct.cumulative_revenue + om.revenue AS cumulative_revenue
    FROM cumulative_target ct
    JOIN ordered_months om ON om.rn = ct.rn + 1
    WHERE ct.cumulative_revenue < 500000000
)
SELECT 
    month,
    cumulative_revenue
FROM cumulative_target
ORDER BY rn;
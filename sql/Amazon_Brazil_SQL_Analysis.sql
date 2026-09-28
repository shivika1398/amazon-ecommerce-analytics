-- Amazon Brazil / Amazon India Analytics Assignment
-- PostgreSQL / pgAdmin
-- Complete SQL submission: Analysis I, II and III

-- ANALYSIS I

-- Q1. Round average payment values by payment type.
SELECT payment_type, ROUND(AVG(payment_value)) AS average_payment_value
FROM amazon_brazil.payments
GROUP BY payment_type ORDER BY average_payment_value;

-- Q2. Percentage of total orders by payment type.
SELECT payment_type, COUNT(DISTINCT order_id) AS total_orders,
ROUND(COUNT(DISTINCT order_id) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM amazon_brazil.payments), 1) AS percentage_of_orders
FROM amazon_brazil.payments GROUP BY payment_type ORDER BY percentage_of_orders DESC;

-- Q3. Products priced 100-500 BRL containing 'Smart' in the available category-name field.
SELECT DISTINCT oi.product_id, oi.price
FROM amazon_brazil.order_items oi JOIN amazon_brazil.products p ON oi.product_id = p.product_id
WHERE oi.price BETWEEN 100 AND 500 AND LOWER(p.product_category_name) LIKE '%smart%'
ORDER BY oi.price DESC;

-- Q4. Top 3 months by total sales value.
SELECT EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp) AS sale_month, SUM(p.payment_value) AS total_sales
FROM amazon_brazil.orders o JOIN amazon_brazil.payments p ON o.order_id = p.order_id
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp)
ORDER BY total_sales DESC LIMIT 3;

-- Q5. Categories where max price - min price > 500 BRL.
SELECT p.product_category_name, MAX(oi.price) AS max_price, MIN(oi.price) AS min_price,
MAX(oi.price) - MIN(oi.price) AS price_difference
FROM amazon_brazil.products p JOIN amazon_brazil.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name HAVING MAX(oi.price) - MIN(oi.price) > 500
ORDER BY price_difference DESC;

-- Q6. Payment types with least variance (standard deviation).
SELECT payment_type, ROUND(STDDEV(payment_value), 2) AS standard_deviation
FROM amazon_brazil.payments GROUP BY payment_type ORDER BY standard_deviation;

-- Q7. Products with missing or one-character category names.
SELECT product_id, product_category_name FROM amazon_brazil.products
WHERE product_category_name IS NULL OR LENGTH(product_category_name) = 1 ORDER BY product_id;

-- ANALYSIS II

-- Q1. Segment order values and count payment types.
WITH order_values AS (
 SELECT order_id, SUM(payment_value) AS order_value FROM amazon_brazil.payments GROUP BY order_id
), order_segments AS (
 SELECT order_id, CASE WHEN order_value < 200 THEN 'Low' WHEN order_value <= 1000 THEN 'Medium' ELSE 'High' END AS order_segment
 FROM order_values
)
SELECT os.order_segment, p.payment_type, COUNT(*) AS payment_type_count
FROM order_segments os JOIN amazon_brazil.payments p ON os.order_id = p.order_id
GROUP BY os.order_segment, p.payment_type
ORDER BY CASE os.order_segment WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 WHEN 'High' THEN 3 END, payment_type_count DESC;

-- Q2. Minimum, maximum and average price by category.
SELECT p.product_category_name, MIN(oi.price) AS min_price, MAX(oi.price) AS max_price,
ROUND(AVG(oi.price), 2) AS average_price
FROM amazon_brazil.products p JOIN amazon_brazil.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name ORDER BY average_price DESC;

-- Q3. Customers with more than one order.
SELECT customer_id, COUNT(order_id) AS order_count FROM amazon_brazil.orders
GROUP BY customer_id HAVING COUNT(order_id) > 1 ORDER BY order_count DESC;

-- Q4. Customer types using a temporary table.
CREATE TEMP TABLE customer_types (min_orders INT, max_orders INT, customer_type VARCHAR(20));
INSERT INTO customer_types VALUES (1,1,'New'), (2,4,'Returning'), (5,NULL,'Loyal');
WITH customer_order_counts AS (
 SELECT customer_id, COUNT(order_id) AS order_count FROM amazon_brazil.orders GROUP BY customer_id
)
SELECT ct.customer_type, COUNT(coc.customer_id) AS customer_count
FROM customer_order_counts coc JOIN customer_types ct
ON coc.order_count >= ct.min_orders AND (ct.max_orders IS NULL OR coc.order_count <= ct.max_orders)
GROUP BY ct.customer_type
ORDER BY CASE ct.customer_type WHEN 'New' THEN 1 WHEN 'Returning' THEN 2 WHEN 'Loyal' THEN 3 END;

-- Q5. Top 5 categories by revenue.
SELECT p.product_category_name, SUM(oi.price) AS total_revenue
FROM amazon_brazil.order_items oi JOIN amazon_brazil.products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name ORDER BY total_revenue DESC LIMIT 5;

-- ANALYSIS III

-- Q1. Seasonal sales using a subquery.
SELECT season, SUM(payment_value) AS total_sales FROM (
 SELECT p.payment_value, CASE
 WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp) IN (3,4,5) THEN 'Spring'
 WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp) IN (6,7,8) THEN 'Summer'
 WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp::timestamp) IN (9,10,11) THEN 'Autumn'
 ELSE 'Winter' END AS season
 FROM amazon_brazil.orders o JOIN amazon_brazil.payments p ON o.order_id = p.order_id
) AS seasonal_data GROUP BY season ORDER BY total_sales DESC;

-- Q2. Products with sales volume above overall average. COUNT(*) is used because order_items has no quantity column.
SELECT product_id, COUNT(*) AS total_quantity_sold FROM amazon_brazil.order_items
GROUP BY product_id HAVING COUNT(*) > (
 SELECT AVG(total_quantity) FROM (
  SELECT product_id, COUNT(*) AS total_quantity FROM amazon_brazil.order_items GROUP BY product_id
 ) AS product_totals
) ORDER BY total_quantity_sold DESC;

-- Q3. Monthly revenue for 2018.
SELECT DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS sale_month,
ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM amazon_brazil.orders o JOIN amazon_brazil.payments p ON o.order_id = p.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp::timestamp) = 2018
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) ORDER BY sale_month;

-- Q4. Customer segmentation using a CTE.
WITH customer_order_counts AS (
 SELECT customer_id, COUNT(order_id) AS order_count FROM amazon_brazil.orders GROUP BY customer_id
), customer_segments AS (
 SELECT customer_id, CASE
 WHEN order_count BETWEEN 1 AND 2 THEN 'Occasional'
 WHEN order_count BETWEEN 3 AND 5 THEN 'Regular'
 WHEN order_count > 5 THEN 'Loyal' END AS customer_segment
 FROM customer_order_counts
)
SELECT customer_segment, COUNT(*) AS customer_count FROM customer_segments
GROUP BY customer_segment ORDER BY CASE customer_segment WHEN 'Occasional' THEN 1 WHEN 'Regular' THEN 2 WHEN 'Loyal' THEN 3 END;

-- Q5. Top 20 customers by average order value.
WITH order_values AS (
 SELECT order_id, customer_id, SUM(payment_value) AS order_value
 FROM amazon_brazil.orders o JOIN amazon_brazil.payments p ON o.order_id = p.order_id
 GROUP BY order_id, customer_id
), customer_average_order_value AS (
 SELECT customer_id, AVG(order_value) AS average_order_value FROM order_values GROUP BY customer_id
), ranked_customers AS (
 SELECT customer_id, average_order_value, ROW_NUMBER() OVER (ORDER BY average_order_value DESC) AS customer_rank
 FROM customer_average_order_value
)
SELECT customer_rank, customer_id, ROUND(average_order_value, 2) AS average_order_value
FROM ranked_customers WHERE customer_rank <= 20 ORDER BY customer_rank;

-- Q6. Monthly cumulative sales for each product from first sale using a recursive CTE.
WITH RECURSIVE monthly_sales AS (
 SELECT oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS sale_month, SUM(oi.price) AS monthly_sales
 FROM amazon_brazil.order_items oi JOIN amazon_brazil.orders o ON oi.order_id = o.order_id
 GROUP BY oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)
), ranked_sales AS (
 SELECT product_id, sale_month, monthly_sales, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY sale_month) AS rn
 FROM monthly_sales
), cumulative_sales AS (
 SELECT product_id, sale_month, monthly_sales AS total_sales, rn FROM ranked_sales WHERE rn = 1
 UNION ALL
 SELECT cs.product_id, rs.sale_month, cs.total_sales + rs.monthly_sales AS total_sales, rs.rn
 FROM cumulative_sales cs JOIN ranked_sales rs ON rs.product_id = cs.product_id AND rs.rn = cs.rn + 1
)
SELECT product_id, sale_month, ROUND(total_sales, 2) AS total_sales
FROM cumulative_sales ORDER BY product_id, sale_month;

-- Q7. Monthly sales by payment type and MoM growth in 2018 using LAG().
SELECT payment_type, sale_month, monthly_total,
ROUND(((monthly_total - previous_month_total) / NULLIF(previous_month_total, 0)) * 100, 2) AS monthly_change
FROM (
 SELECT p.payment_type, DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS sale_month,
 SUM(p.payment_value) AS monthly_total,
 LAG(SUM(p.payment_value)) OVER (PARTITION BY p.payment_type ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)) AS previous_month_total
 FROM amazon_brazil.payments p JOIN amazon_brazil.orders o ON p.order_id = o.order_id
 WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp::timestamp) = 2018
 GROUP BY p.payment_type, DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)
) AS monthly_data ORDER BY payment_type, sale_month;

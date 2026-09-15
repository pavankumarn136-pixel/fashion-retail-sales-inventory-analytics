CREATE DATABASE fashion_retail_analytics;
USE fashion_retail_analytics;

SELECT DATABASE();

DESCRIBE amazon_sales_cleaned;
SHOW TABLES;

SELECT COUNT(*)
FROM inventory_cleaned;

DESCRIBE inventory_cleaned;

SELECT COUNT(*)
FROM amazon_sales_cleaned;

SELECT * 
FROM amazon_sales_cleaned
LIMIT 10;

DROP TABLE amazon_sales_cleaned;

SELECT COUNT(*)
FROM amazon_sales_cleaned;

-- Q1. How many unique SKUs are common between the sales and inventory datasets?

SELECT COUNT(DISTINCT a.sku) AS matching_skus
FROM amazon_sales_cleaned a
Join inventory_cleaned i
ON  a.sku = i.sku;

-- Q2. How many unique SKUs are present in each table?

SELECT 
	(SELECT COUNT(DISTINCT sku)
    FROM amazon_sales_cleaned) AS  sales_skus,
    
    (SELECT COUNT(DISTINCT sku)
    FROM inventory_cleaned) AS inventory_skus;

-- Q3. How many Sales SKUs do not exist in the Inventory table?

SELECT COUNT(DISTINCT a.sku) AS sales_skus_not_in_inventory
FROM amazon_sales_cleaned a
LEFT JOIN inventory_cleaned i
ON a.sku = i.sku
WHERE i.sku IS NULL;

-- Q4. What is the total available stock in inventory?

SELECT SUM(stock) AS total_stock
FROM inventory_cleaned;
    
-- Q5. What is the stock distribution by stock status? / To understand how much inventory is In Stock, Low Stock, or Out of Stock--
SELECT 
	stock_status,
	COUNT(*) AS sku_records,
	SUM(stock) AS total_stock
FROM inventory_cleaned
GROUP BY stock_status
ORDER BY total_stock DESC;

-- Q6. Which categories have the highest total stock?

SELECT category, SUM(stock) AS total_stock
FROM inventory_cleaned
GROUP BY category
ORDER BY total_stock DESC;

-- Q7. What is the total revenue and total units sold?

SELECT SUM(amount) AS total_revenue,
SUM(qty) AS total_units_sold
FROM amazon_sales_cleaned;

-- Q8. What is the revenue and units sold by category?

SELECT category, ROUND(SUM(amount),2) AS total_revenue,
	SUM(qty) AS units_sold
FROM amazon_sales_cleaned
GROUP BY category
ORDER BY total_revenue DESC;

-- Q9. Which states generate the highest revenue?

SELECT ship_state,
	ROUND(SUM(amount),2) As total_revenue,
    SUM(qty) AS units_sold
FROM amazon_sales_cleaned
GROUP BY ship_state
ORDER BY total_revenue DESC
LIMIT 10;

-- Q10. Which months generated the highest revenue?

SELECT
    `year_month`,
    ROUND(SUM(amount),2) AS total_revenue,
    SUM(qty) AS units_sold
FROM amazon_sales_cleaned
GROUP BY `year_month`
ORDER BY total_revenue DESC;

-- Q10 — Which order statuses generate the most revenue?

SELECT status_group,
	ROUND(SUM(amount),2) AS total_revenue,
    SUM(qty) AS  units_sold
FROM amazon_sales_cleaned
GROUP BY status_group
ORDER BY  total_revenue DESC;

-- Q11. What percentage of units fall under each order status?

SELECT
    status_group,
    SUM(qty) AS units,
    ROUND(
        SUM(qty) * 100.0 /
        (SELECT SUM(qty) FROM amazon_sales_cleaned),
        2
    ) AS percentage
FROM amazon_sales_cleaned
GROUP BY status_group
ORDER BY percentage DESC;

-- Q12. Which SKUs generated the highest revenue?

SELECT
    sku,
    ROUND(SUM(amount),2) AS total_revenue,
    SUM(qty) AS units_sold
FROM amazon_sales_cleaned
GROUP BY sku
ORDER BY total_revenue DESC
LIMIT 10;

-- Q13. How do B2B and non-B2B customers compare in sales?

SELECT customer_type,
	ROUND(SUM(amount),2) AS total_revenue,
    SUM(qty) AS units_sold,
    COUNT(DISTINCT order_id) AS total_orders
FROM amazon_sales_cleaned
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Q14. Which fulfilment method generates the most revenue?

SELECT fulfilment, 
	ROUND(SUM(amount),2) AS total_revenue,
    COUNT(qty) AS units_sold,
    COUNT(DISTINCT order_id) AS total_orders
FROM amazon_sales_cleaned
GROUP BY fulfilment
ORDER BY total_revenue DESC;

-- Q15. Which sales channel generates the most revenue?

SELECT sales_channel,
	ROUND(SUM(amount),2) As total_revenue,
    COUNT(qty) AS units_sold,
    COUNT(DISTINCT order_id) AS total_orders
FROM amazon_sales_cleaned
GROUP BY sales_channel
ORDER BY total_revenue DESC;


-- Q15A. What are the total number of sales records, units sold, and unique orders in the dataset?
SELECT
    COUNT(*) AS rows_count,
    SUM(qty) AS total_qty,
    COUNT(DISTINCT order_id) AS unique_orders
FROM amazon_sales_cleaned;

-- Q16. Which sold SKUs are currently low stock or out of stock?

SELECT 
	a.sku,
    SUM(a.qty) AS units_sold,
    i.stock,
    i.stock_status
FROM amazon_sales_cleaned a
JOIN inventory_cleaned i
	ON a.sku = i.sku
WHERE i.stock_status IN ('Low Stock','Out of Stock')
GROUP BY a.sku,i.stock,i.stock_status
ORDER BY units_sold DESC
LIMIT 10;

-- Q17. Which sizes generate the highest sales?

SELECT size,
	SUM(qty) AS units_sold,
	ROUND(SUM(amount),2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY size
ORDER BY units_sold DESC;


-- Q18. Which day of the week generates the highest sales?

SELECT day_name,
	SUM(qty) AS units_sold,
    ROUND(SUM(amount),2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM amazon_sales_cleaned
GROUP BY day_name
ORDER BY total_revenue DESC;

-- Q19. Rank the top 3 SKUs by revenue within each category?

WITH sku_sales AS( 
	SELECT category, sku,
    ROUND(SUM(amount),2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY category,sku),

ranked_skus AS ( 
	SELECT category,sku,total_revenue,
		DENSE_RANK() OVER(PARTITION BY category
        ORDER BY total_revenue DESC) AS revenue_rank
        FROM sku_sales)
        
SELECT * 
FROM ranked_skus
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;

-- Q20. Which top-selling SKUs have low or out-of-stock inventory and may require restocking?

SELECT
    a.sku,
    a.category,
    SUM(a.qty) AS units_sold,
    i.stock AS current_stock,
    i.stock_status
FROM amazon_sales_cleaned a
JOIN inventory_cleaned i
    ON a.sku = i.sku
WHERE i.stock_status IN ('Low Stock','Out of Stock')
GROUP BY
    a.sku,
    a.category,
    i.stock,
    i.stock_status
ORDER BY units_sold DESC
LIMIT 10;

USE fashion_retail_analytics;

SHOW TABLES;


-- How many inventory records and unique SKUs are there in each stock status?
SELECT stock_status,
	COUNT(*) AS rows_count,
    COUNT(DISTINCT sku) AS unique_skus
FROM inventory_cleaned
GROUP BY stock_status;

-- Check inventory status for a specific SKU

SELECT
    sku,
    stock,
    stock_status
FROM inventory_cleaned
WHERE sku = 'JNE3405-KR-M';


-- Which Top 10 products had the highest sales but are currently Low Stock?

SELECT
    a.sku,
    a.category,
    SUM(a.qty) AS units_sold,
    MAX(i.stock) AS current_stock
FROM amazon_sales_cleaned a
JOIN inventory_cleaned i
    ON a.sku = i.sku
WHERE i.stock_status = 'Low Stock'
GROUP BY
    a.sku,
    a.category
ORDER BY
    units_sold DESC
LIMIT 10;


-- Which Top 10 products had the highest sales but are currently Out of Stock?

SELECT
    a.sku,
    a.category,
    SUM(a.qty) AS units_sold,
    MAX(i.stock) AS current_stock
FROM amazon_sales_cleaned a
JOIN inventory_cleaned i
    ON a.sku = i.sku
WHERE i.stock_status = 'Out of Stock'
GROUP BY
    a.sku,
    a.category
ORDER BY
    units_sold DESC
LIMIT 10;
-- Check 1: Order status distribution
-- Finding: 96,478 of 99,441 orders (97.0%) are delivered.
-- Decision: revenue and delivery analysis will use delivered orders only.
SELECT order_status, COUNT(*) AS n
FROM orders
GROUP BY order_status
ORDER BY n DESC

-- Check 2a: What period does the data cover?
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

-- Check 2b: Orders per month (to spot partial months)
SELECT date_trunc('month', order_purchase_timestamp) AS order_month,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;

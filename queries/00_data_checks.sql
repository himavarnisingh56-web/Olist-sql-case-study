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

-- Check 3a: How many orders are missing a delivery date?

sql
SELECT COUNT(*) AS total_orders,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date
FROM orders;

-- Check 3b: Which statuses do the missing dates belong to?

sql
SELECT order_status,
       COUNT(*) AS orders,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Check 3c: Delivered orders that still have no delivery date

sql
SELECT COUNT(*) AS delivered_but_no_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

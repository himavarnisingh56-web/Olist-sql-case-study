-- Check 1: Order status distribution
-- Finding: 96,478 of 99,441 orders (97.0%) are delivered.
-- Decision: revenue and delivery analysis will use delivered orders only.
SELECT order_status, COUNT(*) AS n
FROM orders
GROUP BY order_status
ORDER BY n DESC;

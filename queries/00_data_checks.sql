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

SELECT COUNT(*) AS total_orders,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date
FROM orders;

-- Check 3b: Which statuses do the missing dates belong to?

SELECT order_status,
       COUNT(*) AS orders,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Check 3c: Delivered orders that still have no delivery date

SELECT COUNT(*) AS delivered_but_no_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- Check 4: Is order_id unique in orders?

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;

--Check 5: Customer IDs

SELECT COUNT(DISTINCT customer_id) AS customer_ids,
       COUNT(DISTINCT customer_unique_id) AS real_customers
FROM customers;

-- Check 6a: Rows per order in order_items
SELECT COUNT(*) AS item_rows,
       COUNT(DISTINCT order_id) AS orders_in_items
FROM order_items;

-- Check 6b: Rows per order in order_payments
SELECT COUNT(*) AS payment_rows,
       COUNT(DISTINCT order_id) AS orders_in_payments
FROM order_payments;

-- Check 6c: Revenue from order_items alone (correct baseline)
SELECT SUM(price) AS item_revenue
FROM order_items;

-- Check 6d: Same revenue after a naive join to payments (inflated)
SELECT SUM(oi.price) AS inflated_item_revenue
FROM order_items oi
JOIN order_payments op ON oi.order_id = op.order_id;

-- Check 6e: The correct way: aggregate payments to one row per order first
WITH pay AS (
  SELECT order_id, SUM(payment_value) AS total_paid
  FROM order_payments
  GROUP BY order_id
)
SELECT SUM(oi.price) AS item_revenue_after_safe_join
FROM order_items oi
JOIN pay ON oi.order_id = pay.order_id;

-- Check 7a: Products with no category at all
SELECT COUNT(*) AS total_products,
       SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category
FROM products;

-- Check 7b: Products with no English category name, split by cause
SELECT CASE WHEN p.product_category_name IS NULL THEN 'no category in products'
            ELSE 'category has no translation' END AS reason,
       COUNT(*) AS products
FROM products p
LEFT JOIN category_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL
GROUP BY 1;

-- Check 7c: Which categories lack a translation?
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL
  AND p.product_category_name IS NOT NULL;

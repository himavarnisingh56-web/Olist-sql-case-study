
%sql

SELECT
    ct.product_category_name_english AS product_category,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS total_items_sold

FROM workspace.olist.orders AS o

INNER JOIN workspace.olist.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN workspace.olist.products AS p
    ON oi.product_id = p.product_id

INNER JOIN workspace.olist.category_translation AS ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    ct.product_category_name_english

ORDER BY
    total_revenue DESC

LIMIT 10;


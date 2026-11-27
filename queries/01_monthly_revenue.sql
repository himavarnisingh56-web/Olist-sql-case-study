
%sql

SELECT
    DATE_TRUNC('MONTH', o.order_purchase_timestamp) AS order_month,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id), 2
    ) AS average_order_value

FROM workspace.olist.orders AS o

INNER JOIN workspace.olist.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    DATE_TRUNC('MONTH', o.order_purchase_timestamp)

ORDER BY
    order_month ASC;


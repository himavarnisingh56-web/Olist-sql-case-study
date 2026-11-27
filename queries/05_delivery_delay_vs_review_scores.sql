
%sql

WITH review_data AS (

    SELECT
        order_id,
        AVG(review_score) AS review_score

    FROM workspace.olist.order_reviews

    WHERE review_score IS NOT NULL

    GROUP BY order_id
),

delivery_data AS (

    SELECT
        o.order_id,

        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) AS delay_days,

        r.review_score

    FROM workspace.olist.orders AS o

    INNER JOIN review_data AS r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
),

delivery_categories AS (

    SELECT
        order_id,
        delay_days,
        review_score,

        CASE
            WHEN delay_days <= 0
                THEN 'On Time'

            WHEN delay_days BETWEEN 1 AND 7
                THEN '1-7 Days Late'

            WHEN delay_days > 7
                THEN 'More Than 7 Days Late'
        END AS delivery_category

    FROM delivery_data
)

SELECT
    delivery_category,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(AVG(review_score), 2) AS average_review_score,

    ROUND(AVG(delay_days), 2) AS average_delay_days

FROM delivery_categories

GROUP BY delivery_category

ORDER BY
    CASE delivery_category
        WHEN 'On Time' THEN 1
        WHEN '1-7 Days Late' THEN 2
        WHEN 'More Than 7 Days Late' THEN 3
    END;

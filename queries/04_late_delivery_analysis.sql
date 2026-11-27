
-- =====================================================
-- BUSINESS QUESTION 4:
-- Late Delivery Analysis by Brazilian State
-- =====================================================

-- QUERY 1: Late Delivery Percentage by State

WITH delivery_data AS (

    SELECT
        o.order_id,
        c.customer_state AS state,

        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) AS days_difference,

        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END AS late_flag

    FROM workspace.olist.orders AS o

    INNER JOIN workspace.olist.customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
),

state_metrics AS (

    SELECT
        state,
        COUNT(*) AS total_delivered_orders,
        SUM(late_flag) AS late_orders,

        ROUND(
            SUM(late_flag) * 100.0 / COUNT(*), 2
        ) AS late_delivery_percentage

    FROM delivery_data
    GROUP BY state
)

SELECT *
FROM state_metrics
ORDER BY late_delivery_percentage DESC;


-- =====================================================
-- QUERY 2: Overall Late Delivery Percentage
-- =====================================================

SELECT
    COUNT(*) AS total_delivered_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS total_late_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS overall_late_delivery_percentage

FROM workspace.olist.orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

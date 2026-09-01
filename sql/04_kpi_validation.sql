-- ============================================================
-- Supply Chain & Inventory Intelligence
-- Validación de KPIs utilizados en Power BI
-- ============================================================


-- ============================================================
-- OVERVIEW
-- ============================================================

SELECT
    ROUND(
        SUM(extended_price - tax_amount)::numeric,
        2
    ) AS net_sales,

    ROUND(
        SUM(line_profit)::numeric,
        2
    ) AS gross_profit,

    COUNT(DISTINCT order_id) AS invoiced_orders

FROM analytics.fact_sales;


SELECT
    ROUND(
        100.0 *
        COUNT(DISTINCT order_id)
            FILTER (WHERE is_on_time_delivery = TRUE)
        /
        NULLIF(
            COUNT(DISTINCT order_id)
                FILTER (WHERE is_on_time_delivery IS NOT NULL),
            0
        ),
        2
    ) AS on_time_delivery_pct

FROM analytics.fact_fulfillment;


-- ============================================================
-- INVENTORY
-- ============================================================

SELECT
    ROUND(
        SUM(quantity_on_hand * last_cost_price)::numeric,
        2
    ) AS inventory_value,

    SUM(quantity_on_hand) AS total_stock_units,

    COUNT(DISTINCT product_id)
        FILTER (
            WHERE quantity_on_hand < reorder_level
        ) AS products_below_reorder,

    COUNT(DISTINCT product_id)
        FILTER (
            WHERE quantity_on_hand > target_stock_level
        ) AS products_above_target

FROM analytics.fact_inventory;


-- ============================================================
-- LOGISTICS
-- ============================================================

SELECT
    ROUND(
        100.0 *
        COUNT(DISTINCT order_id)
            FILTER (WHERE is_on_time_delivery = TRUE)
        /
        NULLIF(
            COUNT(DISTINCT order_id)
                FILTER (WHERE is_on_time_delivery IS NOT NULL),
            0
        ),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        100.0 *
        COUNT(DISTINCT order_id)
            FILTER (WHERE is_backordered = TRUE)
        /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS orders_with_backorder_pct,

    ROUND(
        100.0 *
        SUM(picked_quantity)
        /
        NULLIF(SUM(ordered_quantity), 0),
        2
    ) AS picking_fill_rate_pct

FROM analytics.fact_fulfillment;


-- Mediana del retraso calculada por orden,
-- no por línea de producto.

WITH order_delays AS (
    SELECT
        order_id,
        MAX(delivery_delay_days) AS delay_days
    FROM analytics.fact_fulfillment
    GROUP BY order_id
)

SELECT
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY delay_days)::numeric,
        0
    ) AS median_late_delivery_delay

FROM order_delays

WHERE delay_days > 0;


-- ============================================================
-- SUPPLIERS
-- ============================================================

SELECT
    ROUND(
        SUM(expected_purchase_value)::numeric,
        2
    ) AS expected_po_value,

    COUNT(DISTINCT purchase_order_id) AS purchase_orders,

    COUNT(DISTINCT supplier_id) AS active_suppliers,

    ROUND(
        (
            SUM(expected_purchase_value)
            /
            NULLIF(COUNT(DISTINCT purchase_order_id), 0)
        )::numeric,
        2
    ) AS average_expected_po_value

FROM analytics.fact_purchases;
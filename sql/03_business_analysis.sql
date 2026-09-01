-- ============================================================
-- Supply Chain & Inventory Intelligence
-- Consultas principales de análisis de negocio
-- ============================================================


-- ============================================================
-- 1. NET SALES POR TERRITORIO
-- ============================================================

SELECT
    c.sales_territory,
    ROUND(
        SUM(f.extended_price - f.tax_amount)::numeric,
        2
    ) AS net_sales,
    ROUND(
        SUM(f.line_profit)::numeric,
        2
    ) AS gross_profit,
    COUNT(DISTINCT f.order_id) AS invoiced_orders
FROM analytics.fact_sales f
JOIN analytics.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.sales_territory
ORDER BY net_sales DESC;


-- ============================================================
-- 2. PRODUCTOS CON MAYOR INVENTORY VALUE ABOVE TARGET
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    i.quantity_on_hand,
    i.target_stock_level,
    i.last_cost_price,

    ROUND(
        (
            (i.quantity_on_hand - i.target_stock_level)
            * i.last_cost_price
        )::numeric,
        2
    ) AS inventory_value_above_target

FROM analytics.fact_inventory i
JOIN analytics.dim_product p
    ON i.product_id = p.product_id

WHERE i.quantity_on_hand > i.target_stock_level

ORDER BY inventory_value_above_target DESC

LIMIT 10;


-- ============================================================
-- 3. FULFILLMENT POR SALES TERRITORY
-- ============================================================

SELECT
    c.sales_territory,

    COUNT(DISTINCT f.order_id) AS fulfillment_orders,

    ROUND(
        100.0 *
        COUNT(DISTINCT f.order_id)
            FILTER (WHERE f.is_on_time_delivery = TRUE)
        /
        NULLIF(
            COUNT(DISTINCT f.order_id)
                FILTER (WHERE f.is_on_time_delivery IS NOT NULL),
            0
        ),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        100.0 *
        COUNT(DISTINCT f.order_id)
            FILTER (WHERE f.is_backordered = TRUE)
        /
        NULLIF(COUNT(DISTINCT f.order_id), 0),
        2
    ) AS orders_with_backorder_pct,

    ROUND(
        100.0 *
        SUM(f.picked_quantity)
        /
        NULLIF(SUM(f.ordered_quantity), 0),
        2
    ) AS picking_fill_rate_pct

FROM analytics.fact_fulfillment f
JOIN analytics.dim_customer c
    ON f.customer_id = c.customer_id

GROUP BY c.sales_territory

ORDER BY orders_with_backorder_pct DESC;


-- ============================================================
-- 4. EXPECTED PO VALUE POR PROVEEDOR
-- ============================================================

SELECT
    s.supplier_name,

    ROUND(
        SUM(f.expected_purchase_value)::numeric,
        2
    ) AS expected_po_value,

    COUNT(DISTINCT f.purchase_order_id) AS purchase_orders

FROM analytics.fact_purchases f
JOIN analytics.dim_supplier s
    ON f.supplier_id = s.supplier_id

GROUP BY s.supplier_name

ORDER BY expected_po_value DESC;


-- ============================================================
-- 5. EVOLUCIÓN MENSUAL DEL EXPECTED PO VALUE
-- ============================================================

SELECT
    d.year_month,

    ROUND(
        SUM(f.expected_purchase_value)::numeric,
        2
    ) AS expected_po_value,

    COUNT(DISTINCT f.purchase_order_id) AS purchase_orders

FROM analytics.fact_purchases f
JOIN analytics.dim_date d
    ON f.order_date_id = d.date_id

GROUP BY d.year_month

ORDER BY MIN(d.date);
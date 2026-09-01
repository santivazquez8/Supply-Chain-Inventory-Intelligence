-- ============================================================
-- Supply Chain & Inventory Intelligence
-- Revisión de la capa analítica
-- ============================================================

-- Dimensiones

SELECT 'dim_product' AS table_name, COUNT(*) AS row_count
FROM analytics.dim_product

UNION ALL

SELECT 'dim_customer', COUNT(*)
FROM analytics.dim_customer

UNION ALL

SELECT 'dim_supplier', COUNT(*)
FROM analytics.dim_supplier

UNION ALL

SELECT 'dim_delivery_method', COUNT(*)
FROM analytics.dim_delivery_method

UNION ALL

SELECT 'dim_stock_group', COUNT(*)
FROM analytics.dim_stock_group

UNION ALL

SELECT 'bridge_product_stock_group', COUNT(*)
FROM analytics.bridge_product_stock_group

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM analytics.dim_date

UNION ALL

-- Tablas de hechos

SELECT 'fact_sales', COUNT(*)
FROM analytics.fact_sales

UNION ALL

SELECT 'fact_fulfillment', COUNT(*)
FROM analytics.fact_fulfillment

UNION ALL

SELECT 'fact_inventory', COUNT(*)
FROM analytics.fact_inventory

UNION ALL

SELECT 'fact_purchases', COUNT(*)
FROM analytics.fact_purchases

ORDER BY table_name;


-- ============================================================
-- Validación de claves principales
-- ============================================================

-- Sales: una fila por sales_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT sales_id) AS unique_sales_ids
FROM analytics.fact_sales;


-- Inventory: una fila por producto
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_products
FROM analytics.fact_inventory;


-- Purchases: una fila por purchase_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT purchase_id) AS unique_purchase_ids
FROM analytics.fact_purchases;
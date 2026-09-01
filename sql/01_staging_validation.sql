-- ============================================================
-- Supply Chain & Inventory Intelligence
-- Validación de tablas cargadas en staging
-- ============================================================

SELECT 'application_cities' AS table_name, COUNT(*) AS row_count
FROM staging.application_cities

UNION ALL

SELECT 'application_countries', COUNT(*)
FROM staging.application_countries

UNION ALL

SELECT 'application_deliverymethods', COUNT(*)
FROM staging.application_deliverymethods

UNION ALL

SELECT 'application_stateprovinces', COUNT(*)
FROM staging.application_stateprovinces

UNION ALL

SELECT 'purchasing_purchaseorderlines', COUNT(*)
FROM staging.purchasing_purchaseorderlines

UNION ALL

SELECT 'purchasing_purchaseorders', COUNT(*)
FROM staging.purchasing_purchaseorders

UNION ALL

SELECT 'purchasing_suppliercategories', COUNT(*)
FROM staging.purchasing_suppliercategories

UNION ALL

SELECT 'purchasing_suppliers', COUNT(*)
FROM staging.purchasing_suppliers

UNION ALL

SELECT 'sales_customers', COUNT(*)
FROM staging.sales_customers

UNION ALL

SELECT 'sales_invoicelines', COUNT(*)
FROM staging.sales_invoicelines

UNION ALL

SELECT 'sales_invoices', COUNT(*)
FROM staging.sales_invoices

UNION ALL

SELECT 'sales_orderlines', COUNT(*)
FROM staging.sales_orderlines

UNION ALL

SELECT 'sales_orders', COUNT(*)
FROM staging.sales_orders

UNION ALL

SELECT 'warehouse_stockgroups', COUNT(*)
FROM staging.warehouse_stockgroups

UNION ALL

SELECT 'warehouse_stockitemholdings', COUNT(*)
FROM staging.warehouse_stockitemholdings

UNION ALL

SELECT 'warehouse_stockitems', COUNT(*)
FROM staging.warehouse_stockitems

UNION ALL

SELECT 'warehouse_stockitemstockgroups', COUNT(*)
FROM staging.warehouse_stockitemstockgroups

UNION ALL

SELECT 'warehouse_stockitemtransactions', COUNT(*)
FROM staging.warehouse_stockitemtransactions

ORDER BY table_name;
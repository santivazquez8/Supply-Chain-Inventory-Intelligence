SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
ORDER BY table_name;

SELECT 'application_cities' AS table_name, COUNT(*) AS rows FROM staging.application_cities
UNION ALL
SELECT 'application_countries', COUNT(*) FROM staging.application_countries
UNION ALL
SELECT 'application_deliverymethods', COUNT(*) FROM staging.application_deliverymethods
UNION ALL
SELECT 'application_stateprovinces', COUNT(*) FROM staging.application_stateprovinces
UNION ALL
SELECT 'purchasing_purchaseorderlines', COUNT(*) FROM staging.purchasing_purchaseorderlines
UNION ALL
SELECT 'purchasing_purchaseorders', COUNT(*) FROM staging.purchasing_purchaseorders
UNION ALL
SELECT 'purchasing_suppliercategories', COUNT(*) FROM staging.purchasing_suppliercategories
UNION ALL
SELECT 'purchasing_suppliers', COUNT(*) FROM staging.purchasing_suppliers
UNION ALL
SELECT 'sales_customers', COUNT(*) FROM staging.sales_customers
UNION ALL
SELECT 'sales_invoicelines', COUNT(*) FROM staging.sales_invoicelines
UNION ALL
SELECT 'sales_invoices', COUNT(*) FROM staging.sales_invoices
UNION ALL
SELECT 'sales_orderlines', COUNT(*) FROM staging.sales_orderlines
UNION ALL
SELECT 'sales_orders', COUNT(*) FROM staging.sales_orders
UNION ALL
SELECT 'warehouse_stockgroups', COUNT(*) FROM staging.warehouse_stockgroups
UNION ALL
SELECT 'warehouse_stockitemholdings', COUNT(*) FROM staging.warehouse_stockitemholdings
UNION ALL
SELECT 'warehouse_stockitems', COUNT(*) FROM staging.warehouse_stockitems
UNION ALL
SELECT 'warehouse_stockitemstockgroups', COUNT(*) FROM staging.warehouse_stockitemstockgroups
UNION ALL
SELECT 'warehouse_stockitemtransactions', COUNT(*) FROM staging.warehouse_stockitemtransactions;



CREATE SCHEMA analytics;

CREATE TABLE analytics.dim_product AS
SELECT
    "StockItemID" AS product_id,
    "StockItemName" AS product_name,
    "SupplierID" AS supplier_id,
    "ColorID" AS color_id,
    "UnitPackageID" AS unit_package_id,
    "OuterPackageID" AS outer_package_id,
    "Brand" AS brand,
    "Size" AS size,
    "LeadTimeDays" AS lead_time_days,
    "QuantityPerOuter" AS quantity_per_outer,
    "IsChillerStock" AS is_chiller_stock,
    "TaxRate" AS tax_rate,
    "UnitPrice" AS unit_price,
    "RecommendedRetailPrice" AS recommended_retail_price,
    "TypicalWeightPerUnit" AS typical_weight_per_unit
FROM staging.warehouse_stockitems;

SELECT COUNT(*)
FROM analytics.dim_product;

CREATE TABLE analytics.dim_supplier AS
SELECT
    "SupplierID" AS supplier_id,
    "SupplierName" AS supplier_name,
    "SupplierCategoryID" AS supplier_category_id,
    "PrimaryContactPersonID" AS primary_contact_person_id,
    "AlternateContactPersonID" AS alternate_contact_person_id,
    "DeliveryMethodID" AS delivery_method_id,
    "DeliveryCityID" AS delivery_city_id,
    "PostalCityID" AS postal_city_id,
    "SupplierReference" AS supplier_reference,
    "PaymentDays" AS payment_days,
    "PhoneNumber" AS phone_number,
    "FaxNumber" AS fax_number,
    "WebsiteURL" AS website_url
FROM staging.purchasing_suppliers;

SELECT COUNT(*)
FROM analytics.dim_supplier;

DROP TABLE IF EXISTS analytics.bridge_product_stock_group;
DROP TABLE IF EXISTS analytics.dim_date;
DROP TABLE IF EXISTS analytics.dim_delivery_method;
DROP TABLE IF EXISTS analytics.dim_stock_group;
DROP TABLE IF EXISTS analytics.dim_customer;
DROP TABLE IF EXISTS analytics.dim_supplier;
DROP TABLE IF EXISTS analytics.dim_product;


-- 1. PRODUCTOS
CREATE TABLE analytics.dim_product AS
SELECT
    "StockItemID" AS product_id,
    "StockItemName" AS product_name,
    "SupplierID" AS supplier_id,
    "ColorID" AS color_id,
    "Brand" AS brand,
    "Size" AS size,
    "LeadTimeDays" AS lead_time_days,
    "QuantityPerOuter" AS quantity_per_outer,
    "IsChillerStock" AS is_chiller_stock,
    "TaxRate" AS tax_rate,
    "UnitPrice" AS unit_price,
    "RecommendedRetailPrice" AS recommended_retail_price,
    "TypicalWeightPerUnit" AS typical_weight_per_unit
FROM staging.warehouse_stockitems;


-- 2. PROVEEDORES
CREATE TABLE analytics.dim_supplier AS
SELECT
    s."SupplierID" AS supplier_id,
    s."SupplierName" AS supplier_name,
    s."SupplierCategoryID" AS supplier_category_id,
    sc."SupplierCategoryName" AS supplier_category,
    s."DeliveryMethodID" AS delivery_method_id,
    s."DeliveryCityID" AS delivery_city_id,
    s."PaymentDays" AS payment_days,
    s."PhoneNumber" AS phone_number,
    s."WebsiteURL" AS website_url,
    c."CityName" AS city,
    sp."StateProvinceName" AS state_province,
    co."CountryName" AS country
FROM staging.purchasing_suppliers s
LEFT JOIN staging.purchasing_suppliercategories sc
    ON s."SupplierCategoryID" = sc."SupplierCategoryID"
LEFT JOIN staging.application_cities c
    ON s."DeliveryCityID" = c."CityID"
LEFT JOIN staging.application_stateprovinces sp
    ON c."StateProvinceID" = sp."StateProvinceID"
LEFT JOIN staging.application_countries co
    ON sp."CountryID" = co."CountryID";


-- 3. CLIENTES
CREATE TABLE analytics.dim_customer AS
SELECT
    cst."CustomerID" AS customer_id,
    cst."CustomerName" AS customer_name,
    cst."CustomerCategoryID" AS customer_category_id,
    cst."BuyingGroupID" AS buying_group_id,
    cst."DeliveryCityID" AS delivery_city_id,
    cst."CreditLimit" AS credit_limit,
    cst."AccountOpenedDate"::date AS account_opened_date,
    cst."StandardDiscountPercentage" AS standard_discount_percentage,
    cst."IsOnCreditHold" AS is_on_credit_hold,
    cst."PaymentDays" AS payment_days,
    c."CityName" AS city,
    sp."StateProvinceName" AS state_province,
    sp."SalesTerritory" AS sales_territory,
    co."CountryName" AS country
FROM staging.sales_customers cst
LEFT JOIN staging.application_cities c
    ON cst."DeliveryCityID" = c."CityID"
LEFT JOIN staging.application_stateprovinces sp
    ON c."StateProvinceID" = sp."StateProvinceID"
LEFT JOIN staging.application_countries co
    ON sp."CountryID" = co."CountryID";


-- 4. MÉTODOS DE ENTREGA
CREATE TABLE analytics.dim_delivery_method AS
SELECT
    "DeliveryMethodID" AS delivery_method_id,
    "DeliveryMethodName" AS delivery_method_name
FROM staging.application_deliverymethods;


-- 5. GRUPOS / CATEGORÍAS DE PRODUCTO
CREATE TABLE analytics.dim_stock_group AS
SELECT
    "StockGroupID" AS stock_group_id,
    "StockGroupName" AS stock_group_name
FROM staging.warehouse_stockgroups;


-- 6. RELACIÓN PRODUCTO ↔ CATEGORÍA
CREATE TABLE analytics.bridge_product_stock_group AS
SELECT
    "StockItemID" AS product_id,
    "StockGroupID" AS stock_group_id
FROM staging.warehouse_stockitemstockgroups;


-- 7. CALENDARIO
CREATE TABLE analytics.dim_date AS
WITH date_values AS (

    SELECT "OrderDate"::date AS date_value
    FROM staging.sales_orders

    UNION ALL

    SELECT "ExpectedDeliveryDate"::date
    FROM staging.sales_orders

    UNION ALL

    SELECT "InvoiceDate"::date
    FROM staging.sales_invoices

    UNION ALL

    SELECT "OrderDate"::date
    FROM staging.purchasing_purchaseorders

    UNION ALL

    SELECT "LastReceiptDate"::date
    FROM staging.purchasing_purchaseorderlines
    WHERE "LastReceiptDate" IS NOT NULL
),

date_bounds AS (
    SELECT
        MIN(date_value) AS min_date,
        MAX(date_value) AS max_date
    FROM date_values
)

SELECT
    TO_CHAR(d::date, 'YYYYMMDD')::integer AS date_id,
    d::date AS date,
    EXTRACT(YEAR FROM d)::integer AS year,
    EXTRACT(QUARTER FROM d)::integer AS quarter,
    EXTRACT(MONTH FROM d)::integer AS month_number,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    TO_CHAR(d, 'YYYY-MM') AS year_month,
    EXTRACT(WEEK FROM d)::integer AS week_number,
    EXTRACT(ISODOW FROM d)::integer AS day_of_week,
    TRIM(TO_CHAR(d, 'Day')) AS day_name
FROM date_bounds
CROSS JOIN LATERAL generate_series(
    min_date,
    max_date,
    INTERVAL '1 day'
) AS d;


SELECT 'dim_product' AS table_name, COUNT(*) AS rows
FROM analytics.dim_product

UNION ALL

SELECT 'dim_supplier', COUNT(*)
FROM analytics.dim_supplier

UNION ALL

SELECT 'dim_customer', COUNT(*)
FROM analytics.dim_customer

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

ORDER BY table_name;



-- =========================================================
-- 1. FACT SALES
-- =========================================================

DROP TABLE IF EXISTS analytics.fact_sales;

CREATE TABLE analytics.fact_sales AS
SELECT
    il."InvoiceLineID" AS sales_id,
    il."InvoiceID" AS invoice_id,
    i."OrderID" AS order_id,
    i."CustomerID" AS customer_id,
    il."StockItemID" AS product_id,
    i."DeliveryMethodID" AS delivery_method_id,

    i."InvoiceDate"::date AS invoice_date,
    TO_CHAR(i."InvoiceDate"::date, 'YYYYMMDD')::integer AS invoice_date_id,

    il."Quantity" AS quantity,
    il."UnitPrice" AS unit_price,
    il."TaxRate" AS tax_rate,
    il."TaxAmount" AS tax_amount,
    il."LineProfit" AS line_profit,
    il."ExtendedPrice" AS extended_price

FROM staging.sales_invoicelines il

JOIN staging.sales_invoices i
    ON il."InvoiceID" = i."InvoiceID";


-- =========================================================
-- 2. FACT FULFILLMENT
-- =========================================================

DROP TABLE IF EXISTS analytics.fact_fulfillment;

CREATE TABLE analytics.fact_fulfillment AS
SELECT
    ol."OrderLineID" AS fulfillment_id,
    o."OrderID" AS order_id,
    o."CustomerID" AS customer_id,
    ol."StockItemID" AS product_id,

    o."OrderDate"::date AS order_date,
    TO_CHAR(o."OrderDate"::date, 'YYYYMMDD')::integer AS order_date_id,

    o."ExpectedDeliveryDate"::date AS expected_delivery_date,
    o."PickingCompletedWhen"::timestamp AS picking_completed_when,

    i."ConfirmedDeliveryTime"::timestamp AS confirmed_delivery_time,
    i."DeliveryMethodID" AS delivery_method_id,

    ol."Quantity" AS ordered_quantity,
    ol."PickedQuantity" AS picked_quantity,

    o."IsUndersupplyBackordered" AS is_backordered,

    CASE
        WHEN i."ConfirmedDeliveryTime" IS NULL THEN NULL
        WHEN i."ConfirmedDeliveryTime"::date <= o."ExpectedDeliveryDate"::date
            THEN TRUE
        ELSE FALSE
    END AS is_on_time_delivery,

    CASE
        WHEN i."ConfirmedDeliveryTime" IS NULL THEN NULL
        ELSE i."ConfirmedDeliveryTime"::date
             - o."ExpectedDeliveryDate"::date
    END AS delivery_delay_days

FROM staging.sales_orderlines ol

JOIN staging.sales_orders o
    ON ol."OrderID" = o."OrderID"

LEFT JOIN staging.sales_invoices i
    ON o."OrderID" = i."OrderID";


-- =========================================================
-- 3. FACT INVENTORY
-- =========================================================

DROP TABLE IF EXISTS analytics.fact_inventory;

CREATE TABLE analytics.fact_inventory AS
SELECT
    h."StockItemID" AS product_id,

    h."QuantityOnHand" AS quantity_on_hand,
    h."LastStocktakeQuantity" AS last_stocktake_quantity,
    h."LastCostPrice" AS last_cost_price,
    h."ReorderLevel" AS reorder_level,
    h."TargetStockLevel" AS target_stock_level,

    CASE
        WHEN h."QuantityOnHand" < h."ReorderLevel"
            THEN TRUE
        ELSE FALSE
    END AS below_reorder_level,

    h."QuantityOnHand" - h."TargetStockLevel"
        AS stock_vs_target

FROM staging.warehouse_stockitemholdings h;


-- =========================================================
-- 4. FACT PURCHASES
-- =========================================================

DROP TABLE IF EXISTS analytics.fact_purchases;

CREATE TABLE analytics.fact_purchases AS
SELECT
    pol."PurchaseOrderLineID" AS purchase_id,
    po."PurchaseOrderID" AS purchase_order_id,
    po."SupplierID" AS supplier_id,
    pol."StockItemID" AS product_id,

    po."OrderDate"::date AS order_date,
    TO_CHAR(po."OrderDate"::date, 'YYYYMMDD')::integer AS order_date_id,

    po."ExpectedDeliveryDate"::date AS expected_delivery_date,
    pol."LastReceiptDate"::date AS last_receipt_date,

    pol."OrderedOuters" AS ordered_outers,
    pol."ReceivedOuters" AS received_outers,
    pol."ExpectedUnitPricePerOuter" AS expected_unit_price,

    pol."OrderedOuters"
        * pol."ExpectedUnitPricePerOuter"
        AS expected_purchase_value,

    CASE
        WHEN pol."OrderedOuters" = 0 THEN NULL
        ELSE
            pol."ReceivedOuters"::numeric
            / pol."OrderedOuters"
    END AS fill_rate,

    CASE
        WHEN pol."LastReceiptDate" IS NULL THEN NULL
        WHEN pol."LastReceiptDate"::date <= po."ExpectedDeliveryDate"::date
            THEN TRUE
        ELSE FALSE
    END AS is_on_time_receipt,

    CASE
        WHEN pol."LastReceiptDate" IS NULL THEN NULL
        ELSE
            pol."LastReceiptDate"::date
            - po."ExpectedDeliveryDate"::date
    END AS receipt_delay_days

FROM staging.purchasing_purchaseorderlines pol

JOIN staging.purchasing_purchaseorders po
    ON pol."PurchaseOrderID" = po."PurchaseOrderID";


SELECT 'fact_sales' AS table_name, COUNT(*) AS rows
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


SELECT
    (SELECT COUNT(*) - COUNT(DISTINCT product_id)
     FROM analytics.dim_product) AS duplicate_products,

    (SELECT COUNT(*) - COUNT(DISTINCT supplier_id)
     FROM analytics.dim_supplier) AS duplicate_suppliers,

    (SELECT COUNT(*) - COUNT(DISTINCT customer_id)
     FROM analytics.dim_customer) AS duplicate_customers,

    (SELECT COUNT(*) - COUNT(DISTINCT sales_id)
     FROM analytics.fact_sales) AS duplicate_sales,

    (SELECT COUNT(*) - COUNT(DISTINCT fulfillment_id)
     FROM analytics.fact_fulfillment) AS duplicate_fulfillment,

    (SELECT COUNT(*) - COUNT(DISTINCT purchase_id)
     FROM analytics.fact_purchases) AS duplicate_purchases;


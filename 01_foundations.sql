
-- Task 3(a): WHERE - SKUs in Pooja & Decor
SELECT *
FROM skus
WHERE category = 'Pooja & Decor';


-- Task 3(b): DISTINCT - List of categories
SELECT DISTINCT category
FROM skus;


-- Task 3(c): ORDER BY + LIMIT - 3 highest-priced SKUs
SELECT sku_id, sku_name, unit_price_inr
FROM skus
ORDER BY unit_price_inr DESC
LIMIT 3;


-- Task 3(d): IN - SKUs in selected categories
SELECT *
FROM skus
WHERE category IN ('Sweets & Mithai', 'Pooja & Decor');


-- Task 3(e): BETWEEN - SKUs priced from 100 to 300 INR
SELECT *
FROM skus
WHERE unit_price_inr BETWEEN 100 AND 300;


-- Task 3(f): LIKE - SKU names containing Box
SELECT *
FROM skus
WHERE sku_name LIKE '%Box%';


-- Task 3(g): IS NULL - SKUs without confirmed lead time
SELECT *
FROM skus
WHERE lead_time_days IS NULL;


-- Task 3(h): ROUND - Calculate 18% tax
SELECT
    sku_name,
    unit_price_inr,
    ROUND(unit_price_inr * 0.18, 2) AS tax_amount
FROM skus;

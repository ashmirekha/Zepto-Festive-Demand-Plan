
-- Remove existing index to ensure a fair comparison
DROP INDEX IF EXISTS idx_ws_sku;

-- Query plan before creating index
EXPLAIN QUERY PLAN
SELECT *
FROM weekly_sales
WHERE sku_id = 13;

-- Create index
CREATE INDEX idx_ws_sku
ON weekly_sales(sku_id);

-- Query plan after creating index
EXPLAIN QUERY PLAN
SELECT *
FROM weekly_sales
WHERE sku_id = 13;

-- Explanation:
-- Before index: SQLite scans the weekly_sales table.
-- After index: SQLite searches using idx_ws_sku.
-- The index improves lookup efficiency by avoiding a full table scan.

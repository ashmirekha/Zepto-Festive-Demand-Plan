
-- Hold-back check: Compare baseline with known actual sales

WITH baseline AS (
    SELECT
        sku_id,
        AVG(units_sold) AS baseline_units
    FROM weekly_sales
    WHERE week_no BETWEEN 73 AND 84
      AND stockout_days = 0
    GROUP BY sku_id
),

actual AS (
    SELECT
        sku_id,
        AVG(units_sold) AS actual_units
    FROM weekly_sales
    WHERE week_no BETWEEN 85 AND 88
    GROUP BY sku_id
),

sku_gap AS (
    SELECT
        s.sku_id,
        s.category,
        b.baseline_units,
        a.actual_units,
        (a.actual_units - b.baseline_units) * 100.0
        / NULLIF(b.baseline_units, 0) AS gap_pct
    FROM skus s
    JOIN baseline b
        ON s.sku_id = b.sku_id
    JOIN actual a
        ON s.sku_id = a.sku_id
)

SELECT
    category,
    COUNT(*) AS sku_count,
    ROUND(AVG(gap_pct), 2) AS avg_gap_pct
FROM sku_gap
GROUP BY category
ORDER BY category;

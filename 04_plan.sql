

-- TASK 1: Calculate SKU-level demand plan

-- Baseline = Average sales in clean weeks 77 to 88
WITH baseline AS (
    SELECT
        sku_id,
        AVG(units_sold) AS baseline_units,
        COUNT(*) AS clean_weeks
    FROM weekly_sales
    WHERE week_no BETWEEN 77 AND 88
      AND stockout_days = 0
    GROUP BY sku_id
),

-- Average clean festive sales
festive_avg AS (
    SELECT
        sku_id,
        AVG(units_sold) AS festive_units
    FROM weekly_sales
    WHERE week_no BETWEEN 37 AND 40
      AND stockout_days = 0
    GROUP BY sku_id
),

-- Average clean pre-festive sales
prefestive_avg AS (
    SELECT
        sku_id,
        AVG(units_sold) AS prefestive_units
    FROM weekly_sales
    WHERE week_no BETWEEN 25 AND 36
      AND stockout_days = 0
    GROUP BY sku_id
),

-- SKU-level festive uplift
sku_uplift AS (
    SELECT
        f.sku_id,
        f.festive_units / NULLIF(p.prefestive_units, 0) AS sku_uplift
    FROM festive_avg f
    JOIN prefestive_avg p
        ON f.sku_id = p.sku_id
),

-- Average SKU uplift for each category
category_uplift AS (

-- Clean-week uplift excludes stockout weeks.
-- All-weeks uplift includes stockout weeks.
-- This comparison shows how stockouts affect estimated festive demand.

    SELECT
        s.category,
        AVG(u.sku_uplift) AS category_uplift
    FROM sku_uplift u
    JOIN skus s
        ON u.sku_id = s.sku_id
    GROUP BY s.category
)

-- Final SKU plan: exactly 8 required columns
SELECT
    s.sku_id,
    s.sku_name,
    s.category,
    b.clean_weeks,
    ROUND(b.baseline_units, 2) AS baseline_units,
    ROUND(c.category_uplift, 4) AS category_uplift,
    ROUND(b.baseline_units * c.category_uplift, 0)
        AS planned_weekly_units,
    co.committed_weekly_units
FROM skus s
JOIN baseline b
    ON s.sku_id = b.sku_id
JOIN category_uplift c
    ON s.category = c.category
JOIN committed_orders co
    ON s.sku_id = co.sku_id
ORDER BY s.sku_id;


-- TASK 2: Compare clean-week uplift with all-weeks uplift

WITH clean_sku_uplift AS (
    SELECT
        f.sku_id,
        AVG(f.units_sold) * 1.0 /
        NULLIF((
            SELECT AVG(p.units_sold)
            FROM weekly_sales p
            WHERE p.sku_id = f.sku_id
              AND p.week_no BETWEEN 25 AND 36
              AND p.stockout_days = 0
        ), 0) AS sku_uplift
    FROM weekly_sales f
    WHERE f.week_no BETWEEN 37 AND 40
      AND f.stockout_days = 0
    GROUP BY f.sku_id
),

clean_category AS (
    SELECT
        s.category,
        AVG(u.sku_uplift) AS clean_uplift
    FROM clean_sku_uplift u
    JOIN skus s ON u.sku_id = s.sku_id
    GROUP BY s.category
),

all_sku_uplift AS (
    SELECT
        f.sku_id,
        AVG(f.units_sold) * 1.0 /
        NULLIF((
            SELECT AVG(p.units_sold)
            FROM weekly_sales p
            WHERE p.sku_id = f.sku_id
              AND p.week_no BETWEEN 25 AND 36
        ), 0) AS sku_uplift
    FROM weekly_sales f
    WHERE f.week_no BETWEEN 37 AND 40
    GROUP BY f.sku_id
),

all_category AS (
    SELECT
        s.category,
        AVG(u.sku_uplift) AS all_weeks_uplift
    FROM all_sku_uplift u
    JOIN skus s ON u.sku_id = s.sku_id
    GROUP BY s.category
)

SELECT
    c.category,
    ROUND(c.clean_uplift, 4) AS clean_uplift,
    ROUND(a.all_weeks_uplift, 4) AS all_weeks_uplift
FROM clean_category c
JOIN all_category a
    ON c.category = a.category
ORDER BY c.category;

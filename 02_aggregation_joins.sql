
-- Task 4(a): INNER JOIN, GROUP BY and HAVING
SELECT
    s.category,
    SUM(w.units_sold) AS total_units,
    SUM(w.stockout_days) AS total_stockout_days
FROM weekly_sales w
INNER JOIN skus s
    ON w.sku_id = s.sku_id
GROUP BY s.category
HAVING SUM(w.units_sold) > 300000
ORDER BY total_units DESC;


-- Task 4(b): LEFT JOIN - Weekly records per SKU
SELECT
    s.sku_id,
    s.sku_name,
    COUNT(w.week_no) AS sku_weeks
FROM skus s
LEFT JOIN weekly_sales w
    ON s.sku_id = w.sku_id
GROUP BY s.sku_id, s.sku_name
ORDER BY sku_weeks ASC;


-- Task 4(c): Stock-out incidence by season
WITH season_totals AS (
    SELECT
        c.season,
        COUNT(*) AS total_sku_weeks
    FROM weekly_sales w
    INNER JOIN calendar_weeks c
        ON w.week_no = c.week_no
    GROUP BY c.season
),
season_stockouts AS (
    SELECT
        c.season,
        COUNT(*) AS affected_sku_weeks
    FROM weekly_sales w
    INNER JOIN calendar_weeks c
        ON w.week_no = c.week_no
    WHERE w.stockout_days > 0
    GROUP BY c.season
)
SELECT
    t.season,
    t.total_sku_weeks,
    COALESCE(s.affected_sku_weeks, 0) AS affected_sku_weeks,
    ROUND(
        COALESCE(s.affected_sku_weeks, 0) * 100.0
        / t.total_sku_weeks, 2
    ) AS incidence_pct
FROM season_totals t
LEFT JOIN season_stockouts s
    ON t.season = s.season
ORDER BY t.season;

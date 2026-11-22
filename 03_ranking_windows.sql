
-- 1. Top 2 SKUs in each category based on weeks 37 to 40 sales

WITH sku_sales AS (
    SELECT
        s.sku_id,
        s.sku_name,
        s.category,
        SUM(w.units_sold) AS total_units
    FROM skus s
    JOIN weekly_sales w
        ON s.sku_id = w.sku_id
    WHERE w.week_no BETWEEN 37 AND 40
    GROUP BY s.sku_id, s.sku_name, s.category
),
ranked_skus AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_units DESC, sku_id
        ) AS category_rank
    FROM sku_sales
)
SELECT
    category,
    sku_id,
    sku_name,
    total_units,
    category_rank
FROM ranked_skus
WHERE category_rank <= 2
ORDER BY category, category_rank;


-- 2. Running total of Sweets sales for weeks 33 to 40

SELECT
    w.week_no,
    SUM(w.units_sold) AS weekly_units,
    SUM(SUM(w.units_sold)) OVER (
        ORDER BY w.week_no
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM weekly_sales w
JOIN skus s
    ON w.sku_id = s.sku_id
WHERE s.category = 'Sweets & Mithai'
  AND w.week_no BETWEEN 33 AND 40
GROUP BY w.week_no
ORDER BY w.week_no;

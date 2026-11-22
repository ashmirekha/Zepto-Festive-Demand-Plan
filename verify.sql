-- Zepto Database Verification

SELECT 'SKUs' AS table_name,
       COUNT(*) AS actual,
       21 AS expected
FROM skus;

SELECT 'Calendar Weeks',
       COUNT(*),
       92
FROM calendar_weeks;

SELECT 'Weekly Sales',
       COUNT(*),
       1760
FROM weekly_sales;

SELECT 'Committed Orders',
       COUNT(*),
       20
FROM committed_orders;

-- Season-wise weekly sales verification

SELECT
    c.season,
    COUNT(*) AS total_sku_weeks,
    COUNT(DISTINCT w.week_no) AS total_weeks
FROM weekly_sales w
JOIN calendar_weeks c
    ON w.week_no = c.week_no
GROUP BY c.season
ORDER BY c.season;
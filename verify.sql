-- Zepto Database Verification
--
-- Expected Results:
-- skus              = 21
-- calendar_weeks    = 92
-- weekly_sales      = 1760
-- committed_orders  = 20
--
-- Season-wise Verification:
-- Festive           = 8
-- Regular           = 84

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

-- Season-wise calendar verification

SELECT
    season,
    COUNT(*) AS total_weeks
FROM calendar_weeks
GROUP BY season
ORDER BY season;

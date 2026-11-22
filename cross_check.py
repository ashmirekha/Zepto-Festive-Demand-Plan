
import sqlite3


def fetch_rows(sql):
    conn = sqlite3.connect("zepto_festive.db")
    conn.row_factory = sqlite3.Row
    rows = [dict(r) for r in conn.execute(sql).fetchall()]
    conn.close()
    return rows


def clean_values(rows, sku_id, start_week, end_week):
    return [
        r["units_sold"]
        for r in rows
        if r["sku_id"] == sku_id
        and start_week <= r["week_no"] <= end_week
        and r["stockout_days"] == 0
    ]


def mean_of(values):
    return sum(values) / len(values) if values else 0


# ---- write your code below this line ----

rows = fetch_rows("""
    SELECT
        ws.sku_id,
        ws.week_no,
        ws.units_sold,
        ws.stockout_days,
        s.sku_name,
        s.category,
        c.season
    FROM weekly_sales ws
    JOIN skus s ON ws.sku_id = s.sku_id
    JOIN calendar_weeks c ON ws.week_no = c.week_no
""")

lines = []
failures = 0

# SKU baseline cross-check

sql_baselines = fetch_rows("""
    SELECT
        sku_id,
        COUNT(*) AS clean_weeks,
        AVG(units_sold) AS baseline_units
    FROM weekly_sales
    WHERE week_no BETWEEN 77 AND 88
      AND stockout_days = 0
    GROUP BY sku_id
    ORDER BY sku_id
""")

for row in sql_baselines:
    sku_id = row["sku_id"]

    values = clean_values(rows, sku_id, 77, 88)
    python_mean = mean_of(values)

    sql_mean = row["baseline_units"]
    sql_weeks = row["clean_weeks"]

    passed = (
        len(values) == sql_weeks
        and abs(python_mean - sql_mean) < 0.0001
    )

    if not passed:
        failures += 1

    lines.append(
        f"SKU {sku_id}: Python={python_mean:.2f}, "
        f"SQL={sql_mean:.2f}, Clean Weeks={len(values)}, "
        f"{'OK' if passed else 'FAIL'}"
    )


# Season stockout cross-check

sql_seasons = fetch_rows("""
    SELECT
        c.season,
        COUNT(*) AS total,
        SUM(CASE WHEN ws.stockout_days > 0 THEN 1 ELSE 0 END)
            AS stockouts
    FROM weekly_sales ws
    JOIN calendar_weeks c ON ws.week_no = c.week_no
    GROUP BY c.season
    ORDER BY c.season
""")

python_seasons = {}

for row in rows:
    season = row["season"]

    if season not in python_seasons:
        python_seasons[season] = {
            "total": 0,
            "stockouts": 0
        }

    python_seasons[season]["total"] += 1

    if row["stockout_days"] > 0:
        python_seasons[season]["stockouts"] += 1

for sql_row in sql_seasons:
    season = sql_row["season"]
    stats = python_seasons[season]

    python_percentage = (
        stats["stockouts"] * 100.0 / stats["total"]
    )

    sql_percentage = (
        sql_row["stockouts"] * 100.0 / sql_row["total"]
    )

    passed = abs(python_percentage - sql_percentage) < 0.0001

    if not passed:
        failures += 1

    lines.append(
        f"{season}: {python_percentage:.2f}% "
        f"{'OK' if passed else 'FAIL'}"
    )


# Category uplift cross-check

sql_category_uplifts = fetch_rows("""
    WITH sku_uplift AS (
        SELECT
            s.sku_id,
            s.category,
            AVG(
                CASE WHEN ws.week_no BETWEEN 37 AND 40
                THEN ws.units_sold END
            ) * 1.0
            /
            AVG(
                CASE WHEN ws.week_no BETWEEN 25 AND 36
                THEN ws.units_sold END
            ) AS uplift
        FROM weekly_sales ws
        JOIN skus s ON ws.sku_id = s.sku_id
        WHERE ws.stockout_days = 0
          AND ws.week_no BETWEEN 25 AND 40
        GROUP BY s.sku_id, s.category
        HAVING COUNT(
            CASE WHEN ws.week_no BETWEEN 25 AND 36 THEN 1 END
        ) > 0
        AND COUNT(
            CASE WHEN ws.week_no BETWEEN 37 AND 40 THEN 1 END
        ) > 0
    )
    SELECT
        category,
        AVG(uplift) AS category_uplift
    FROM sku_uplift
    GROUP BY category
    ORDER BY category
""")

category_values = {}

sku_ids = sorted(set(row["sku_id"] for row in rows))

for sku_id in sku_ids:
    pre_values = clean_values(rows, sku_id, 25, 36)
    festive_values = clean_values(rows, sku_id, 37, 40)

    if pre_values and festive_values:
        pre_mean = mean_of(pre_values)
        festive_mean = mean_of(festive_values)
        uplift = festive_mean / pre_mean

        category = next(
            row["category"]
            for row in rows
            if row["sku_id"] == sku_id
        )

        category_values.setdefault(category, []).append(uplift)

for row in sql_category_uplifts:
    category = row["category"]

    python_uplift = mean_of(category_values[category])
    sql_uplift = row["category_uplift"]

    passed = abs(python_uplift - sql_uplift) < 0.0001

    if not passed:
        failures += 1

    lines.append(
        f"{category}: Python={python_uplift:.4f}, "
        f"SQL={sql_uplift:.4f}, "
        f"{'OK' if passed else 'FAIL'}"
    )


if failures == 0:
    lines.append("ALL CHECKS PASSED")
else:
    lines.append("CHECKS FAILED")

print("\n".join(lines))


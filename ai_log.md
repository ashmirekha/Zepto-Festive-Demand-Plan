# AI Usage Log

## Prompt Used

### Task
Help build a Zepto Festive Demand Plan using SQL, Python, and Excel.

### Context
The project analyses weekly SKU sales, festive demand, committed orders, stockouts, and inventory coverage across four product categories.

### Constraints
- Follow the project brief and required file structure.
- Use SQLite for SQL analysis and Python for independent validation.
- Use clean sales weeks for the baseline.
- Verify all outputs against the project acceptance criteria.
- Do not invent missing data or assume unknown causes.

### Format
Provide step-by-step guidance, executable SQL and Python, validation checks, and a decision memo with actionable recommendations.

## First-Draft Issues and Prompt Changes

1. **Issue:** An early SQL ranking did not produce the expected Focus List SKU IDs.
   **Prompt change:** Recheck the ranking logic against the exact project definition and validate the selected SKUs against the acceptance criteria.

2. **Issue:** An early Python validation script had an indentation problem, causing the category uplift check to be placed inside the season loop.
   **Prompt change:** Review the complete script structure, check loop indentation, and run all validation checks independently.

## Validation Note

- **Title:** Zepto Festive Demand Plan
- **Sources:** Project-provided dataset, SQLite database tables, and project acceptance criteria.
- **AI usage:** Used for SQL/Python guidance, debugging, Excel formulas, and memo drafting.
- **Manual checks:** Verified database counts, SQL outputs, Python cross-checks, Excel formulas, coverage results, and category gaps.
- **Changes made:** Corrected SQL ranking and Python indentation; checked formulas and outputs against expected results.
- **Analysis limits:** Historical sales may not represent future demand; stockout-related lost demand and the causes of category differences are unknown.
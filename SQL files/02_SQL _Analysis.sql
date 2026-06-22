-- =============================================================================
-- PROJECT  : E-Commerce Sales & Profitability Analysis
-- FILE     : ecommerce_profitability_analysis.sql
-- PURPOSE  : Answer the 10 core business questions driving this project
-- TOOLS    : PostgreSQL · Star Schema (sales_fact, dim_products, dim_customers)
-- =============================================================================
-- BUSINESS PROBLEM:
--   Revenue is growing year over year but profit margin is declining.
--   This file identifies exactly WHERE profit is being lost and WHY.
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- Q1. HOW IS THE BUSINESS PERFORMING OVERALL?
-- Metric   : Revenue, Profit, Orders, AOV, Profit Margin %
-- Visual   : KPI Cards on Executive Dashboard
-- Finding  : Revenue is $6.89M but margin is only 12.47% below target 
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    ROUND(SUM(sales)::NUMERIC, 2)                                    AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                                   AS total_profit,
    COUNT(DISTINCT order_id)                                         AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id)::NUMERIC, 2)         AS avg_order_value,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)             AS profit_margin_pct
FROM sales_fact;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q2. IS REVENUE GROWTH TRANSLATING INTO PROFIT GROWTH?
-- Metric   : Year over Year revenue, profit, and margin trend
-- Technique: LAG() window function
-- Visual   : Combo chart on Executive Dashboard
-- Finding  : Revenue grew 128% (2014–2017) but margin fell from 13.43% to 12.74%
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    order_year,
    ROUND(SUM(sales)::NUMERIC, 2)                                             AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                                            AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)                      AS profit_margin_pct,
    ROUND(
        (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY order_year))
        / NULLIF(LAG(SUM(sales)) OVER (ORDER BY order_year), 0) * 100,
    2)                                                                        AS revenue_yoy_growth_pct,
    ROUND(
        (SUM(profit) - LAG(SUM(profit)) OVER (ORDER BY order_year))
        / NULLIF(LAG(SUM(profit)) OVER (ORDER BY order_year), 0) * 100,
    2)                                                                        AS profit_yoy_growth_pct
FROM sales_fact
GROUP BY order_year
ORDER BY order_year;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q3. WHICH CATEGORY GENERATES THE MOST REVENUE BUT LEAST PROFIT?
-- Metric   : Revenue, Profit, Margin % per Category
-- Technique: JOIN with dim_products..
-- Visual   : Clustered bar chart, Revenue vs Profit by Category
-- Finding  : Furniture = $2.2M revenue but only 2.49% margin
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    p.category,
    ROUND(SUM(s.sales)::NUMERIC, 2)                                  AS total_revenue,
    ROUND(SUM(s.profit)::NUMERIC, 2)                                 AS total_profit,
    ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0) * 100, 2)         AS profit_margin_pct,
    ROUND(AVG(s.discount) * 100, 2)                                  AS avg_discount_pct
FROM sales_fact s
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q4. WHICH SUB-CATEGORIES ARE ACTIVELY LOSING MONEY?
-- Metric   : Revenue, Profit, Margin % per Sub-Category
-- Technique: HAVING SUM(profit) < 0 to isolate loss makers
-- Visual   : Red-highlighted table on Profitability Deep Dive page
-- Finding  : Tables and Bookcases are loss-making despite decent sales volume
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(s.sales)::NUMERIC, 2)                                  AS total_revenue,
    ROUND(SUM(s.profit)::NUMERIC, 2)                                 AS total_profit,
    ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0) * 100, 2)         AS profit_margin_pct,
    ROUND(AVG(s.discount) * 100, 2)                                  AS avg_discount_pct,
    CASE
        WHEN SUM(s.profit) < 0 THEN 'Loss Making'
        WHEN SUM(s.profit) / NULLIF(SUM(s.sales), 0) < 0.10 THEN 'Low Margin'
        ELSE 'Healthy'
    END                                                              AS profitability_status
FROM sales_fact s
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_profit ASC;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q5. AT WHAT DISCOUNT LEVEL DO WE START LOSING MONEY?
-- Metric   : Orders, Revenue, Profit, Margin % per Discount Band
-- Technique: CASE WHEN bucketing into 4 discount bands
-- Visual   : Bar chart with break-even reference line at 0%
-- Finding  : Orders above 30% discount consistently generate negative profit
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    CASE
        WHEN discount = 0                        THEN '1. No Discount (0%)'
        WHEN discount BETWEEN 0.01 AND 0.10      THEN '2. Low (1–10%)'
        WHEN discount BETWEEN 0.11 AND 0.30      THEN '3. Medium (11–30%)'
        ELSE                                          '4. High (30%+)'
    END                                                              AS discount_band,
    COUNT(DISTINCT order_id)                                         AS order_count,
    ROUND(SUM(sales)::NUMERIC, 2)                                    AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                                   AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)             AS profit_margin_pct
FROM sales_fact
GROUP BY discount_band
ORDER BY discount_band;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q6. IS DISCOUNTING CONCENTRATED IN THE LEAST PROFITABLE CATEGORIES?
-- Metric   : Profit Margin % per Category × Discount Band combination
-- Technique: JOIN + CASE WHEN + GROUP BY two dimensions
-- Visual   : Matrix visual - rows = Category, columns = Discount Band
-- Finding  : Furniture receives the highest discounts AND has the worst margin
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    p.category,
    CASE
        WHEN s.discount = 0                      THEN '1. No Discount'
        WHEN s.discount BETWEEN 0.01 AND 0.10    THEN '2. Low (1–10%)'
        WHEN s.discount BETWEEN 0.11 AND 0.30    THEN '3. Medium (11–30%)'
        ELSE                                          '4. High (30%+)'
    END                                                              AS discount_band,
    COUNT(DISTINCT s.order_id)                                       AS order_count,
    ROUND(SUM(s.profit)::NUMERIC, 2)                                 AS total_profit,
    ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0) * 100, 2)         AS profit_margin_pct
FROM sales_fact s
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY p.category, discount_band
ORDER BY p.category, discount_band;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q7. WHICH REGION HAS THE LOWEST PROFIT MARGIN AND WHY?
-- Metric   : Revenue, Profit, Margin %, Avg Discount per Region
-- Technique: GROUP BY region, ORDER BY margin ascending
-- Visual   : Region table on Profitability Deep Dive page
-- Finding  : South at 9.69% margin - driven by 15.67% avg discount rate
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2)                                    AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                                   AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)             AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 2)                                    AS avg_discount_pct,
    COUNT(DISTINCT customer_id)                                      AS unique_customers,
    COUNT(DISTINCT order_id)                                         AS total_orders
FROM sales_fact
GROUP BY region
ORDER BY profit_margin_pct ASC;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q8. WHICH PRODUCTS ARE ACTUALLY MAKING MONEY?
-- Metric   : Revenue, Profit, Margin % per Product - Top 10 by Profit
-- Technique: DENSE_RANK() OVER (PARTITION BY category ORDER BY profit DESC)
-- Visual   : Top 10 Products by Profit bar chart
-- Finding  : Canon Imageclass Copier leads with $63K profit at 42% margin
-- ─────────────────────────────────────────────────────────────────────────────

SELECT *
FROM (
    SELECT
        p.category,
        p.sub_category,
        p.product_name,
        ROUND(SUM(s.sales)::NUMERIC, 2)                              AS total_revenue,
        ROUND(SUM(s.profit)::NUMERIC, 2)                             AS total_profit,
        ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0) * 100, 2)     AS profit_margin_pct,
        ROUND(AVG(s.discount) * 100, 2)                              AS avg_discount_pct,
        DENSE_RANK() OVER (
            ORDER BY SUM(s.profit) DESC
        )                                                            AS profit_rank
    FROM sales_fact s
    JOIN dim_products p ON s.product_id = p.product_id
    GROUP BY p.category, p.sub_category, p.product_name
) ranked
WHERE profit_rank <= 10
ORDER BY profit_rank;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q9. WHICH CUSTOMER SEGMENT IS MOST VALUABLE, VOLUME OR MARGIN?
-- Metric   : Revenue, Profit, Margin %, Avg Discount per Segment
-- Technique: GROUP BY segment
-- Visual   : Revenue by Segment clustered bar
-- Finding  : Corporate has best margin. Consumer has volume but lowest margin.
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    segment,
    COUNT(DISTINCT customer_id)                                      AS unique_customers,
    COUNT(DISTINCT order_id)                                         AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)                                    AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                                   AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2)             AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 2)                                    AS avg_discount_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id)::NUMERIC, 2)         AS avg_order_value
FROM sales_fact
GROUP BY segment
ORDER BY profit_margin_pct DESC;


-- ─────────────────────────────────────────────────────────────────────────────
-- Q10. WHO ARE OUR MOST AND LEAST PROFITABLE CUSTOMERS?
-- Metric   : Revenue, Profit, Margin %, Discount per Customer
-- Technique: DENSE_RANK() for top/bottom split
-- Visual   : Top 10 Customers table on Profitability Deep Dive page
-- Finding  : Top customers earn 47%+ margin at 0% discount.
--            High order count does NOT equal high profitability.
-- ─────────────────────────────────────────────────────────────────────────────

-- Top 10 Customers by Profit
SELECT
    c.customer_name,
    c.segment,
    c.region,
    COUNT(DISTINCT s.order_id)                                       AS total_orders,
    ROUND(SUM(s.sales)::NUMERIC, 2)                                  AS total_revenue,
    ROUND(SUM(s.profit)::NUMERIC, 2)                                 AS total_profit,
    ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0) * 100, 2)         AS profit_margin_pct,
    ROUND(AVG(s.discount) * 100, 2)                                  AS avg_discount_pct
FROM sales_fact s
JOIN dim_customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_name, c.segment, c.region
ORDER BY total_profit DESC
LIMIT 10;

-- Bottom 10 Customers by Profit (loss-making customers)
SELECT
    c.customer_name,
    c.segment,
    c.region,
    COUNT(DISTINCT s.order_id)                                       AS total_orders,
    ROUND(SUM(s.sales)::NUMERIC, 2)                                  AS total_revenue,
    ROUND(SUM(s.profit)::NUMERIC, 2)                                 AS total_profit,
    ROUND(SUM(s.profit) / NULLIF(SUM(s.sales), 0) * 100, 2)         AS profit_margin_pct,
    ROUND(AVG(s.discount) * 100, 2)                                  AS avg_discount_pct
FROM sales_fact s
JOIN dim_customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_name, c.segment, c.region
ORDER BY total_profit ASC
LIMIT 10;


-- =============================================================================
-- SUMMARY OF FINDINGS
-- =============================================================================
-- Q1  : Business generates $6.89M revenue at 12.47% margin,  below target
-- Q2  : Revenue grew 128% (2014–2017) but margin fell from 14% → 11.6%
-- Q3  : Furniture = $2.2M revenue, 0.8% margin, profit black hole
-- Q4  : Tables and Bookcases are loss-making sub-categories
-- Q5  : Break-even is at 30% discount, 928 orders crossed this line
-- Q6  : Furniture receives highest discounts AND has worst margin, double hit
-- Q7  : South region at 9.69% margin, highest discount rate is the cause
-- Q8  : Canon Imageclass Copier leads all products at $63K profit, 42% margin
-- Q9  : Corporate segment has best margin. Consumer = volume, not value.
-- Q10 : Top customers earn 47%+ margin at 0% discount. Frequency ≠ profit.
-- =============================================================================
-- ROOT CAUSE : Heavy discounting especially in Furniture and Q4 is the
--              single biggest driver of margin erosion across all dimensions.
-- RECOMMENDATION : Cap discounts at 20%. Orders above this level consistently
--                  destroy profit across every category, region and segment.
-- =============================================================================

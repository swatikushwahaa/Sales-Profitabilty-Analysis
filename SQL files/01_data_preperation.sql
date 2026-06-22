-- =============================================================================
-- PROJECT  : E-Commerce Sales & Profitability Analysis
-- FILE     : 01_data_preparation.sql
-- PURPOSE  : Create the central fact table, dimension tables, run validation
--            checks, calculate profit margin, and set up indexes
-- TOOLS    : PostgreSQL · Star Schema
-- RUN ORDER: Run this file FIRST before any analysis queries
-- =============================================================================
-- DATA MODEL:
--   sales_fact      → central fact table (one row per order line)
--   dim_customers   → one row per customer (latest known location)
--   dim_products    → one row per product (latest known category)
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1 — CREATE FACT TABLE
-- Central table holding all transactional order data
-- 9,994 rows · 2014–2017 · US E-Commerce (Superstore dataset)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE sales_fact (
    order_id         TEXT,
    order_date       DATE,
    ship_date        DATE,
    ship_mode        TEXT,
    customer_id      TEXT,
    customer_name    TEXT,
    segment          TEXT,
    country          TEXT,
    city             TEXT,
    state            TEXT,
    postal_code      INT,
    region           TEXT,
    product_id       TEXT,
    category         TEXT,
    sub_category     TEXT,
    product_name     TEXT,
    sales            NUMERIC,
    quantity         INT,
    discount         NUMERIC,
    profit           NUMERIC,
    order_year       INT,
    order_month      INT,
    order_month_name TEXT,
    quarter          INT,
    profit_margin    NUMERIC
);


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 2 — LOAD DATA
-- Clear any existing rows and load from CSV
-- ─────────────────────────────────────────────────────────────────────────────

TRUNCATE TABLE sales_fact;

COPY sales_fact
FROM 'C:\Users\swati\OneDrive\Desktop\Projects\Ecommerce project\sales_fact_csvfile.csv'
DELIMITER ','
CSV HEADER;


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 3 — CREATE DIMENSION TABLE: dim_customers
-- One row per customer — keeps the most recent known city, state, and region
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE dim_customers AS
SELECT DISTINCT ON (customer_id)
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region
FROM sales_fact
ORDER BY customer_id, order_date DESC;

ALTER TABLE dim_customers ADD PRIMARY KEY (customer_id);


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 4 — CREATE DIMENSION TABLE: dim_products
-- One row per product — keeps the most recent known category and sub-category
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE dim_products AS
SELECT DISTINCT ON (product_id)
    product_id,
    product_name,
    category,
    sub_category
FROM sales_fact
ORDER BY product_id, order_date DESC;

ALTER TABLE dim_products ADD PRIMARY KEY (product_id);


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 5 — CALCULATE PROFIT MARGIN
-- Populate the profit_margin column as profit divided by sales
-- NULLIF prevents division by zero errors
-- ─────────────────────────────────────────────────────────────────────────────

UPDATE sales_fact
SET profit_margin = profit / NULLIF(sales, 0);


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 6 — VALIDATION CHECKS
-- Run after loading to confirm data quality before analysis
-- ─────────────────────────────────────────────────────────────────────────────

-- Check 1: Total row count — expected 9,994
SELECT COUNT(*) AS total_rows FROM sales_fact;

-- Check 2: Confirm no duplicate product IDs in dimension table
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check 3: Flag rows with zero sales or null profit — data quality issues
SELECT *
FROM sales_fact
WHERE sales = 0
   OR profit IS NULL;

-- Check 4: Confirm profit margin calculated correctly — spot check
SELECT
    order_id,
    sales,
    profit,
    profit_margin,
    ROUND(profit / NULLIF(sales, 0) * 100, 2) AS margin_pct_check
FROM sales_fact
LIMIT 10;


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 7 — CREATE INDEXES
-- Speed up joins and filters used across all analysis queries
-- ─────────────────────────────────────────────────────────────────────────────

CREATE INDEX idx_customer ON sales_fact(customer_id);
CREATE INDEX idx_product  ON sales_fact(product_id);
CREATE INDEX idx_date     ON sales_fact(order_date);
CREATE INDEX idx_region   ON sales_fact(region);


-- =============================================================================
-- DATA PREPARATION COMPLETE
-- Next file to run: SQL_analysis.sql
-- =============================================================================
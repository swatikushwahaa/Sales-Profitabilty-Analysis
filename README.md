# E-Commerce Sales & Profitability Analysis

### The business was growing revenue every year - but quietly losing profit margin. This project finds exactly where, why, and what to do about it.

## Business Problem

Between 2014 and 2017, the business grew revenue by 128%.

At first, this looks like strong business growth. But when I looked deeper, I found that profit margin was falling every year from 14.2% in 2014 to 11.6% in 2017.

This means the company was making more sales, but not turning those sales into healthy profit.

So the main questions were:

Is revenue growth actually helping profit growth?
Which products or categories are hurting profitability?
Are discounts reducing profit too much?
Which regions and customer segments are performing well, and which are not?
Which customers are truly valuable to the business?

This project answers these questions using SQL and Power BI.


## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Data cleaning, star schema design, business analysis queries |
| Power BI | Two-page interactive dashboard |
| DAX | KPI measures, YoY growth, time intelligence |

**Dataset:** Superstore (9,994 orders · 4 years · US e-commerce)


## What I Built

### Two SQL Files

**`01_data_preparation.sql`**
Sets up the data model from scratch - fact table, two dimension tables, validation checks, profit margin calculation, and indexes for query performance.

**`ecommerce_profitability_analysis.sql`**
10 business questions, each answered by one focused SQL query. Every query has a comment explaining what it measures, which SQL technique it uses, and what insight it surfaces.


### Two Dashboard Pages

**Page 1 - Is the business growing profitably?**

The executive view. Opens with 5 KPI cards showing revenue, profit, margin, orders, and average order value, each with a year-over-year % change so the trend is visible immediately.

Three charts below answer the growth story:
- A combo chart showing revenue climbing every year while the profit margin line quietly drops, the core tension of this entire project
- A discount break-even chart showing exactly where orders start losing money (above 30% discount)
- A monthly trend chart showing Q4 peaks in sales but collapses in margin every November and December

**Page 2 - Where exactly is profit being lost?**

The deep dive. Five charts that pinpoint the problem by category, sub-category, segment, region, and customer.


## The 10 Business Questions This Project Answers

| # | Question | Key Finding |
|---|---|---|
| Q1 | How is the business performing overall? | $6.89M revenue · 12.47% margin · below 15% target |
| Q2 | Is revenue growth translating into profit growth? | Revenue +128% but margin fell from 14.2% → 11.6% |
| Q3 | Which category generates the most revenue but least profit? | Furniture $2.2M revenue, only $18K profit (0.8% margin) |
| Q4 | Which sub-categories are actively losing money? | Tables -$53K · Bookcases -$10K · Supplies -$3.6K |
| Q5 | At what discount level do we start losing money? | Above 30% discount every order at this level is a guaranteed loss |
| Q6 | Is discounting concentrated in the worst categories? | Furniture gets the highest discounts and has the worst margin a double problem |
| Q7 | Which region has the lowest margin, and why? | South at 9.7% driven by the highest average discount rate of 15.7% |
| Q8 | Which products are actually making money? | Canon Imageclass Copier $63K profit at 42% margin |
| Q9 | Which customer segment is most valuable? | Corporate earns 16% margin · Consumer has volume but only 11.5% margin |
| Q10 | Who are our best and worst customers? | Top customers earn 47% margin at 0% discount · High orders ≠ high profit |

---

## Key Findings

Finding 1 - Revenue growth did not lead to better profitability
Revenue grew every year. But so did the average discount rate. Margin fell every year as a direct result. The business looks healthy on the top line and is quietly bleeding on the bottom line.

Finding 2 - Furniture is the biggest profit problem
Furniture generates $2.2M in revenue - identical to Technology and Office Supplies. But it earns only $18K in profit while Technology earns $475K on similar revenue. Three Furniture sub-categories (Tables, Bookcases, Supplies) actively lose money.

Finding 3 - Higher discounts were hurting profit
Below 30% discount - profitable. Above 30% - guaranteed loss. This is true across every category and every region. 928 orders in the dataset crossed this threshold.

Finding 4 - High order frequency does not equal high profit
Some customers place many orders but generate negative profit - because they consistently receive high discounts. The top two customers earn 47% margin at zero discount. Loyalty and discount dependency are two very different things

##Recommendations

1. Tighten discount control across the business : Revenue growth should not come at the cost of falling margin. The company should review discounting more closely, track discount % against margin %, and reduce broad discounting that drives sales but weakens profitability.

2. Focus on fixing Furniture profitability: Furniture should be treated as a priority category for margin improvement. Loss-making sub-categories such as Tables, Bookcases, and Supplies need pricing, discount, and product mix review before further sales growth is pushed.

3. Introduce a discount guardrail below 30% : Since orders above 30% discount were consistently loss-making, the business should set a discount ceiling below this level and require review for any exceptions. This would reduce avoidable losses and improve pricing discipline.

4. Evaluate customers based on profit, not just order count : Customer performance should be measured using profit contribution and discount dependency, not only order frequency. This would help the business identify which customers are truly valuable and where discounts are reducing profitability.

## SQL Techniques Used

- Star schema design - `sales_fact` joined to `dim_products` and `dim_customers`
- Window functions - `LAG()` for YoY growth, `SUM() OVER()` for running totals
- `DENSE_RANK() OVER (PARTITION BY)` for top products per category
- `CASE WHEN` bucketing for discount bands
- `HAVING` clause to isolate loss-making sub-categories
- `NULLIF()` to handle division by zero in margin calculations
- Indexing on join keys for query performance


## DAX Measures Built

- `Revenue YoY %` - year over year growth using `SAMEPERIODLASTYEAR`
- `Profit YoY %` - same pattern for profit
- `Profit Margin %` - `DIVIDE(SUM(profit), SUM(sales))`
- `Margin vs Target` - gap between actual margin and 15% target
- `Revenue YoY Label` - formatted ▲/▼ arrow label for KPI cards
- `YTD Revenue` and `YTD Profit` - using `TOTALYTD`
- `Peak Month Labels` - conditional labels showing only peak months on the chart

## Project Structure

```
ecommerce-sales-profitability/
├── sql/
│   ├── 01_data_preparation.sql
│   └── ecommerce_profitability_analysis.sql
├── screenshots/
│   ├── page1_executive_overview.png
│   └── page2_profitability_deepdive.png
└── README.md
```

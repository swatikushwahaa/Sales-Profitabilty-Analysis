# E-Commerce Sales & Profitability Analysis

### The business was growing revenue every year - but quietly losing profit margin. This project finds exactly where, why, and what to do about it.

## Business Problem

Between 2014 and 2017, the business grew revenue by 128%.

At first, this looks like strong business growth. But when I looked deeper, I found that profit margin was falling every year from 14.2% in 2014 to 11.6% in 2017.

This means the company was making more sales, but not turning those sales into healthy profit.

So the main questions were:
1. Is revenue growth actually helping profit growth?
2. Which products or categories are hurting profitability?
3. Are discounts reducing profit too much?
4. Which regions and customer segments are performing well, and which are not?
5. Which customers are truly valuable to the business?

This project answers these questions using SQL and Power BI.

**Dataset:** E-commerce Sales Dataset (9,994 orders · 4 years · US)

## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Data cleaning, star schema design, business analysis queries |
| Power BI | Two-page interactive dashboard |
| DAX | KPI measures, YoY growth, time intelligence |


## Analysis

### SQL Files

**`01_data_preparation.sql`**
Sets up the data model from scratch - fact table, two dimension tables, validation checks, profit margin calculation.

**`ecommerce_profitability_analysis.sql`**
10 business questions, each answered by one focused SQL query.

### Dashboard Pages

<img width="980" height="557" alt="Executive Profitability Overview" src="https://github.com/user-attachments/assets/9450ce0d-e151-4052-be94-ba7414885d65" />

Executive Profitability Overview : Is the business growing profitably?

Opens with 5 KPI cards showing revenue, profit, margin, orders, and average order value, each with a Month-over-Month % change so the trend is visible immediately.
Three charts below answer the growth story:
- A combo chart showing revenue climbing every year while the profit margin line quietly drops, the core tension of this entire project
- A discount break-even chart showing exactly where orders start losing money (above 30% discount)
- A monthly trend chart showing Q4 peaks in sales but collapses in margin every November and December

<img width="971" height="551" alt="Profitability Deepdive" src="https://github.com/user-attachments/assets/eb6d2272-275a-4666-ac27-fbc35ddf1b52" />

Profitability Deepdive : Where exactly is profit being lost?

The Profitability deep dive, charts that pinpoint the problem by category, sub-category, segment, region, and customer, discount.


### The 10 Business Questions This Project Answers

| ### | Question | Key Finding |
| Q1 | How is the business performing overall? |
| Q2 | Is revenue growth translating into profit growth? |
| Q3 | Which category generates the most revenue but least profit? |
| Q4 | Which sub-categories are actively losing money? |
| Q5 | At what discount level do we start losing money? |
| Q6 | Is discounting concentrated in the worst categories? |
| Q7 | Which region has the lowest margin, and why? |
| Q8 | Which products are actually making money? |
| Q9 | Which customer segment is most valuable? |
| Q10 | Who are our best and worst customers? |

**SUMMARY OF FINDINGS**
Q1  : Business generates $6.89M revenue at 12.47% margin,  below target
Q2  : Revenue grew 128% (2014–2017) but margin fell from 14% → 11.6%
Q3  : Furniture = $2.2M revenue, 0.8% margin, profit black hole
Q4  : Tables and Bookcases are loss-making sub-categories
Q5  : Break-even is at 30% discount, 928 orders crossed this line
Q6  : Furniture receives highest discounts AND has worst margin, double hit
Q7  : South region at 9.69% margin, highest discount rate is the cause
Q8  : Canon Imageclass Copier leads all products at $63K profit, 42% margin
Q9  : Corporate segment has best margin. Consumer = volume, not value.
Q10 : Top customers earn 47%+ margin at 0% discount. Frequency ≠ profit.

**ROOT CAUSE : Heavy discounting especially in Furniture and Q4 is the single biggest driver of margin decrease across all dimensions.**

**RECOMMENDATION : Cap discounts at 20%. Orders above this level consistent destroy profit across every category, region and segment.**

## KEY INSIGHTS

1. Revenue growth did not lead to better profitability : Revenue grew every year. But so did the average discount rate. Margin fell every year as a direct result. The business looks healthy on the top line and is quietly bleeding on the bottom line.

2. Furniture is the biggest profit problem : Furniture generates $2.2M in revenue - identical to Technology and Office Supplies. But it earns only $18K in profit while Technology earns $475K on similar revenue. Three Furniture sub-categories (Tables, Bookcases, Supplies) actively lose money.

3. Higher discounts were hurting profit : Below 30% discount - profitable. Above 30% - guaranteed loss. This is true across every category and every region. 928 orders in the dataset crossed this threshold.

4. High order frequency does not equal high profit : Some customers place many orders but generate negative profit - because they consistently receive high discounts. The top two customers earn 47% margin at zero discount. Loyalty and discount dependency are two very different things

## Key Recommendations

1. Tighten discount control across the business : Revenue growth should not come at the cost of falling margin. The company should review discounting more closely, track discount % against margin %, and reduce broad discounting that drives sales but weakens profitability.

2. Focus on fixing Furniture profitability: Furniture should be treated as a priority category for margin improvement. Loss-making sub-categories such as Tables, Bookcases, and Supplies need pricing, discount, and product mix review before further sales growth is pushed.

3. Introduce a discount guardrail below 30% : Since orders above 30% discount were consistently loss-making, the business should set a discount ceiling below this level and require review for any exceptions. This would reduce avoidable losses and improve pricing discipline.

4. Evaluate customers based on profit, not just order count : Customer performance should be measured using profit contribution and discount dependency, not only order frequency. This would help the business identify which customers are truly valuable and where discounts are reducing profitability.


## Repository structure

```
sales-profitability-analysis/
├── Power BI/
│   ├── Executive Profitability Overview.png
│   └── Profitability Deepdive.png
|   └── Screenshots.txt
├── SQL files
│   ├── 01_data_preparation.sql
│   └── 02_ecommerce_profitability_analysis.sql
└── README.md
```

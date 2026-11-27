# Olist E-Commerce: Data Exploration Notes

**Platform:** Databricks SQL (queries run on Delta tables; table names may need your catalog and schema prefix, e.g. `main.olist.orders`)
**Dataset:** Olist Brazilian E-Commerce Public Dataset (Kaggle)
**Purpose:** Data quality checks and decisions made before the business analysis.

## Table inventory

| Table | Rows | Distinct key |
|---|---|---|
| orders | 99,441 | 99,441 order_id |
| customers | 99,441 | 99,441 customer_id / 96,096 customer_unique_id |
| order_items | 112,650 | 98,666 order_id |
| order_payments | 103,886 | 99,440 order_id |
| products | 32,951 | n/a |
| order_reviews | (fill in) | (fill in) |
| sellers | (fill in) | (fill in) |
| geolocation | (fill in) | (fill in) |
| category_translation | (fill in) | (fill in) |

Query to fill the blanks: `SELECT COUNT(*) FROM <table>;` for each remaining table.

## Check 1: Order status

| order_status | orders |
|---|---|
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

- 99,441 orders in total; 96,478 (97.0%) are delivered.
- The other 2,963 orders are in non-final or failed states (shipped, canceled, unavailable and so on).
- **Decision:** revenue and delivery analysis use `order_status = 'delivered'` only, so canceled or unfulfilled orders don't inflate sales.

## Check 2: Date range

- Data runs from 2016-09-04 to 2018-10-17.
- Sparse months: 2016-09 (4 orders), 2016-10 (324), 2016-12 (1), 2018-09 (16), 2018-10 (4). 2016-11 has no orders at all. Steady volume starts in 2017-01 (800 orders).
- The 2016 months look like a ramp-up period. The 2018-09 and 2018-10 figures are far too low to be a real sales drop, so they are most likely an extraction cutoff or incomplete data in the dataset.
- **Decision:** monthly trend and growth analysis covers 2017-01 to 2018-08 only (rule: exclude months with fewer than 500 orders). Overall totals use all delivered orders.

## Check 3: Missing delivery dates

- 2,965 of 99,441 orders have no delivery date.
- Of these, 2,957 belong to non-delivered statuses: shipped (1,107), canceled (619), unavailable (609), invoiced (314), processing (301), created (5) and approved (2). This is expected, since these orders never reached the customer.
- The remaining 8 orders are marked `delivered` but have no delivery date (0.0083% of the 96,478 delivered orders).
- **Decision:** delivery-time and late-delivery analysis excludes orders with a null delivery date. Revenue analysis is unaffected.

## Check 4: Duplicate order IDs

- `orders` has 99,441 rows and 99,441 distinct order_ids, so `order_id` is unique.
- **Decision:** no deduplication needed on the orders table.

## Check 5: Customer identifiers

- `customers` has 99,441 distinct `customer_id`s but only 96,096 distinct `customer_unique_id`s.
- `customer_id` is generated per order, so the same person gets a new `customer_id` each time they buy. `customer_unique_id` identifies the actual person.
- The gap (99,441 - 96,096 = 3,345) is the number of extra orders placed by returning customers beyond their first, which suggests repeat buying is rare. The exact repeat purchase rate is calculated in Q8.
- **Decision:** all repeat-purchase and retention analysis uses `customer_unique_id`. Using `customer_id` would show a 0% repeat rate, because every order has its own id.

## Check 6: Join inflation

All figures in this check cover orders of every status, because the purpose is to show the join problem, not to report revenue.

- `order_items` has 112,650 rows for 98,666 distinct orders (multiple items per order).
- `order_payments` has 103,886 rows for 99,440 distinct orders (multiple payment rows per order, e.g. split payments or vouchers).

| Method | Item revenue (BRL) |
|---|---|
| Baseline: SUM(price) on order_items alone | 13,591,643.70 |
| Naive join of order_items to order_payments | 14,209,115.34 |
| Safe join (payments aggregated per order in a CTE first) | 13,591,508.73 |

- The naive join overstates the baseline by 617,471.64 BRL (about 4.5%), because each item row is repeated once per payment row.
- Compared like for like, the naive join overstates the safe join by 617,606.61 BRL (also about 4.5%). The like-for-like comparison is the fair one, since both sides exclude orders with no payment record.
- The safe join is 134.97 BRL below the baseline. This is consistent with orders that have items but no payment record (only 1 of 99,441 orders has no payment row). To confirm, run the anti-join below and record the result here: ____
- **Decision:** product revenue is calculated from `order_items.price` (`payment_value` includes freight). Whenever payment data is needed, it is aggregated to order level in a CTE before joining.

```sql
-- Confirm which items have no payment record
SELECT oi.order_id, SUM(oi.price) AS item_value
FROM order_items oi
LEFT JOIN order_payments op ON oi.order_id = op.order_id
WHERE op.order_id IS NULL
GROUP BY oi.order_id;
```

## Check 7: Category translations

- 610 of 32,951 products have no category name at all.
- 13 more products belong to 2 categories that are missing from the translation table (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`).
- **Decision:** category analysis uses `COALESCE(english_name, product_category_name, 'unknown')`, so no product is dropped from revenue totals. The 2 untranslated categories get a manual English label (`pc_gamer` stays `pc_gamer`; `portateis_cozinha_e_preparadores_de_alimentos` becomes `portable_kitchen_food_preparers`) so charts don't mix Portuguese and English names.

## Summary of decisions

| # | Decision |
|---|---|
| 1 | Revenue and delivery analysis use delivered orders only |
| 2 | Monthly trends cover 2017-01 to 2018-08 (months with 500+ orders) |
| 3 | Delivery analysis excludes the 8 delivered orders with no delivery date |
| 4 | No deduplication needed on orders |
| 5 | Repeat-purchase analysis uses `customer_unique_id` |
| 6 | Revenue is `SUM(order_items.price)`; payments are aggregated per order before any join |
| 7 | Categories use COALESCE with a manual mapping for untranslated names |

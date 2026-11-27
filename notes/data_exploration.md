# Data exploration notes

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
- Decision: revenue and delivery analysis use `order_status = 'delivered'` only, so cancelled or unfulfilled orders don't inflate sales.

## Check 2: Date range
- Data runs from 2016-09-04 to 2018-10-17.
- Sparse months: 2016-09 (4 orders), 2016-10 (324), 2016-12 (1), 2018-09 (16), 2018-10 (4).
  2016-11 has no orders at all. Steady volume starts in 2017-01 (800 orders).
- 2018-09 and 2018-10 are low because the dataset ends there, not a real sales drop.
- Decision: monthly trend and growth analysis covers 2017-01 to 2018-08 only
  (rule: exclude months with fewer than 500 orders). Overall totals use all delivered orders.

## Check 3: Missing delivery dates
- 2965 of 99441 orders have no delivery date.
- These belong mostly to statuses: shipped (1,107), canceled (619), unavailable (609), invoiced (314), processing (301), created (5), and approved (2) (2,959 non-delivered orders total).
- 8 orders are marked 'delivered' but have no delivery date (0.0083% of 96,478 delivered orders).
- Decision: delivery-time and late-delivery analysis excludes orders with a null
  delivery date; revenue analysis is unaffected.

## Check 4: Duplicate order IDs
- orders has 99,441 rows and 99,441 distinct order_ids, so order_id is unique.
- No deduplication needed on the orders table.

## Check 5: Customer identifiers
- customers has 99,441 distinct customer_ids but only 96,096 distinct customer_unique_ids.
- customer_id is generated per order, so the same person gets a new customer_id
  each time they buy. customer_unique_id identifies the actual person.
- The gap (99,441 - 96,096 = 3,345) is the number of orders placed by returning customers
  beyond their first, which suggests repeat buying is rare (roughly 3% of customers).
- Decision: all repeat-purchase and retention analysis uses customer_unique_id.
  Using customer_id would show a 0% repeat rate, because every order has its own id.

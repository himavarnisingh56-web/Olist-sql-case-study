# Data exploration notes

## Order status
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
- Data runs from [first date] to [last date].
- Months that look partial: [which ones, and how you could tell,
  e.g. "only N orders vs. thousands in neighboring months"].
- Decision: monthly trend analysis excludes [those months].

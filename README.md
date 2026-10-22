# books-shop-dbt

Sample [dbt](https://www.getdbt.com/) project that transforms analytics from the **Leaf & Lantern Books** storefront ([`books-shop`](../books-shop)) into a dimensional model. Uses PostgreSQL with self-contained CSV seeds—no live RudderStack warehouse required.

## What this project demonstrates

This is a teaching-oriented dbt project covering the major project features:

| dbt topic | Where to look |
|-----------|---------------|
| Project config | [`dbt_project.yml`](dbt_project.yml) — vars, materializations, tags, hooks, groups |
| Profiles | [`profiles.yml.example`](profiles.yml.example) |
| Packages | [`packages.yml`](packages.yml) — `dbt_utils` |
| Seeds | [`seeds/`](seeds/) — books catalog + synthetic RudderStack events |
| Sources | [`models/staging/*/_*__sources.yml`](models/staging/) |
| Staging models | [`models/staging/`](models/staging/) |
| Intermediate models | [`models/intermediate/`](models/intermediate/) — includes ephemeral model |
| Mart models | [`models/marts/`](models/marts/) |
| Incremental model | [`stg_rudderstack__events.sql`](models/staging/rudderstack/stg_rudderstack__events.sql) |
| Snapshots (SCD Type 2) | [`snapshots/snap_books.sql`](snapshots/snap_books.sql) |
| Schema tests | [`_core__models.yml`](models/marts/core/_core__models.yml), [`_seeds.yml`](seeds/_seeds.yml) |
| Singular tests | [`tests/assert_orders_have_completed_event.sql`](tests/assert_orders_have_completed_event.sql) |
| Custom generic test | [`macros/tests/positive_value.sql`](macros/tests/positive_value.sql) |
| Unit tests | [`_stg_rudderstack__models.yml`](models/staging/rudderstack/_stg_rudderstack__models.yml) |
| Macros | [`macros/cents_to_dollars.sql`](macros/cents_to_dollars.sql) |
| Documentation | Column descriptions in `_core__models.yml` |
| Metrics & semantic models | [`_core__models.yml`](models/marts/core/_core__models.yml) |
| Exposures | [`_core__models.yml`](models/marts/core/_core__models.yml) |
| Analyses | [`analyses/funnel_drop_off.sql`](analyses/funnel_drop_off.sql) |
| Selectors | [`selectors.yml`](selectors.yml) |
| Hooks | `on-run-start` in [`dbt_project.yml`](dbt_project.yml) |
| Groups | [`models/groups.yml`](models/groups.yml) |

## Data model

```text
seeds (raw)
  ├── books.csv              → stg_books_shop__books → dim_products
  ├── books_price_history.csv → stg_books_shop__book_versions
  └── raw_track_events.csv   → stg_rudderstack__events
                                    ↓
                              int_events__unified
                                    ↓
                              int_sessions → int_funnel_steps
                                    ↓
                    fct_orders / fct_product_events / rpt_daily_funnel
```

### Analytics events (from books-shop)

| Event | Description |
|-------|-------------|
| `page_view` | Page navigation |
| `product_viewed` | Product detail view |
| `cart_item_added` | Add to cart |
| `checkout_started` | Checkout form submit |
| `order_completed` | Successful order |

Synthetic seed data includes three user journeys: full funnel, browse-only, and cart abandon.

## Prerequisites

- Docker (for local Postgres)
- Python 3.10+
- pip

## Quick start

### 1. Start Postgres

```bash
docker compose up -d
```

### 2. Install dbt

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Configure profile

```bash
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

Or run from the project directory with a local profile:

```bash
cp profiles.yml.example profiles.yml
export DBT_PROFILES_DIR=.
```

### 4. Run the project

```bash
dbt deps
dbt seed
dbt run
dbt snapshot
dbt test
dbt docs generate
dbt docs serve
```

### Selectors

```bash
dbt run --selector daily    # marts only
dbt run --selector full     # all models
dbt run --selector funnel   # funnel-tagged models
dbt run --select tag:core   # core mart models
```

## Snapshot demo

To see SCD Type 2 in action:

1. Run `dbt snapshot` (captures initial book prices)
2. Edit a `price` value in [`seeds/books.csv`](seeds/books.csv)
3. Run `dbt seed && dbt snapshot` again
4. Query `snapshots.snap_books` for `dbt_valid_from` / `dbt_valid_to` columns

## Project structure

```text
books-shop-dbt/
├── analyses/           # Ad-hoc SQL (not materialized)
├── macros/             # Reusable Jinja/SQL
├── models/
│   ├── staging/        # Cleaned source data
│   ├── intermediate/   # Business logic joins
│   └── marts/          # Analytics-ready tables
├── seeds/              # CSV raw data
├── snapshots/          # SCD Type 2 history
├── tests/              # Singular data tests
├── dbt_project.yml
├── packages.yml
├── selectors.yml
└── docker-compose.yml
```

## Related project

The upstream storefront lives in [`../books-shop`](../books-shop). Event contracts are defined in `books-shop/analytics/schemas/*.json`.


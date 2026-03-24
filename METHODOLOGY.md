# Analytical Methodology
### Novadata Analytics | Hope Forward NGO Case Study

This document explains the analytical approach, tool choices, and key decisions made during this engagement.

---

## 1. Problem Framing

Before any data work began, the core business questions were defined:

1. How much funding has the organisation received, and is it growing?
2. Which donor types and regions drive the most revenue?
3. Which programme funds are over- or under-subscribed?
4. Which donors are at risk of lapsing?
5. What is the year-over-year donor retention rate?
6. Are there seasonal patterns that should inform campaign timing?

Every query, chart, and analytical output in this project maps directly to one of these questions. This is a deliberate choice — analytics without a business question is just noise.

---

## 2. Data Consolidation Approach

### Schema Design
Two tables were created following third normal form (3NF) principles:

- **`donors`** — one record per unique donor, storing identity and demographic attributes
- **`donations`** — one record per transaction, linked to donors via foreign key

A deliberate denormalisation was applied: `donor_type` and `region` were retained in the `donations` table to simplify analytical queries. This is an accepted trade-off in analytical (OLAP) databases where read performance and query simplicity take priority over write efficiency.

### Why PostgreSQL
PostgreSQL was chosen as the database engine for the following reasons:
- Free and open-source — no licensing cost for the client
- Robust support for date functions, window functions, and CTEs
- Production-ready for organisations that grow beyond small datasets
- Compatible with all major BI tools (Power BI, Tableau, Metabase)

SQLite is noted as an alternative for smaller organisations without server infrastructure.

---

## 3. SQL Analytical Framework

Twelve queries were developed across six analytical categories:

| Category | Questions Answered |
|---|---|
| Portfolio overview | Annual trends, active donor counts, average gift |
| Donor segmentation | Funding by type, top 10 donors by lifetime value |
| Retention analysis | Year-over-year retention rate, cohort survival |
| Lapse detection | Donors inactive for 24+ months |
| Fund allocation | Programme funding trends, donor-type-to-fund mapping |
| Seasonality | Monthly and quarterly giving patterns |

### Window Functions
Retention rate calculations use SQL window functions (`LAG`) to compare current-year donor counts against prior-year counts without requiring application-level logic.

### CTE Pattern
Complex multi-step queries (retention, lapse detection) use Common Table Expressions (CTEs) for readability and maintainability. Each CTE represents one logical step, making the query auditable and easy to modify.

---

## 4. R Analysis Approach

### Package Selection

| Package | Reason |
|---|---|
| `dplyr` | Intuitive data manipulation — readable by non-programmers |
| `ggplot2` | Publication-quality charts with full customisation |
| `lubridate` | Reliable date parsing and extraction |
| `scales` | Currency and percentage formatting on chart axes |
| `tidyr` | Reshaping data for cohort analysis |

### Reproducibility
The entire analysis is contained in a single `analysis.R` script. Running `source("r/analysis.R")` reproduces all five charts and the summary metrics from scratch. This is intentional — reproducibility is a core principle of evidence-based reporting.

### Simulated Dataset
The dataset was generated using R's `set.seed(42)` for reproducibility. Donation amounts were drawn from realistic distributions by donor type:
- Individual: ZAR 500 – 15,000
- Corporate: ZAR 10,000 – 120,000
- Foundation: ZAR 20,000 – 200,000
- Government: ZAR 50,000 – 500,000

---

## 5. The Five Charts and Their Purpose

### Chart 1 — Annual Funding Trend
**Question answered:** Is funding growing, and where are the gaps?  
**Chart type:** Line chart with area fill  
**Key decision:** Labels show ZAR millions rounded to one decimal — precise enough for strategic decisions, not so precise as to mislead on simulated data.

### Chart 2 — Funding by Donor Type
**Question answered:** Which donor segments are most valuable?  
**Chart type:** Horizontal bar chart with percentage labels  
**Key decision:** Horizontal orientation chosen because donor type labels are text — vertical bars would require rotated axis labels which reduce readability.

### Chart 3 — Fund Allocation Over Time
**Question answered:** Are programme areas funded consistently, or is there volatility?  
**Chart type:** Stacked bar chart by year  
**Key decision:** Stacked bars show both total funding growth and compositional change simultaneously — two insights in one chart.

### Chart 4 — Donor Retention by Cohort
**Question answered:** Do donors come back after their first gift?  
**Chart type:** Line chart by acquisition cohort  
**Key decision:** Cohort analysis (grouping donors by the year they first gave) reveals retention patterns invisible in aggregate statistics. A flat overall retention rate can mask improving trends in newer cohorts.

### Chart 5 — Monthly Seasonality
**Question answered:** When should campaigns be timed?  
**Chart type:** Bar chart with November–December highlighted in accent colour  
**Key decision:** Highlighting only the high-performing months in orange draws the eye immediately to the actionable insight without requiring the reader to interpret the whole chart.

---

## 6. Limitations and Caveats

- The dataset is entirely simulated. Real-world donor data will produce different distributions.
- Retention analysis requires at least 2 years of data per cohort to be meaningful — newer cohorts show 100% retention simply because insufficient time has passed.
- Seasonality patterns should be validated over at least 3 years of real data before being used to make campaign timing decisions.
- The `donor_type` check constraint in the schema assumes four categories. Organisations with different typologies should update the constraint to match their own classification system.

---

*© 2025 Novadata Analytics. Methodology documentation for portfolio and educational use.*

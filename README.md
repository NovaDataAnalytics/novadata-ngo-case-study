# Donor Data Management — NGO Case Study
### Novadata Analytics | Hope Forward NGO (Simulated)

> **Focus keyword:** Donor data management South Africa  
> **Sector:** Non-profit / NGO  
> **Tools:** PostgreSQL · R · ggplot2 · tidyverse

---

## Overview

Many South African NGOs and NPOs manage donor data across disconnected spreadsheets, with no single source of truth. This case study demonstrates how Novadata Analytics consolidates fragmented donor records into a structured analytical system — using SQL for data infrastructure and R for analysis and visualisation.

**The result:** Board reports that took 5 days now take under 2 hours. Lapsed donors are flagged automatically. Year-end campaigns are timed to data, not guesswork.

---

## The Problem

Hope Forward NGO (a simulated client) experienced:

- Donor records spread across multiple Excel files and staff members
- No ability to identify lapsed or at-risk donors
- Quarterly board reports taking 3–5 working days to compile
- Year-end fundraising campaigns planned without historical data
- No measurement of donor retention year-over-year

---

## The Solution

A three-phase data analytics engagement:

1. **Consolidate** — all donor records loaded into a unified PostgreSQL database
2. **Analyse** — SQL queries for retention, lapse detection, fund allocation, and seasonality
3. **Visualise** — R and ggplot2 charts embedded in a reproducible reporting template

---

## Repository Structure

```
novadata-ngo-case-study/
│
├── README.md                   ← You are here
├── METHODOLOGY.md              ← Analytical approach and decisions
├── DATA_DICTIONARY.md          ← Column definitions for both tables
│
├── data/
│   ├── dataset_donors.csv      ← 80 simulated donor records
│   └── dataset_donations.csv   ← 354 simulated donation transactions
│
├── sql/
│   ├── 01_schema.sql           ← CREATE TABLE statements
│   ├── 02_queries.sql          ← 12 analytical queries (6 categories)
│   └── 03_reload.sql           ← Safe TRUNCATE + COPY reload script
│
├── r/
│   └── analysis.R              ← Full R analysis + 5 ggplot2 charts
│
└── docs/
    └── novadata_ngo_case_study.docx   ← Full case study document
```

---

## Key Findings

| Finding | Insight |
|---|---|
| Annual funding | Grew 2020–2024 but with unexplained dips — now traceable |
| Top donor type | Government drives 62.7% of revenue — concentration risk |
| Retention | Less than 50% of new donors give again after year one |
| Seasonality | November–December consistently spike — campaign window identified |
| Top programme | Health receives the most funding — Education underfunded |

---

## Tech Stack

| Tool | Role |
|---|---|
| PostgreSQL | Relational database — donors + donations tables |
| R + tidyverse | Data wrangling, cohort analysis, statistical summaries |
| ggplot2 | Publication-quality charts and visualisations |
| dplyr / lubridate | Data transformation and date handling |
| Excel / CSV | Data intake — existing NGO records |

All tools are **open-source and free** — accessible to budget-constrained organisations.

---

## Simulated Dataset

The dataset is entirely fictional and created for demonstration purposes.

- **80 donors** — individuals, corporates, foundations, and government funders
- **354 donations** — spanning 2020 to 2024 across 5 programme funds
- **ZAR 33,020,410** total funding tracked
- **ZAR 93,278** average gift size

---

## How to Reproduce This Analysis

### 1. Set up the database

```sql
-- Run in order:
psql -d your_database -f sql/01_schema.sql
psql -d your_database -f sql/03_reload.sql   -- update file paths first
```

### 2. Run the analytical queries

```sql
psql -d your_database -f sql/02_queries.sql
```

### 3. Run the R analysis

```r
# Install required packages (once)
install.packages(c("ggplot2", "dplyr", "scales", "lubridate", "tidyr"))

# Run the full analysis
source("r/analysis.R")
```

Charts are saved automatically to the working directory as PNG files.

---

## About Novadata Analytics

Novadata Analytics is a South African data analytics firm helping NGOs, businesses, government entities, and researchers unlock the value of their data.

- **Website:** [www.novadataanalytics.co.za](https://www.novadataanalytics.co.za)
- **LinkedIn:** [Novadata Analytics](https://www.linkedin.com/company/novadata-analytics)
- **Email:** info@novadataanalytics.co.za

---

## Licence

This repository is shared for educational and portfolio purposes.  
The dataset is entirely simulated — Hope Forward NGO is a fictional organisation.  
© 2025 Novadata Analytics. All rights reserved.

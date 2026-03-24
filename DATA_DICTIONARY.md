# Data Dictionary
### Novadata Analytics | ThriveBridge NGO Case Study

This document defines every column in the two database tables and their corresponding CSV files.

---

## Table: `donors`
**File:** `data/dataset_donors.csv`  
**Rows:** 80  
**Description:** One record per unique donor — individual, corporate, foundation, or government funder.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `donor_id` | TEXT (PK) | Unique donor identifier | `D001` |
| `donor_name` | TEXT | Full name of the donor or organisation | `Donor 1` |
| `donor_type` | TEXT | Category of donor | `Government`, `Foundation`, `Corporate`, `Individual` |
| `region` | TEXT | Geographic region of the donor | `Gauteng`, `Western Cape`, `International` |
| `acquisition_year` | INTEGER | Year the donor made their first gift | `2021` |

**Allowed values for `donor_type`:**
- `Individual` — private persons giving in their personal capacity
- `Corporate` — businesses and companies
- `Foundation` — charitable foundations and trusts
- `Government` — government departments and agencies

---

## Table: `donations`
**File:** `data/dataset_donations.csv`  
**Rows:** 354  
**Description:** One record per donation transaction. Multiple records can exist per donor.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `donation_id` | TEXT (PK) | Unique transaction identifier | `DON0001` |
| `donor_id` | TEXT (FK) | Links to `donors.donor_id` | `D001` |
| `amount` | REAL | Donation amount in South African Rand (ZAR) | `199600.00` |
| `donation_date` | DATE | Date the donation was received | `2021-04-08` |
| `fund` | TEXT | Programme area the donation is directed to | `Health` |
| `payment_method` | TEXT | How the donation was made | `EFT` |
| `year` | INTEGER | Calendar year extracted from `donation_date` | `2021` |
| `month` | INTEGER | Month number extracted from `donation_date` | `4` |
| `quarter` | TEXT | Quarter extracted from `donation_date` | `Q2` |
| `donor_type` | TEXT | Donor type (denormalised from donors table) | `Government` |
| `region` | TEXT | Donor region (denormalised from donors table) | `Western Cape` |

**Allowed values for `fund`:**
- `Health`
- `Education`
- `Livelihoods`
- `WASH` (Water, Sanitation and Hygiene)
- `Emergency Relief`

**Allowed values for `payment_method`:**
- `EFT` — Electronic Funds Transfer
- `Credit Card`
- `Cheque`
- `Wire Transfer`

---

## Relationship

```
donors (donor_id) ──< donations (donor_id)
```

One donor can have many donations. The `donor_id` in the `donations` table is a foreign key referencing the `donors` table primary key.

---

## Notes on Denormalised Columns

The `donations` table contains `donor_type` and `region` columns that also exist in the `donors` table. These are intentionally denormalised for analytical convenience — queries that group or filter by donor type on the donations table do not require a JOIN. Both columns are populated from the donors table at load time and should remain consistent.

---

## Data Quality Rules

| Rule | Column | Constraint |
|---|---|---|
| Primary key uniqueness | `donor_id`, `donation_id` | No duplicates allowed |
| Non-null name | `donor_name` | Required |
| Positive amounts only | `amount` | Must be > 0 |
| Valid date | `donation_date` | Must be a valid DATE |
| Controlled vocabulary | `donor_type` | Must be one of 4 allowed values |
| Foreign key integrity | `donor_id` in donations | Must exist in donors table |

---

*Dataset is entirely simulated for demonstration purposes. © 2025 Novadata Analytics.*

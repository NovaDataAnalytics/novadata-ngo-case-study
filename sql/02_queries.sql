-- ============================================================
-- NOVA DATA ANALYTICS | CASE STUDY SQL QUERIES
-- Client: THRIVEBRIDGE NGO (Simulated)
-- Focus:  Donor & Funding Data Management
-- DB:     SQLite-compatible (also runs on PostgreSQL / MySQL)
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: DATABASE SCHEMA
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS donors (
    donor_id         TEXT PRIMARY KEY,
    donor_name       TEXT NOT NULL,
    donor_type       TEXT CHECK(donor_type IN ('Individual','Corporate','Foundation','Government')),
    region           TEXT,
    acquisition_year INTEGER
);

CREATE TABLE IF NOT EXISTS donations (
    donation_id     TEXT PRIMARY KEY,
    donor_id        TEXT REFERENCES donors(donor_id),
    amount          REAL NOT NULL CHECK(amount > 0),
    donation_date   DATE NOT NULL,
    fund            TEXT,
    payment_method  TEXT,
    year            INTEGER,
    month           INTEGER,
    quarter         TEXT
);


-- ────────────────────────────────────────────────────────────
-- SECTION 2: DONOR HEALTH & PORTFOLIO OVERVIEW
-- ────────────────────────────────────────────────────────────

-- Q1: Total funding received per year
SELECT
    year,
    COUNT(donation_id)            AS total_donations,
    COUNT(DISTINCT donor_id)      AS active_donors,
    ROUND(SUM(amount), 2)         AS total_funding,
    ROUND(AVG(amount), 2)         AS avg_gift_size
FROM donations
GROUP BY year
ORDER BY year;


-- Q2: Funding breakdown by donor type
SELECT
    d.donor_type,
    COUNT(DISTINCT d.donor_id)               AS donor_count,
    COUNT(dn.donation_id)                    AS donation_count,
    ROUND(SUM(dn.amount), 2)                 AS total_funding,
    ROUND(AVG(dn.amount), 2)                 AS avg_gift,
    ROUND(SUM(dn.amount) * 100.0 /
          (SELECT SUM(amount) FROM donations), 1) AS pct_of_total
FROM donors d
LEFT JOIN donations dn ON d.donor_id = dn.donor_id
GROUP BY d.donor_type
ORDER BY total_funding DESC;


-- Q3: Top 10 donors by cumulative giving
SELECT
    d.donor_id,
    d.donor_name,
    d.donor_type,
    d.region,
    COUNT(dn.donation_id)          AS gifts_made,
    ROUND(SUM(dn.amount), 2)       AS lifetime_value,
    ROUND(AVG(dn.amount), 2)       AS avg_gift,
    MIN(dn.donation_date)          AS first_gift_date,
    MAX(dn.donation_date)          AS most_recent_gift
FROM donors d
JOIN donations dn ON d.donor_id = dn.donor_id
GROUP BY d.donor_id, d.donor_name, d.donor_type, d.region
ORDER BY lifetime_value DESC
LIMIT 10;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: DONOR RETENTION & LAPSE ANALYSIS
-- ────────────────────────────────────────────────────────────

-- Q4: Classify donors as Retained, Lapsed, or New (as at end of 2024)
WITH last_gift AS (
    SELECT
        donor_id,
        MAX(year) AS last_gift_year
    FROM donations
    GROUP BY donor_id
),
first_gift AS (
    SELECT
        donor_id,
        MIN(year) AS first_gift_year
    FROM donations
    GROUP BY donor_id
)
SELECT
    d.donor_id,
    d.donor_name,
    d.donor_type,
    f.first_gift_year,
    l.last_gift_year,
    CASE
        WHEN l.last_gift_year = 2024              THEN 'Active'
        WHEN l.last_gift_year = 2023              THEN 'At Risk'
        WHEN l.last_gift_year <= 2022             THEN 'Lapsed'
    END AS donor_status
FROM donors d
JOIN first_gift f ON d.donor_id = f.donor_id
JOIN last_gift  l ON d.donor_id = l.donor_id
ORDER BY donor_status, l.last_gift_year DESC;


-- Q5: Year-over-year donor retention rate
WITH yearly_donors AS (
    SELECT DISTINCT donor_id, year FROM donations
),
retained AS (
    SELECT
        a.year                      AS current_year,
        COUNT(DISTINCT a.donor_id)  AS retained_donors
    FROM yearly_donors a
    JOIN yearly_donors b
        ON a.donor_id = b.donor_id AND b.year = a.year - 1
    GROUP BY a.year
),
total_prev AS (
    SELECT year, COUNT(DISTINCT donor_id) AS total_donors
    FROM yearly_donors
    GROUP BY year
)
SELECT
    r.current_year,
    r.retained_donors,
    t.total_donors                                  AS prior_year_donors,
    ROUND(r.retained_donors * 100.0 / t.total_donors, 1) AS retention_rate_pct
FROM retained r
JOIN total_prev t ON t.year = r.current_year - 1
ORDER BY r.current_year;


-- ────────────────────────────────────────────────────────────
-- SECTION 4: PROGRAMME FUND ALLOCATION
-- ────────────────────────────────────────────────────────────

-- Q6: Funding per programme area per year
SELECT
    fund,
    year,
    ROUND(SUM(amount), 2)    AS total_funding,
    COUNT(donation_id)       AS donation_count,
    ROUND(AVG(amount), 2)    AS avg_donation
FROM donations
GROUP BY fund, year
ORDER BY fund, year;


-- Q7: Which donor types fund which programmes?
SELECT
    d.donor_type,
    dn.fund,
    COUNT(dn.donation_id)        AS donations,
    ROUND(SUM(dn.amount), 2)     AS total_funding
FROM donations dn
JOIN donors d ON dn.donor_id = d.donor_id
GROUP BY d.donor_type, dn.fund
ORDER BY d.donor_type, total_funding DESC;


-- ────────────────────────────────────────────────────────────
-- SECTION 5: SEASONALITY & CASH FLOW PLANNING
-- ────────────────────────────────────────────────────────────

-- Q8: Monthly donation patterns (all years combined)
SELECT
    month,
    COUNT(donation_id)            AS donation_count,
    ROUND(SUM(amount), 2)         AS total_funding,
    ROUND(AVG(amount), 2)         AS avg_gift
FROM donations
GROUP BY month
ORDER BY month;


-- Q9: Quarter-on-quarter growth
WITH quarterly AS (
    SELECT
        year,
        quarter,
        ROUND(SUM(amount), 2) AS total
    FROM donations
    GROUP BY year, quarter
)
SELECT
    year,
    quarter,
    total,
    LAG(total) OVER (ORDER BY year, quarter) AS prev_quarter_total,
    ROUND(
        (total - LAG(total) OVER (ORDER BY year, quarter)) * 100.0 /
         NULLIF(LAG(total) OVER (ORDER BY year, quarter), 0), 1
    ) AS qoq_growth_pct
FROM quarterly
ORDER BY year, quarter;


-- ────────────────────────────────────────────────────────────
-- SECTION 6: DATA QUALITY FLAGS (key governance check)
-- ────────────────────────────────────────────────────────────

-- Q10: Identify donors with no activity in 24+ months (lapse risk)
SELECT
    d.donor_id,
    d.donor_name,
    d.donor_type,
    MAX(dn.donation_date)  AS last_donation_date,
    ROUND(julianday('2025-01-01') - julianday(MAX(dn.donation_date))) AS days_since_gift
FROM donors d
JOIN donations dn ON d.donor_id = dn.donor_id
GROUP BY d.donor_id, d.donor_name, d.donor_type
HAVING days_since_gift > 730
ORDER BY days_since_gift DESC;


-- Q11: Duplicate donation check (same donor, same amount, same date)
SELECT
    donor_id,
    donation_date,
    amount,
    COUNT(*) AS occurrences
FROM donations
GROUP BY donor_id, donation_date, amount
HAVING occurrences > 1;


-- Q12: Summary dashboard view (management KPI snapshot)
SELECT
    'Total Donors'                              AS metric,
    CAST(COUNT(DISTINCT donor_id) AS TEXT)      AS value
FROM donors
UNION ALL
SELECT 'Total Donations',     CAST(COUNT(*) AS TEXT)                    FROM donations
UNION ALL
SELECT 'Total Funding (ZAR)', CAST(ROUND(SUM(amount),2) AS TEXT)        FROM donations
UNION ALL
SELECT 'Avg Gift Size (ZAR)', CAST(ROUND(AVG(amount),2) AS TEXT)        FROM donations
UNION ALL
SELECT 'Active in 2024',      CAST(COUNT(DISTINCT donor_id) AS TEXT)    FROM donations WHERE year=2024;

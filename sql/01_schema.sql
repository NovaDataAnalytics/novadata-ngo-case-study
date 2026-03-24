-- ============================================================
-- 01_schema.sql
-- NOVADATA ANALYTICS | Hope Forward NGO Case Study
-- Creates the donors and donations tables
-- Compatible with PostgreSQL 13+
-- ============================================================


CREATE TABLE IF NOT EXISTS donors (
    donor_id         TEXT        PRIMARY KEY,
    donor_name       TEXT        NOT NULL,
    donor_type       TEXT        CHECK (donor_type IN (
                                    'Individual',
                                    'Corporate',
                                    'Foundation',
                                    'Government'
                                 )),
    region           TEXT,
    acquisition_year INTEGER
);


CREATE TABLE IF NOT EXISTS donations (
    donation_id     TEXT        PRIMARY KEY,
    donor_id        TEXT        REFERENCES donors(donor_id),
    amount          REAL        NOT NULL CHECK (amount > 0),
    donation_date   DATE        NOT NULL,
    fund            TEXT,
    payment_method  TEXT,
    year            INTEGER,
    month           INTEGER,
    quarter         TEXT,
    donor_type      TEXT,
    region          TEXT
);


-- Indexes for common analytical query patterns
CREATE INDEX IF NOT EXISTS idx_donations_donor_id
    ON donations(donor_id);

CREATE INDEX IF NOT EXISTS idx_donations_year
    ON donations(year);

CREATE INDEX IF NOT EXISTS idx_donations_fund
    ON donations(fund);

CREATE INDEX IF NOT EXISTS idx_donations_donor_type
    ON donations(donor_type);

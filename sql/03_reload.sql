-- ============================================================
-- NOVADATA ANALYTICS — Safe Table Reload Script
-- Use this when re-running COPY to avoid duplicate key errors
-- ============================================================


-- ── OPTION 1: TRUNCATE then COPY (full reload) ───────────────
-- Use this when you want to wipe and reload cleanly from CSV.
-- RESTART IDENTITY resets any sequences.
-- CASCADE handles the foreign key from donations → donors.

TRUNCATE TABLE donations RESTART IDENTITY CASCADE;
TRUNCATE TABLE donors    RESTART IDENTITY CASCADE;

-- Now run your COPY commands as normal:
COPY donors    FROM '/path/to/dataset_donors.csv'    DELIMITER ',' CSV HEADER;
COPY donations FROM '/path/to/dataset_donations.csv' DELIMITER ',' CSV HEADER;


-- ── OPTION 2: UPSERT with ON CONFLICT (safe incremental load) ─
-- Use this when you want to add new records but skip existing ones.
-- Requires a staging table — paste your CSV into it first,
-- then merge into the real table.

-- Step 1: create temporary staging tables
CREATE TEMP TABLE donors_stage    (LIKE donors    INCLUDING ALL);
CREATE TEMP TABLE donations_stage (LIKE donations INCLUDING ALL);

-- Step 2: load CSVs into staging
COPY donors_stage    FROM '/path/to/dataset_donors.csv'    DELIMITER ',' CSV HEADER;
COPY donations_stage FROM '/path/to/dataset_donations.csv' DELIMITER ',' CSV HEADER;

-- Step 3: merge into real tables — skip any row whose key already exists
INSERT INTO donors
    SELECT * FROM donors_stage
    ON CONFLICT (donor_id) DO NOTHING;

INSERT INTO donations
    SELECT * FROM donations_stage
    ON CONFLICT (donation_id) DO NOTHING;

-- Step 4: staging tables drop automatically when session ends


-- ── VERIFICATION: confirm counts after either option ─────────
SELECT 'donors'    AS table_name, COUNT(*) AS rows FROM donors
UNION ALL
SELECT 'donations',               COUNT(*) FROM donations;

SELECT ROUND(SUM(amount)::numeric, 2) AS total_funding FROM donations;

DROP TABLE IF EXISTS quiet_companion.raw.raw_eligible_securities;

CREATE TABLE quiet_companion.raw.raw_eligible_securities (
    effective_date TEXT NOT NULL,
    ticker TEXT NOT NULL,
    security_name TEXT,
    asset_class TEXT,
    security_category TEXT,
    product_id TEXT NOT NULL,
    eligible TEXT,
    raw_created_timestamp TIMESTAMP NOT NULL
);

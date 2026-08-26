DROP TABLE IF EXISTS quiet_companion.raw.raw_trades;

CREATE TABLE quiet_companion.raw.raw_trades (
    effective_date TEXT,
    trade_id TEXT,
    account_number TEXT,
    ssn TEXT,
    advisor_code TEXT,
    advisor_name TEXT,
    trade_date TEXT,
    settlement_date TEXT,
    asset_class TEXT,
    ticker TEXT,
    security_name TEXT,
    "action" TEXT,
    quantity TEXT,
    price TEXT,
    gross_amount TEXT,
    commission TEXT,
    net_amount TEXT,
    cash_flow_direction TEXT,
    currency TEXT,
    order_type TEXT,
    product_id TEXT,
    tax_status TEXT,
    raw_created_timestamp TIMESTAMP
);

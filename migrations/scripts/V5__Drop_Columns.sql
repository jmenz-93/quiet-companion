ALTER TABLE raw.raw_accounts
DROP COLUMN IF EXISTS equity_allocation,
DROP COLUMN IF EXISTS fixed_income_allocation,
DROP COLUMN IF EXISTS alternative_allocation;

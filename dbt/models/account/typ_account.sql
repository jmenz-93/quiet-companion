{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['account_number', 'effective_date', 'raw_created_timestamp'],
    on_schema_change='sync_all_columns'
) }}

SELECT
    CAST(raw_accounts.effective_date AS DATE) AS effective_date,
    raw_accounts.account_number,
    raw_accounts.ssn,
    CAST(raw_accounts.product_id AS INTEGER) AS product_id,
    raw_accounts.account_status,
    CAST(raw_accounts.date_opened AS DATE) AS date_opened,
    CAST(raw_accounts.date_closed AS DATE) AS date_closed,
    CAST(raw_accounts.last_review_date AS DATE) AS last_review_date,
    raw_accounts.custodian,
    raw_accounts.advisor_code,
    raw_accounts.investment_objective,
    raw_accounts.risk_profile,
    raw_accounts.time_horizon,
    raw_accounts.rebalance_frequency,
    CAST(NULLIF(TRIM(raw_accounts.annual_contribution), '') AS NUMERIC(12, 2)) AS annual_contribution,
    CAST(NULLIF(TRIM(raw_accounts.management_fee), '') AS NUMERIC(5, 4)) AS management_fee,
    raw_accounts.margin_enabled,
    raw_accounts.options_approved,
    raw_accounts.beneficiary_designated,
    raw_accounts.esg_preference,
    raw_accounts.raw_created_timestamp,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ source('quiet_companion', 'raw_accounts') }} AS raw_accounts
{% if is_incremental() %}
    WHERE raw_accounts.raw_created_timestamp >= (SELECT MAX(a.raw_created_timestamp) FROM {{ this }} AS a)
{% endif %}

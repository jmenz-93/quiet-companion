{{ config(
    materialized='table'
) }}

-- SCD2 account dimension (see scd2 macro), enriched with product attributes.
-- LEFT JOIN keeps accounts whose product_id has no match (product_* -> 'Unknown')
-- instead of dropping them.

SELECT
    scd.account_number,
    scd.ssn,
    scd.product_id,
    p.contribution_limit_2026,
    p.income_limit_2026,
    p.typical_time_horizon,
    scd.account_status,
    scd.date_opened,
    scd.date_closed,
    scd.last_review_date,
    scd.custodian,
    scd.advisor_code,
    scd.investment_objective,
    scd.risk_profile,
    scd.time_horizon,
    scd.rebalance_frequency,
    scd.annual_contribution,
    scd.management_fee,
    scd.margin_enabled,
    scd.options_approved,
    scd.beneficiary_designated,
    scd.esg_preference,
    COALESCE(p.product_name, 'Unknown') AS product_name,
    COALESCE(p.product_category, 'Unknown') AS product_category,
    COALESCE(p.tax_status, 'Unknown') AS tax_status,
    scd.effective_start_date,
    scd.effective_end_date,
    scd.is_current
FROM {{ scd2(
    ref('typ_account'),
    partition_by=['account_number'],
    tracked_columns=[
        'ssn', 'product_id', 'account_status', 'date_opened', 'date_closed',
        'last_review_date', 'custodian', 'advisor_code',
        'investment_objective', 'risk_profile', 'time_horizon',
        'rebalance_frequency', 'annual_contribution', 'management_fee',
        'margin_enabled', 'options_approved', 'beneficiary_designated',
        'esg_preference'
    ]
) }} AS scd
LEFT JOIN {{ ref('cls_products') }} AS p
    ON scd.product_id = p.product_id

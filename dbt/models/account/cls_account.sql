{{config(
    materialized='incremental',
    incremental_strategy = 'merge',
    unique_key=['account_number', 'effective_start_date'],
    on_schema_change='sync_all_columns'
)}}

WITH ranked AS (
    SELECT
        t.account_number,
        t.ssn,
        p.product_name,
        p.product_category,
        p.tax_status,
        p.contribution_limit_2026,
        p.income_limit_2026,
        p.typical_time_horizon,
        t.account_status,
        t.date_opened,
        t.date_closed,
        t.last_review_date,
        t.custodian,
        t.advisor_code,
        t.investment_objective,
        t.risk_profile,
        t.time_horizon,
        t.rebalance_frequency,
        t.annual_contribution,
        t.management_fee,
        t.margin_enabled,
        t.options_approved,
        t.beneficiary_designated,
        t.esg_preference,
        dbt_valid_from AS effective_start_date,
        dbt_valid_to AS effective_end_date,
        ROW_NUMBER() OVER (
            PARTITION BY t.account_number, t.effective_date
            ORDER BY t.raw_created_timestamp DESC
        ) AS row_num
    FROM {{ref('account_scd2')}} AS t
    LEFT JOIN {{ref("cls_products")}} AS p
        ON t.product_id = p.product_id
    WHERE
        p.product_id IS NOT NULL
        {% if is_incremental() %}
            AND t.account_number IN (
                SELECT t2.account_number
                FROM {{ ref('account_scd2') }} AS t2
                WHERE t2.effective_date >= (SELECT MAX(t3.effective_date) FROM {{ this }} AS t3)
            )
        {% endif %}
)

SELECT
    account_number,
    ssn,
    product_name,
    product_category,
    tax_status,
    contribution_limit_2026,
    income_limit_2026,
    typical_time_horizon,
    account_status,
    date_opened,
    date_closed,
    last_review_date,
    custodian,
    advisor_code,
    investment_objective,
    risk_profile,
    time_horizon,
    rebalance_frequency,
    annual_contribution,
    management_fee,
    margin_enabled,
    options_approved,
    beneficiary_designated,
    esg_preference,
    effective_start_date,
    effective_end_date,
    (dbt_valid_to IS NULL) AS is_current
FROM ranked
WHERE row_num = 1

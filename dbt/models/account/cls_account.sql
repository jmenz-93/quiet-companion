{{ config(
    materialized='table'
) }}

-- SCD2 account dimension built directly from the effective-dated history in
-- typ_account, enriched with product attributes. We dedup late-arriving
-- corrections to one row per (account_number, effective_date), derive the
-- validity interval with LEAD over all versions, then join product details.
-- Full rebuild (table) is used because appending a new version must rewrite the
-- prior row's end date.

WITH deduped AS (
    SELECT
        t.effective_date,
        t.account_number,
        t.ssn,
        t.product_id,
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
        ROW_NUMBER() OVER (
            PARTITION BY t.account_number, t.effective_date
            ORDER BY t.raw_created_timestamp DESC
        ) AS row_num
    FROM {{ ref('typ_account') }} AS t
),

versioned AS (
    SELECT
        *,
        LEAD(effective_date) OVER (
            PARTITION BY account_number ORDER BY effective_date
        ) AS effective_end_date
    FROM deduped
    WHERE row_num = 1
)

SELECT
    v.account_number,
    v.ssn,
    p.product_name,
    p.product_category,
    p.tax_status,
    p.contribution_limit_2026,
    p.income_limit_2026,
    p.typical_time_horizon,
    v.account_status,
    v.date_opened,
    v.date_closed,
    v.last_review_date,
    v.custodian,
    v.advisor_code,
    v.investment_objective,
    v.risk_profile,
    v.time_horizon,
    v.rebalance_frequency,
    v.annual_contribution,
    v.management_fee,
    v.margin_enabled,
    v.options_approved,
    v.beneficiary_designated,
    v.esg_preference,
    v.effective_date AS effective_start_date,
    v.effective_end_date,
    (v.effective_end_date IS NULL) AS is_current
FROM versioned AS v
INNER JOIN {{ ref('cls_products') }} AS p
    ON v.product_id = p.product_id

{{ config(
    materialized='table'
) }}
SELECT
    CAST(products.product_id AS int) AS product_id,
    products.product_code,
    products.product_name,
    products.product_category,
    products.tax_treatment,
    products.tax_status,
    products.contribution_limit_2026,
    products.income_limit_2026,
    products.early_withdrawal_penalty,
    products.required_minimum_distributions,
    products.eligible_investments,
    products.purpose,
    products.best_suited_for,
    products.when_to_recommend,
    products.key_benefits,
    products.key_limitations,
    products.common_age_range,
    products.typical_time_horizon,
    products.risk_suitability,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ ref('products') }} AS products

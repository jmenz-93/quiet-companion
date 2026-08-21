{{ config(
    materialized='table'
) }}

-- SCD2 eligible-securities dimension (see scd2 macro), tracked per ticker,
-- enriched with product attributes. LEFT JOIN keeps securities whose product_id
-- has no match (product_* -> 'Unknown') instead of dropping them.

SELECT
    scd.ticker,
    scd.security_name,
    scd.asset_class,
    scd.security_category,
    scd.product_id,
    scd.eligible,
    scd.effective_start_date,
    scd.effective_end_date,
    COALESCE(p.product_name, 'Unknown') AS product_name,
    COALESCE(p.product_category, 'Unknown') AS product_category,
    COALESCE(p.tax_status, 'Unknown') AS tax_status,
    scd.is_current
FROM {{ scd2(
    ref('typ_eligible_securities'),
    partition_by=['ticker'],
    tracked_columns=[
        'security_name', 'asset_class', 'security_category', 'product_id',
        'eligible'
    ]
) }} AS scd
LEFT JOIN {{ ref('cls_products') }} AS p
    ON scd.product_id = p.product_id

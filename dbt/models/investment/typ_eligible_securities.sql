{{config(
    materialized='incremental',
    incremental_strategy = 'merge',
    unique_key=['ticker', 'effective_date'],
    on_schema_change='sync_all_columns'
)}}


SELECT
    CAST(raw_eligible_securities.effective_date AS DATE) AS effective_date,
    raw_eligible_securities.ticker,
    raw_eligible_securities.security_name,
    raw_eligible_securities.asset_class,
    raw_eligible_securities.security_category,
    CAST(raw_eligible_securities.product_id AS INTEGER) AS product_id,
    raw_eligible_securities.eligible,
    raw_eligible_securities.raw_created_timestamp,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ source('quiet_companion', 'raw_eligible_securities') }} AS raw_eligible_securities
{% if is_incremental() %}
    WHERE raw_eligible_securities.raw_created_timestamp >= (SELECT MAX(t.raw_created_timestamp) FROM {{ this }} AS t)
{% endif %}

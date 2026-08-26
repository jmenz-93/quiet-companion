{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['ssn', 'effective_date', 'raw_created_timestamp'],
    on_schema_change='sync_all_columns'
) }}

SELECT
    CAST(raw_client_address.effective_date AS DATE) AS effective_date,
    raw_client_address.ssn,
    raw_client_address.address_line_1,
    raw_client_address.address_line_2,
    raw_client_address.city,
    raw_client_address.state,
    raw_client_address.zip_code,
    raw_client_address.county,
    raw_client_address.country,
    raw_client_address.address_type,
    raw_client_address.residency_status,
    CAST(raw_client_address.years_at_current_address AS INTEGER) AS years_at_current_address,
    raw_client_address.raw_created_timestamp,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ source('quiet_companion', 'raw_client_address') }} AS raw_client_address
{% if is_incremental() %}
    WHERE raw_client_address.raw_created_timestamp >= (SELECT MAX(ca.raw_created_timestamp) FROM {{ this }} AS ca)
{% endif %}

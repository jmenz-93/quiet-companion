{{config(
    materialized='incremental',
    incremental_strategy = 'merge',
    unique_key=['ssn', 'address_type', 'effective_start_date'],
    on_schema_change='sync_all_columns'
)}}

WITH ranked AS (
    SELECT
        t.ssn,
        t.address_line_1,
        t.address_line_2,
        t.city,
        t.state,
        t.zip_code,
        t.county,
        t.country,
        t.address_type,
        t.residency_status,
        t.years_at_current_address,
        dbt_valid_from AS effective_start_date,
        dbt_valid_to AS effective_end_date,
        ROW_NUMBER() OVER (PARTITION BY t.ssn, t.effective_date ORDER BY t.raw_created_timestamp DESC) AS row_num
    FROM {{ref('client_address_scd2')}} AS t
    {% if is_incremental() %}
        WHERE t.ssn IN (
            SELECT t2.ssn
            FROM {{ ref('client_address_scd2') }} AS t2
            WHERE t2.effective_date >= (SELECT MAX(t3.effective_date) FROM {{ this }} AS t3)
        )
    {% endif %}
)

SELECT
    ssn,
    address_line_1,
    address_line_2,
    city,
    state,
    zip_code,
    county,
    country,
    address_type,
    residency_status,
    years_at_current_address,
    effective_start_date,
    effective_end_date,
    (dbt_valid_to IS NULL) AS is_current
FROM ranked
WHERE row_num = 1

{{ config(
    materialized='table'
) }}

-- SCD2 client-address dimension built directly from the effective-dated history
-- in typ_client_address. History is tracked per (ssn, address_type); we dedup to
-- one row per (ssn, address_type, effective_date) and derive the validity
-- interval with LEAD. Full rebuild (table) is used because appending a new
-- version must rewrite the prior row's end date.

WITH deduped AS (
    SELECT
        t.effective_date,
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
        ROW_NUMBER() OVER (
            PARTITION BY t.ssn, t.address_type, t.effective_date
            ORDER BY t.raw_created_timestamp DESC
        ) AS row_num
    FROM {{ ref('typ_client_address') }} AS t
),

versioned AS (
    SELECT
        *,
        LEAD(effective_date) OVER (
            PARTITION BY ssn, address_type ORDER BY effective_date
        ) AS effective_end_date
    FROM deduped
    WHERE row_num = 1
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
    effective_date AS effective_start_date,
    effective_end_date,
    (effective_end_date IS NULL) AS is_current
FROM versioned

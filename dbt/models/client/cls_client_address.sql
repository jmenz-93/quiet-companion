{{ config(
    materialized='table'
) }}

-- SCD2 client-address dimension (see scd2 macro), tracked per (ssn, address_type).

SELECT
    scd.ssn,
    scd.address_line_1,
    scd.address_line_2,
    scd.city,
    scd.state,
    scd.zip_code,
    scd.county,
    scd.country,
    scd.address_type,
    scd.residency_status,
    scd.years_at_current_address,
    scd.effective_start_date,
    scd.effective_end_date,
    scd.is_current
FROM {{ scd2(
    ref('typ_client_address'),
    partition_by=['ssn', 'address_type'],
    tracked_columns=[
        'address_line_1', 'address_line_2', 'city', 'state', 'zip_code',
        'county', 'country', 'residency_status', 'years_at_current_address'
    ]
) }} AS scd

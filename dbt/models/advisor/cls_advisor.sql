{{config(
    materialized='table'
)}}

SELECT
    t.advisor_code,
    t.advisor_name,
    t.title,
    t.credentials,
    t.license_series,
    t.hire_date,
    t.years_in_industry,
    t.branch_name,
    t.office_city,
    t.office_state,
    t.email_address,
    t.phone_number,
    t.specialization,
    t.advisor_status,
    t.typ_created_timestamp
FROM {{ref('typ_advisor')}} AS t

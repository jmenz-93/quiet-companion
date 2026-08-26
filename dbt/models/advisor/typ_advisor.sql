{{ config(
    materialized='table'
) }}
SELECT
    advisors.advisor_code,
    advisors.advisor_name,
    advisors.title,
    advisors.credentials,
    advisors.license_series,
    advisors.hire_date,
    advisors.years_in_industry,
    advisors.branch_name,
    advisors.office_city,
    advisors.office_state,
    advisors.email_address,
    advisors.phone_number,
    advisors.specialization,
    advisors.advisor_status,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ ref('advisors') }} AS advisors

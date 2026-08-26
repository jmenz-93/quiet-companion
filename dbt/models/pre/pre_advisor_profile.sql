SELECT
    advisor_code,
    advisor_name,
    title,
    credentials,
    license_series,
    hire_date,
    years_in_industry,
    branch_name,
    office_city,
    office_state,
    email_address,
    phone_number,
    specialization,
    advisor_status
FROM {{ ref('cls_advisor') }}

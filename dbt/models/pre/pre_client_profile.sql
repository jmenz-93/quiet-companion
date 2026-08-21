WITH latest_client AS (
    SELECT DISTINCT ON (ssn) *
    FROM {{ ref('cls_client') }}
    WHERE is_current = TRUE
),

latest_address AS (
    SELECT DISTINCT ON (ssn) *
    FROM {{ ref('cls_client_address') }}
    WHERE is_current = TRUE
)

SELECT
    c.ssn AS client_ssn,
    c.first_name AS client_first_name,
    c.last_name AS client_last_name,
    c.date_of_birth AS client_date_of_birth,
    c.age AS client_age,
    c.marital_status AS client_marital_status,
    c.number_of_dependents AS client_number_of_dependents,
    c.annual_income_bracket AS client_annual_income_bracket,
    c.estimated_net_worth_bracket AS client_estimated_net_worth_bracket,
    c.email_address AS client_email_address,
    c.phone_number AS client_phone_number,
    c.preferred_contact_method AS client_preferred_contact_method,
    c.employment_status AS client_employment_status,
    c.occupation AS client_occupation,
    c.employer_name AS client_employer_name,
    cca.address_line_1 AS client_address_line_1,
    cca.city AS client_city,
    cca.state AS client_state,
    cca.zip_code AS client_zip_code,
    c.citizenship_status AS client_citizenship_status,
    c.education_level AS client_education_level,
    c.politically_exposed_person AS client_politically_exposed_person,
    c.finra_association AS client_finra_association,
    c.aml_flag AS client_anti_money_laundering_flag
FROM latest_client AS c
LEFT JOIN latest_address AS cca ON c.ssn = cca.ssn

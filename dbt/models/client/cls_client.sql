{{config(
    materialized='incremental',
    incremental_strategy = 'merge',
    unique_key=['ssn', 'effective_date'],
    on_schema_change='sync_all_columns'
)}}

WITH ranked AS (
    SELECT
        t.effective_date,
        t.ssn,
        t.first_name,
        t.last_name,
        t.date_of_birth,
        t.marital_status,
        t.number_of_dependents,
        t.email_address,
        t.phone_number,
        t.citizenship_status,
        t.employment_status,
        t.occupation,
        t.employer_name,
        t.annual_income_bracket,
        t.estimated_net_worth_bracket,
        t.education_level,
        t.politically_exposed_person,
        t.finra_association,
        t.aml_flag,
        t.preferred_contact_method,
        t.raw_created_timestamp,
        t.typ_created_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY t.ssn, t.effective_date
            ORDER BY t.raw_created_timestamp DESC
        ) AS row_num
    FROM {{ref('client_scd2')}} AS t
    {% if is_incremental() %}
        WHERE t.ssn IN (
            SELECT t2.ssn
            FROM {{ ref('client_scd2') }} AS t2
            WHERE t2.effective_date >= (SELECT MAX(t3.effective_date) FROM {{ this }} AS t3)
        )
    {% endif %}
)

SELECT --noqa
    effective_date,
    ssn,
    first_name,
    last_name,
    date_of_birth,
    EXTRACT(YEAR FROM AGE(effective_date, date_of_birth)) AS age,
    marital_status,
    number_of_dependents,
    email_address,
    phone_number,
    citizenship_status,
    employment_status,
    occupation,
    employer_name,
    annual_income_bracket,
    estimated_net_worth_bracket,
    education_level,
    politically_exposed_person,
    finra_association,
    aml_flag,
    preferred_contact_method,
    raw_created_timestamp,
    typ_created_timestamp,
    COALESCE((effective_date = MAX(effective_date) OVER (PARTITION BY ssn)), FALSE) AS is_current
FROM ranked
WHERE row_num = 1

{{ config(
    materialized='table'
) }}

-- SCD2 client dimension built directly from the effective-dated history in
-- typ_client. We dedup late-arriving corrections to one row per
-- (ssn, effective_date), then derive the validity interval with LEAD so the
-- boundaries reflect the business effective_date. Full rebuild (table) is used
-- because appending a new version must rewrite the prior row's end date.

WITH deduped AS (
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
        ROW_NUMBER() OVER (
            PARTITION BY t.ssn, t.effective_date
            ORDER BY t.raw_created_timestamp DESC
        ) AS row_num
    FROM {{ ref('typ_client') }} AS t
),

versioned AS (
    SELECT
        *,
        LEAD(effective_date) OVER (
            PARTITION BY ssn ORDER BY effective_date
        ) AS effective_end_date
    FROM deduped
    WHERE row_num = 1
)

SELECT --noqa
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
    effective_date AS effective_start_date,
    effective_end_date,
    (effective_end_date IS NULL) AS is_current
FROM versioned

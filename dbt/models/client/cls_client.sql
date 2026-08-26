{{ config(
    materialized='table'
) }}

-- SCD2 client dimension (see scd2 macro). effective_date-driven history,
-- versioned only on real attribute change; enriched here with derived age.

SELECT
    scd.ssn,
    scd.first_name,
    scd.last_name,
    scd.date_of_birth,
    scd.marital_status,
    scd.number_of_dependents,
    scd.email_address,
    scd.phone_number,
    scd.citizenship_status,
    scd.employment_status,
    scd.occupation,
    scd.employer_name,
    scd.annual_income_bracket,
    scd.estimated_net_worth_bracket,
    scd.education_level,
    scd.politically_exposed_person,
    scd.finra_association,
    scd.aml_flag,
    scd.preferred_contact_method,
    scd.effective_start_date,
    scd.effective_end_date,
    scd.is_current,
    EXTRACT(YEAR FROM AGE(scd.effective_start_date, scd.date_of_birth)) AS age
FROM {{ scd2(
    ref('typ_client'),
    partition_by=['ssn'],
    tracked_columns=[
        'first_name', 'last_name', 'date_of_birth', 'marital_status',
        'number_of_dependents', 'email_address', 'phone_number',
        'citizenship_status', 'employment_status', 'occupation',
        'employer_name', 'annual_income_bracket',
        'estimated_net_worth_bracket', 'education_level',
        'politically_exposed_person', 'finra_association', 'aml_flag',
        'preferred_contact_method'
    ]
) }} AS scd

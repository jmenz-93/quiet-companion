{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['ssn', 'effective_date', 'raw_created_timestamp'],
    on_schema_change='sync_all_columns'
) }}

SELECT
    CAST(raw_client.effective_date AS DATE) AS effective_date,
    raw_client.ssn,
    raw_client.first_name,
    raw_client.last_name,
    CAST(raw_client.date_of_birth AS DATE) AS date_of_birth,
    raw_client.marital_status,
    CAST(raw_client.number_of_dependents AS INTEGER) AS number_of_dependents,
    raw_client.email_address,
    raw_client.phone_number,
    raw_client.citizenship_status,
    raw_client.employment_status,
    raw_client.occupation,
    raw_client.employer_name,
    raw_client.annual_income_bracket,
    raw_client.estimated_net_worth_bracket,
    raw_client.education_level,
    raw_client.politically_exposed_person,
    raw_client.finra_association,
    raw_client.aml_flag,
    raw_client.preferred_contact_method,
    raw_client.raw_created_timestamp,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ source('quiet_companion', 'raw_client') }} AS raw_client
{% if is_incremental() %}
    WHERE raw_client.raw_created_timestamp >= (SELECT MAX(c.raw_created_timestamp) FROM {{ this }} AS c)
{% endif %}

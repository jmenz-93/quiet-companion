{% snapshot client_scd2 %}

{{ config(
  target_schema='snapshots',
  unique_key='ssn',
  strategy='check',
  check_cols=['effective_date','first_name','last_name','date_of_birth','marital_status','number_of_dependents','email_address','phone_number','citizenship_status','employment_status','occupation','employer_name','annual_income_bracket','estimated_net_worth_bracket','education_level','politically_exposed_person','finra_association','aml_flag','preferred_contact_method']
) }}

    SELECT * FROM {{ ref('typ_client') }}

{% endsnapshot %}

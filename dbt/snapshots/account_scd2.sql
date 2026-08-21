{% snapshot account_scd2 %}

{{ config(
  target_schema='snapshots',
  unique_key='account_number',
  strategy='check',
  check_cols=['effective_date','ssn','product_id','account_status','date_opened','date_closed','last_review_date','custodian','advisor_code','investment_objective','risk_profile','time_horizon','rebalance_frequency','annual_contribution','management_fee','margin_enabled','options_approved','beneficiary_designated','esg_preference']
) }}

    SELECT * FROM {{ ref('typ_account') }}

{% endsnapshot %}

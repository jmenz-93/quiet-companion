{% snapshot client_address_scd2 %}

{{ config(
  target_schema='snapshots',
  unique_key=['ssn','address_type'],
  strategy='check',
  check_cols=['effective_date','address_line_1','address_line_2','city','state','zip_code','county','country','residency_status','years_at_current_address']
) }}

    SELECT * FROM {{ ref('typ_client_address') }}

{% endsnapshot %}

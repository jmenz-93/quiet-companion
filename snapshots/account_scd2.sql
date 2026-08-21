{% snapshot account_scd2 %}

{{ config(
  target_schema='snapshots',
  unique_key='account_number',
  strategy='timestamp',
  updated_at='raw_created_timestamp'
) }}

select * from {{ ref('typ_account') }}

{% endsnapshot %}

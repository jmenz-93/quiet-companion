{% snapshot client_scd2 %}

{{ config(
  target_schema='snapshots',
  unique_key='ssn',
  strategy='timestamp',
  updated_at='raw_created_timestamp'
) }}

select * from {{ ref('typ_client') }}

{% endsnapshot %}

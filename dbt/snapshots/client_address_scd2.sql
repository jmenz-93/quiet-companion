{% snapshot client_address_scd2 %}

{{ config(
  target_schema='snapshots',
  unique_key='ssn',
  strategy='timestamp',
  updated_at='raw_created_timestamp'
) }}

    SELECT * FROM {{ ref('typ_client_address') }}

{% endsnapshot %}

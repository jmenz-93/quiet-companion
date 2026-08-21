{#
    Build a Type-2 slowly-changing dimension from an effective-dated source.

    The source is expected to already carry history: one row per
    (business key, effective_column), with an order_column to break ties on
    late-arriving corrections. The macro:
      1. dedups to one row per (partition_by..., effective_column)
      2. keeps a version only when a tracked attribute actually changes (hash diff)
      3. derives the validity interval with LEAD over the surviving versions

    Returns a parenthesized subquery exposing every source column plus
    effective_start_date, effective_end_date and is_current. (Postgres has no
    SELECT * EXCLUDE, so the _rn / _row_hash / _prev_hash helper columns pass
    through — list columns explicitly in the caller's final SELECT.)

    Args:
      relation:         a Relation, usually ref('typ_...')
      partition_by:     list of business-key columns, e.g. ['ssn'] or ['ssn','address_type']
      tracked_columns:  list of attributes whose change starts a new version
      effective_column: date the version takes effect (default 'effective_date')
      order_column:     tie-breaker for same-date corrections (default 'raw_created_timestamp')

    Example:
      select ... from {{ scd2(ref('typ_client'), ['ssn'], ['first_name', ...]) }} as scd
#}

{% macro scd2(relation, partition_by, tracked_columns,
              effective_column='effective_date',
              order_column='raw_created_timestamp') %}
{%- set pk = partition_by | join(', ') -%}
(
    with _scd_dedup as (
        select
            *,
            row_number() over (
                partition by {{ pk }}, {{ effective_column }}
                order by {{ order_column }} desc
            ) as _rn
        from {{ relation }}
    ),

    _scd_hashed as (
        select
            *,
            {{ dbt_utils.generate_surrogate_key(tracked_columns) }} as _row_hash
        from _scd_dedup
        where _rn = 1
    ),

    _scd_lagged as (
        select
            *,
            lag(_row_hash) over (
                partition by {{ pk }} order by {{ effective_column }}
            ) as _prev_hash
        from _scd_hashed
    ),

    -- keep only rows where a tracked attribute changed vs the previous version
    _scd_versions as (
        select
            *,
            {{ effective_column }} as effective_start_date,
            lead({{ effective_column }}) over (
                partition by {{ pk }} order by {{ effective_column }}
            ) as effective_end_date
        from _scd_lagged
        where _prev_hash is distinct from _row_hash
    )

    select
        *,
        (effective_end_date is null) as is_current
    from _scd_versions
)
{% endmacro %}

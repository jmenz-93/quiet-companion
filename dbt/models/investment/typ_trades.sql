{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['trade_id', 'effective_date', 'raw_created_timestamp'],
    on_schema_change='sync_all_columns'
) }}

SELECT
    CAST(raw_trades.effective_date AS DATE) AS effective_date,
    raw_trades.trade_id,
    raw_trades.account_number,
    CAST(raw_trades.product_id AS INTEGER) AS product_id,
    raw_trades.ssn,
    raw_trades.advisor_code,
    CAST(raw_trades.trade_date AS DATE) AS trade_date,
    CAST(raw_trades.settlement_date AS DATE) AS settlement_date,
    raw_trades.ticker,
    raw_trades.action,
    CAST(raw_trades.quantity AS DECIMAL(18, 8)) AS quantity,
    CAST(raw_trades.price AS DECIMAL(12, 4)) AS price,
    CAST(raw_trades.commission AS DECIMAL(12, 4)) AS commission,
    CAST(raw_trades.net_amount AS DECIMAL(18, 4)) AS net_amount,
    raw_trades.cash_flow_direction,
    raw_trades.currency,
    raw_trades.order_type,
    raw_trades.raw_created_timestamp,
    CURRENT_TIMESTAMP AS typ_created_timestamp
FROM {{ source('quiet_companion', 'raw_trades') }} AS raw_trades
{% if is_incremental() %}
    WHERE raw_trades.raw_created_timestamp >= (SELECT MAX(t.raw_created_timestamp) FROM {{ this }} AS t)
{% endif %}

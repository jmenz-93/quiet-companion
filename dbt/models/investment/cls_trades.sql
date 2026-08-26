{{config(
    materialized='incremental',
    incremental_strategy = 'merge',
    unique_key=['trade_id', 'effective_date'],
    on_schema_change='sync_all_columns'
)}}

WITH ranked AS (
    SELECT
        trades.effective_date,
        trades.trade_id,
        trades.account_number,
        trades.ssn,
        trades.advisor_code,
        trades.trade_date,
        trades.settlement_date,
        trades.ticker,
        trades.action,
        trades.quantity,
        trades.price,
        trades.commission,
        trades.net_amount,
        trades.cash_flow_direction,
        trades.currency,
        trades.order_type,
        trades.raw_created_timestamp,
        trades.typ_created_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY trades.trade_id, trades.effective_date
            ORDER BY trades.raw_created_timestamp DESC
        ) AS row_num
    FROM {{ref('typ_trades')}} AS trades
    WHERE
        trades.trade_id IS NOT NULL
        {% if is_incremental() %}
            AND trades.effective_date >= (SELECT MAX(t2.effective_date) FROM {{ this }} AS t2)
        {% endif %}
)

SELECT
    effective_date,
    trade_id,
    account_number,
    ssn,
    advisor_code,
    trade_date,
    settlement_date,
    ticker,
    action,
    quantity,
    price,
    commission,
    net_amount,
    cash_flow_direction,
    currency,
    order_type,
    raw_created_timestamp,
    typ_created_timestamp
FROM ranked
WHERE row_num = 1

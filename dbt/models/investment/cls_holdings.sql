{{ config(materialized='table') }}

WITH daily AS (
    SELECT
        account_number,
        ssn,
        ticker,
        effective_date,
        SUM(CASE
            WHEN action IN ('Buy', 'Rebalance Buy', 'Dividend Reinvestment', 'Transfer In') THEN quantity
            WHEN action IN ('Sell', 'Rebalance Sell', 'Transfer Out') THEN quantity * -1
            ELSE 0
        END) AS share_change,
        SUM(CASE
            WHEN action IN ('Buy', 'Rebalance Buy', 'Dividend Reinvestment', 'Transfer In') THEN net_amount
            ELSE 0
        END) AS cost_change,
        SUM(CASE WHEN action = 'Dividend (Cash)' THEN net_amount ELSE 0 END) AS dividend_income,
        SUM(CASE WHEN action = 'Interest' THEN net_amount ELSE 0 END) AS interest_income,
        SUM(CASE WHEN action = 'Capital Gain Distribution' THEN net_amount ELSE 0 END) AS capital_gain_distributions,
        SUM(CASE WHEN action IN ('Sell', 'Rebalance Sell') THEN net_amount ELSE 0 END) AS realized_proceeds
    FROM {{ ref('cls_trades') }}
    GROUP BY account_number, ssn, ticker, effective_date
),

cumulative AS (
    SELECT
        account_number,
        ssn,
        ticker,
        effective_date,
        SUM(share_change) OVER w AS shares_owned,
        SUM(cost_change) OVER w AS cost_basis,
        SUM(dividend_income) OVER w AS dividend_income,
        SUM(interest_income) OVER w AS interest_income,
        SUM(capital_gain_distributions) OVER w AS capital_gain_distributions,
        SUM(realized_proceeds) OVER w AS realized_proceeds
    FROM daily
    WINDOW w AS (
        PARTITION BY account_number, ssn, ticker
        ORDER BY effective_date
        ROWS UNBOUNDED PRECEDING
    )
)

SELECT
    effective_date,
    account_number,
    ssn,
    ticker,
    shares_owned,
    cost_basis,
    dividend_income,
    interest_income,
    capital_gain_distributions,
    realized_proceeds,
    CASE
        WHEN shares_owned > 0
            THEN ROUND(cost_basis / shares_owned, 4)
        ELSE 0
    END AS average_cost_per_share
FROM cumulative
WHERE shares_owned > 0

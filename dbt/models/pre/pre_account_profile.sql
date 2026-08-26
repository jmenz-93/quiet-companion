SELECT
    ca.account_number,
    ca.ssn AS client_ssn,
    ca.advisor_code,
    ca2.advisor_name,
    ca.product_name,
    ca.product_category,
    ca.tax_status,
    ca.account_status,
    ca.date_opened,
    ca.date_closed,
    ca.last_review_date,
    ca.investment_objective,
    ca.annual_contribution,
    ca.margin_enabled,
    ca.options_approved,
    ca.esg_preference
FROM {{ ref('cls_account') }} AS ca
LEFT JOIN {{ ref('cls_advisor') }} AS ca2 ON ca.advisor_code = ca2.advisor_code
WHERE ca.is_current = TRUE

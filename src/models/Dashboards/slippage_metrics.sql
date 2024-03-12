SELECT
    slippage,
    CAST(amount as BIGINT) / power(10, 18) AS amount_eth,
    CASE
        WHEN domain_id = '6648936' THEN 'Ethereum'
        WHEN domain_id = '1869640809' THEN 'Optimism'
        WHEN domain_id = '6450786' THEN 'BNB'
        WHEN domain_id = '6778479' THEN 'Gnosis'
        WHEN domain_id = '1886350457' THEN 'Polygon'
        WHEN domain_id = '1634886255' THEN 'Arbitrum One'
        WHEN domain_id = '1818848877' THEN 'Linea'
        WHEN domain_id = '1835365481' THEN 'Metis'
        WHEN domain_id = '1650553709' THEN 'Base'
        ELSE
            domain_id
    END
        AS chain_name,
    format_timestamp('%Y-%m-%d %H:%M:%S', timestamp_seconds(CAST(timestamp as INT)) AS timestamp_time
FROM
    {{ ref('slippage_historical') }}

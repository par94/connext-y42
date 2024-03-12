SELECT
    slippage,
    CAST(amount as BIGINT) / power(10, 18) AS amount_eth,
    CASE
        WHEN domain = '6648936' THEN 'Ethereum'
        WHEN domain = '1869640809' THEN 'Optimism'
        WHEN domain = '6450786' THEN 'BNB'
        WHEN domain = '6778479' THEN 'Gnosis'
        WHEN domain = '1886350457' THEN 'Polygon'
        WHEN domain = '1634886255' THEN 'Arbitrum One'
        WHEN domain = '1818848877' THEN 'Linea'
        WHEN domain = '1835365481' THEN 'Metis'
        WHEN domain = '1650553709' THEN 'Base'
        ELSE
            domain
    END
        AS chain_name,
    format_timestamp('%Y-%m-%d %H:%M:%S', timestamp_seconds(timestamp)) AS timestamp_time
FROM
    {{ ref('slippage_historical') }}

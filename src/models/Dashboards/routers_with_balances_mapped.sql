SELECT 
    COALESCE(dm.name, rwb.`asset_domain`) AS destination_domain_name,
    COALESCE(tam.`assetid_symbol`, rwb.`adopted`)  AS adopted_asset_name,
    COALESCE(CAST(tam.`assetid_decimals` AS NUMERIC), rwb.`adopted_decimal`)  AS adopted_asset_decimal,
    COALESCE(rm.`name`, rwb.`router_address`)  AS router_name,
    rwb.*
FROM {{ source('Cartographer', 'public_routers_with_balances') }} AS rwb
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS dm ON rwb.`asset_domain` = dm.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS tam ON rwb.`adopted` = tam.`assetid` AND rwb.`asset_domain` = tam.`domainid`
LEFT JOIN {{ source('bq_raw', 'raw_dim_connext_routers_name') }} AS rm ON rwb.`router_address` = rm.`router`

WITH ttt AS (
SELECT
    COALESCE(odm.name,t.origin_domain) AS origin_domain_name,
    COALESCE(ddm.name,t.`destination_domain`) AS destination_domain_name,
    COALESCE(otam.`assetid_symbol`,t.`origin_transacting_asset`)  AS origin_asset_name,
    COALESCE(otam.`assetid_decimals`, NULL) AS origin_asset_decimals,
    COALESCE(dtam.`assetid_symbol`,t.`destination_transacting_asset`) AS destination_asset_name,
    COALESCE(dtam.`assetid_decimals`, NULL) AS destination_asset_decimals,
    t.*
FROM {{ ref('transfers') }} AS t
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS odm ON t.`origin_domain` = odm.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS ddm ON t.`destination_domain` = ddm.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS otam ON t.`origin_transacting_asset` = otam.`assetid` AND t.`origin_domain` = otam.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS dtam ON t.`destination_transacting_asset` = dtam.`assetid`AND t.`destination_domain` = dtam.`domainid`
)
SELECT * FROM ttt -- WHERE (destination_transacting_asset IS NOT NULL and destination_asset_name IS NULL) OR (origin_transacting_asset IS NOT NULL and origin_asset_name IS NULL)

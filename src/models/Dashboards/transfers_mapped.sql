WITH ttt AS (
SELECT
    odm.name AS origin_domain_name,
    ddm.name AS destination_domain_name,
    otam.`assetid_symbol` AS origin_asset_name,
    otam.`assetid_decimals` AS origin_asset_decimals,
    dtam.`assetid_symbol` AS destination_asset_name,
    dtam.`assetid_decimals` AS destination_asset_decimals,
    t.*
FROM {{ ref('transfers') }} AS t
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS odm ON t.`origin_domain` = odm.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS ddm ON t.`destination_domain` = ddm.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS otam ON t.`origin_transacting_asset` = otam.`assetid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS dtam ON t.`destination_transacting_asset` = dtam.`assetid`
)
SELECT * FROM ttt -- WHERE (destination_transacting_asset IS NOT NULL and destination_asset_name IS NULL) OR (origin_transacting_asset IS NOT NULL and origin_asset_name IS NULL)

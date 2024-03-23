--TO DO

--fix_pricing
--Missing assets
WITH connext_tokens AS (
    SELECT DISTINCT
    ct.token_address,
    ct.token_name,
    ct.is_xerc20
  FROM {{ source('bq_stage', 'stage_connext_tokens') }} ct
),

ttt AS (
    SELECT
    COALESCE(odm.name,t.origin_domain) AS origin_domain_name,
    COALESCE(ddm.name,t.`destination_domain`) AS destination_domain_name,
    COALESCE(otam.`assetid_symbol`, dtam.`assetid_symbol`, cc_origin.token_name, t.`origin_transacting_asset`)  AS origin_asset_name,
    COALESCE(otam.`assetid_decimals`, NULL) AS origin_asset_decimals,
    COALESCE(dtam.`assetid_symbol`, otam.`assetid_symbol`, cc_destination.token_name, t.`destination_transacting_asset`) AS destination_asset_name,
    COALESCE(dtam.`assetid_decimals`, NULL) AS destination_asset_decimals,
    CAST(cc_origin.is_xerc20 AS BOOL) AS is_origin_asset_xerc20,
    CAST(cc_destination.is_xerc20 AS BOOL) AS is_destination_asset_xerc20,
    CASE WHEN LOWER(t.xcall_caller) != LOWER(t.xcall_tx_origin) THEN 'Contract' ELSE 'EOA' END AS caller_type,
    --t.destination_transacting_amount, 
    cc.* EXCEPT (xcall_caller, rn),
    t.*
    FROM {{ ref('transfers') }} AS t
    LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS odm ON t.`origin_domain` = odm.`domainid`
    LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS ddm ON t.`destination_domain` = ddm.`domainid`
    LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS otam ON t.`origin_transacting_asset` = otam.`assetid` AND t.`origin_domain` = otam.`domainid`
    LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS dtam ON t.`destination_transacting_asset` = dtam.`assetid`AND t.`destination_domain` = dtam.`domainid`
    LEFT JOIN connext_tokens AS cc_origin ON t.origin_transacting_asset = cc_origin.token_address
    LEFT JOIN connext_tokens AS cc_destination ON t.destination_transacting_asset = cc_destination.token_address
    LEFT JOIN (
        SELECT 
        LOWER(xcall_caller) AS xcall_caller,
        * EXCEPT (xcall_caller)
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY `xcall_caller` ORDER BY `contract_name`) AS rn
            FROM {{ source('Mapping', 'contracts') }}
        ) AS subquery
        WHERE rn = 1
        ) AS cc ON t.`xcall_caller` = cc.`xcall_caller`
)

SELECT * FROM ttt -- WHERE (destination_transacting_asset IS NOT NULL and destination_asset_name IS NULL) OR (origin_transacting_asset IS NOT NULL and origin_asset_name IS NULL)

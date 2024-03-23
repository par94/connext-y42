WITH connext_tokens AS (
    SELECT DISTINCT
        ct.token_address,
        ct.token_name,
        ct.is_xerc20
    FROM {{ source('bq_stage', 'stage_connext_tokens') }} AS ct
),

fj AS (
    SELECT *
    FROM {{ source('Cartographer', 'public_assets') }} AS pa
    FULL JOIN
        {{ source('github_tokens_parser', 'github_parser_tokens') }} AS gtp
        ON pa.`domain` = gtp.`domainid` AND pa.`id` = gtp.`assetid`
),

origin_unmapped AS (
    SELECT DISTINCT
        t.`origin_transacting_asset`,
        t.`origin_domain`
    FROM
        {{ ref('transfers') }} AS t LEFT JOIN
        {{ source('Cartographer', 'public_assets') }} AS pa
        ON t.`origin_transacting_asset` = pa.`id` AND t.`origin_domain` = pa.`domain`
    WHERE pa.id IS NULL
),

destination_unmapped AS (
    SELECT DISTINCT
        t.`destination_transacting_asset`,
        t.`destination_domain`
    FROM
        {{ ref('transfers') }} AS t LEFT JOIN
        {{ source('Cartographer', 'public_assets') }} AS pa
        ON t.`destination_transacting_asset` = pa.`id` AND t.`destination_domain` = pa.`domain`
    WHERE pa.id IS NULL
),

destination_mapped AS (
    SELECT *
    FROM destination_unmapped AS dum
    LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS gtp
        ON dum.`destination_domain` = gtp.`domainid` AND dum.`destination_transacting_asset` = gtp.`assetid`
    WHERE `destination_transacting_asset` IS NOT NULL
),

origin_mapped AS (
    SELECT *
    FROM origin_unmapped AS dum
    LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS gtp
        ON dum.`origin_domain` = gtp.`domainid` AND dum.`origin_transacting_asset` = gtp.`assetid`
),

combinations AS (
    SELECT DISTINCT domain, asset
    FROM (
        SELECT origin_domain AS domain, origin_transacting_asset AS asset
        FROM {{ ref('transfers') }}

        UNION ALL

        SELECT destination_domain AS domain, destination_transacting_asset AS asset
        FROM {{ ref('transfers') }}
    ) AS combined
    WHERE asset IS NOT NULL
),
mapping AS (
 SELECT 
t.*,
dm.name as domain_name,
tam.assetid_symbol as asset_name,
cc.*,
tam.*
FROM combinations AS t
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS dm ON t.`domain` = dm.`domainid`
--LEFT JOIN {{ source('github_tokens_parser', 'github_parser_chains') }} AS ddm ON t.`destination_domain` = ddm.`domainid`
LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS tam ON t.`asset` = tam.`assetid` AND t.`domain` = tam.`domainid`
--LEFT JOIN {{ source('github_tokens_parser', 'github_parser_tokens') }} AS dtam ON t.`destination_transacting_asset` = dtam.`assetid` AND t.`destination_domain` = dtam.`domainid`
LEFT JOIN connext_tokens AS cc ON t.asset = cc.token_address
--LEFT JOIN connext_tokens AS cc_destination ON t.destination_transacting_asset = cc_destination.token_address
WHERE tam.assetid_symbol is NULL AND cc.`token_name` is NULL 
ORDER BY `domain`, `asset`
)

--SELECT count(*) FROM combinations
SELECT * FROM mapping


--WHERE `destination_transacting_asset` is NOT NULL
/*
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
*/

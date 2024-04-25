--fix pricing
WITH router_mapping AS (
SELECT 
    COALESCE(tm.domain_name, rwb.`asset_domain`) AS destination_domain_name,
    COALESCE(tm.`asset_name`, rwb.`adopted`)  AS asset_name,
    --COALESCE(CAST(tam.`assetid_decimals` AS NUMERIC), rwb.`adopted_decimal`)  AS adopted_asset_decimal,
    COALESCE(rm.`name`, rwb.`router_address`)  AS router_name,
    rwb.*
FROM {{ source('Cartographer', 'public_routers_with_balances') }} AS rwb
LEFT JOIN {{ ref('token_mapping') }} AS tm ON rwb.`asset_domain` = tm.`domain` AND rwb.`adopted` = tm.`asset`
--rwb.`asset_canonical_id` = tm.`canonical_id`
LEFT JOIN {{ source('bq_raw', 'raw_dim_connext_routers_name') }} AS rm ON LOWER(rwb.`router_address`) = LOWER(rm.`router`)
),
price_fix AS (
  SELECT 
  CASE
      WHEN t1.asset_name in ('dai','xdai','usdt','wxdai','m.usdt','usdc') AND (t1.asset_usd_price = 0) THEN 1
      WHEN t1.asset_name in ('ezeth','weth','aeth') AND (t1.asset_usd_price = 0) THEN t2.eth_price
      ELSE t1.asset_usd_price
    END AS asset_usd_price,
    CASE
      WHEN t1.asset_name in ('dai','xdai','usdt','wxdai','m.usdt','usdc') AND (t1.asset_usd_price = 0) THEN t1.balance / power(10, decimal)
      WHEN t1.asset_name in ('ezeth','weth','aeth') AND (t1.asset_usd_price = 0) THEN t1.balance / power(10, decimal) * t2.eth_price
      ELSE t1.balance_usd
    END AS balance_usd,
    CASE
      WHEN t1.asset_name in ('dai','xdai','usdt','wxdai','m.usdt','usdc') AND (t1.asset_usd_price = 0) THEN t1.locked / power(10, decimal)
      WHEN t1.asset_name in ('ezeth','weth','aeth') AND (t1.asset_usd_price = 0) THEN t1.locked / power(10, decimal) * t2.eth_price
      ELSE t1.locked_usd
    END AS locked_usd,
    CASE
      WHEN t1.asset_name in ('dai','xdai','usdt','wxdai','m.usdt','usdc') AND (t1.asset_usd_price = 0) THEN t1.removed / power(10, decimal)
      WHEN t1.asset_name in ('ezeth','weth','aeth') AND (t1.asset_usd_price = 0) THEN t1.removed / power(10, decimal) * t2.eth_price
      ELSE t1.removed_usd
    END AS removed_usd,
    CASE
      WHEN t1.asset_name in ('dai','xdai','usdt','wxdai','m.usdt','usdc') AND (t1.asset_usd_price = 0) THEN t1.supplied / power(10, decimal)
      WHEN t1.asset_name in ('ezeth','weth','aeth') AND (t1.asset_usd_price = 0) THEN t1.supplied / power(10, decimal) * t2.eth_price
      ELSE t1.supplied_usd
    END AS supplied_usd,
    CASE
      WHEN t1.asset_name in ('dai','xdai','usdt','wxdai','m.usdt','usdc') AND (t1.asset_usd_price = 0) THEN t1.fees_earned / power(10, decimal)
      WHEN t1.asset_name in ('ezeth','weth','aeth') AND (t1.asset_usd_price = 0) THEN t1.fees_earned / power(10, decimal) * t2.eth_price
      ELSE t1.fee_earned_usd
    END AS fee_earned_usd,
  * EXCEPT (asset_usd_price, balance_usd, locked_usd, removed_usd, supplied_usd, fee_earned_usd)
  FROM router_mapping t1
  CROSS JOIN (
    SELECT asset_usd_price as ETH_price
    FROM {{ ref('transfers_mapped') }}
    WHERE origin_asset_name = 'weth' and asset_usd_price > 0
    ORDER BY xcall_timestamp DESC
    LIMIT 1
  ) t2
),
last_bid AS (
    SELECT 
    pf.*,
    rb.last_bid,
    FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_SECONDS(CAST(rb.last_bid AS INT64))) AS last_bid_time,
    CASE WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), TIMESTAMP_SECONDS(CAST(rb.last_bid AS INT64)), HOUR) >= 2 THEN "Inactive" ELSE "Active" END AS Active

    FROM price_fix AS pf 
    LEFT JOIN {{ ref('router_bids') }} AS rb 
    ON pf.router_address = rb.router_address 
    AND 
    pf.adopted = rb.token_address
    AND pf.asset_domain = rb.router_domain
)

SELECT * FROM last_bid ORDER BY balance_usd DESC

--WHERE `asset_usd_price` = 0 AND balance > 0 --AND tm.`asset_name` = 'weth'
--WHERE tm.`asset_name` is NULL
/*
LEFT JOIN 'github_parser_chains') }} AS dm ON rwb.`asset_domain` = dm.`domainid`
LEFT JOIN 'github_parser_tokens') }} AS tam ON rwb.`adopted` = tam.`assetid` AND rwb.`asset_domain` = tam.`domainid`
*/

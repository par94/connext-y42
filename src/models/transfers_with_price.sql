SELECT
  t.*,
  t.transfer_id,
  p.asset_usd_price,
  p.decimals,
  p.asset_usd_price * (CAST(t.bridged_amt AS FLOAT64) / POW(10, p.decimals)) AS usd_amount
FROM {{ source('Cartographer','public_transfers_with_numeric_id') }} AS t
  LEFT JOIN (
    SELECT
      t_1.transfer_id,
      t_1.xcall_timestamp,
      COALESCE(p_1.price, 0) AS asset_usd_price,
      (
        SELECT a.decimal
        FROM {{ source('Cartographer', 'public_assets') }} AS a
        WHERE a.canonical_id = t_1.canonical_id
        LIMIT 1
      ) AS decimals
    FROM {{ source('Cartographer', 'public_transfers_with_numeric_id') }} AS t_1
      LEFT JOIN {{ source('Cartographer', 'public_asset_prices') }}
        AS p_1 ON p_1.canonical_id = t_1.canonical_id
        AND p_1.timestamp = (
        (
          SELECT MAX(ap.timestamp) AS maxtimestamp
          FROM {{ source('Cartographer', 'public_asset_prices') }} AS ap
          WHERE
            ap.canonical_id = t_1.canonical_id
            AND ap.timestamp <= t_1.xcall_timestamp
        )
      )
  ) AS p ON t.transfer_id = p.transfer_id

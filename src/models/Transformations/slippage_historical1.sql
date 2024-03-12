   SELECT *
    FROM {{ ref('slippage_historical') }}
    WHERE row_hash NOT IN (
        SELECT row_hash
        FROM {{ this }}
    )

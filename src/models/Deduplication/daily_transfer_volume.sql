SELECT
     *,
     row_number() OVER (PARTITION BY `id` ORDER BY SystemModstamp DESC) AS row_num
FROM {{ source('Cartographer', 'public_daily_transfer_volume') }}
QUALIFY row_num = 1

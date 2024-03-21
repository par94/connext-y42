SELECT * FROM {{ ref('transfers') }}
LEFT JOIN {{ source('bq_raw', '') }}

INSERT INTO {{ ref('slippage_historical') }}
SELECT * FROM {{ source('slippage_monitoring', 'slippage_monitoring') }}

--INSERT INTO {{ this }}
SELECT * FROM {{ source('slippage_monitoring', 'slippage_monitoring') }}

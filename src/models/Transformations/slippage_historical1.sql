{{ config(materialized='incremental') }}

WITH source_data AS (
    SELECT *
    --CURRENT_TIMESTAMP() AS version_timestamp -- Captures the refresh timestamp
    FROM {{ source('slippage_monitoring', 'slippage_monitoring') }}
)

SELECT *
FROM source_data

{{ config(materialized='incremental', unique_key='row_hash') }}

WITH source_data AS (
    SELECT
        *,
        --CURRENT_TIMESTAMP() AS version_timestamp -- Captures the refresh timestamp
        MD5(CONCAT(
            ',', COALESCE(CAST(domain_id AS STRING), ''), COALESCE(CAST(asset AS STRING), ''),
            COALESCE(CAST(amount AS STRING), ''), COALESCE(CAST(`timestamp` AS STRING), '')
        )) AS row_hash
    FROM {{ source('slippage_monitoring', 'slippage_monitoring') }}
)

SELECT *
FROM source_data

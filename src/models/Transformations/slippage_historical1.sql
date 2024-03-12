--{{ config(materialized='incremental') }} -- noqa: TMP

{% set source_count = dbt_utils.get_row_count(ref('slippage_historical')) %}
{% set model_count = dbt_utils.get_row_count(this) %}

{% if source_count > model_count %}
    -- If the source table has more rows, perform a complete copy
    SELECT *
    FROM {{ ref('slippage_historical') }}
{% else %}
    -- If the source table has the same or fewer rows, perform an incremental update
    SELECT *
    FROM {{ ref('slippage_historical') }}
    WHERE row_hash NOT IN (
        SELECT row_hash
        FROM {{ this }}
    )
{% endif %}


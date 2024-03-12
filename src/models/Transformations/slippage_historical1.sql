{{ config(materialized='incremental') }}

{{ ref('daily_transfer_volume_y42_dedup') }}

{% set source_count = dbt_utils.get_row_count({{ ref('daily_transfer_volume_y42_dedup') }}) %}
{% set model_count = dbt_utils.get_row_count(this) %}

{% if source_count > model_count %}
    -- If the source table has more rows, perform a complete copy
    SELECT *
    FROM {{ ref('daily_transfer_volume_y42_dedup') }}
{% else %}
    -- If the source table has the same or fewer rows, perform an incremental update
    SELECT *
    FROM {{ ref('daily_transfer_volume_y42_dedup') }}
    WHERE row_hash NOT IN (
        SELECT row_hash
        FROM {{ this }}
    )
{% endif %}


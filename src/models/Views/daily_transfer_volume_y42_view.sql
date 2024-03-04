SELECT
    tf.status,
    date_trunc('day'::text, to_timestamp(tf.xcall_timestamp::double precision))::date AS transfer_date,
    tf.origin_domain AS origin_chain,
    tf.destination_domain AS destination_chain,
    regexp_replace(tf.routers::text, '[\{\}]'::text, ''::text, 'g'::text) AS router,
    tf.origin_transacting_asset AS asset,
    sum(tf.origin_transacting_amount::numeric) AS volume,
    avg(tf.asset_usd_price) AS avg_price,
    sum(tf.usd_amount) AS usd_volume,
    row_number() OVER () AS id
FROM {{ ref('transfers_with_price_ttr_ttv_y42_dedup') }} AS tf
GROUP BY
    tf.status, 
    (date_trunc('day'::text, to_timestamp(tf.xcall_timestamp::double precision))::date), 
    tf.origin_domain, 
    tf.destination_domain, 
    (regexp_replace(tf.routers::text, '[\{\}]'::text, ''::text, 'g'::text)), 
    tf.origin_transacting_asset;

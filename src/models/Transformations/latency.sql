SELECT
    status,
    origin_transacting_asset,
    origin_domain,
    destination_transacting_asset,
    destination_domain,
    xcall_date,
    COUNT(*) AS count,
    (
        SELECT COUNT(*)
        FROM {{ ref('transfers') }} AS tf1
        WHERE
            (updated_slippage > 0 OR error_status LIKE '%slippage%')
            AND tf1.origin_transacting_asset = tf.origin_transacting_asset
            AND tf1.origin_domain = tf.origin_domain
            AND tf1.destination_transacting_asset = tf.destination_transacting_asset
            AND tf1.destination_domain = tf.destination_domain
            AND tf1.xcall_date = tf.xcall_date
    ) AS count_bumped_transfers,
    (
        SELECT SUM(usd_amount)
        FROM {{ ref('transfers') }} AS tf2
        WHERE
            (updated_slippage > 0 OR error_status LIKE '%slippage%')
            AND tf2.origin_transacting_asset = tf.origin_transacting_asset
            AND tf2.origin_domain = tf.origin_domain
            AND tf2.destination_transacting_asset = tf.destination_transacting_asset
            AND tf2.destination_domain = tf.destination_domain
            AND tf2.xcall_date = tf.xcall_date
    ) AS sum_bumped_transfers,
    SUM(usd_amount) AS total_usd_amount,
    AVG(ttv) AS avg_ttv,
    MAX(ttv) AS max_ttv,
    MIN(ttv) AS min_ttv,
    APPROX_QUANTILES(ttv, 100)[ORDINAL(50)] AS median_ttv,
    APPROX_QUANTILES(ttv, 100)[ORDINAL(10)] AS per10th_ttv,
    APPROX_QUANTILES(ttv, 100)[ORDINAL(90)] AS per90th_ttv,
    APPROX_QUANTILES(ttv, 100)[ORDINAL(95)] AS per95th_ttv,
    APPROX_QUANTILES(ttv, 100)[ORDINAL(99)] AS per99th_ttv,
    APPROX_QUANTILES(ttr, 100)[ORDINAL(50)] AS median_ttr,
    APPROX_QUANTILES(ttr, 100)[ORDINAL(10)] AS per10th_ttr,
    APPROX_QUANTILES(ttr, 100)[ORDINAL(90)] AS per90th_ttr,
    APPROX_QUANTILES(ttr, 100)[ORDINAL(95)] AS per95th_ttr,
    APPROX_QUANTILES(ttr, 100)[ORDINAL(99)] AS per99th_ttr
FROM
    {{ ref('transfers') }} AS tf
WHERE
    CAST(xcall_date as DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY
    1,2,3,4,5,6

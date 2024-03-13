WITH ModeTransfers AS (
    SELECT * FROM {{ ref('transfers') }}
    WHERE `origin_domain` = '1836016741' OR `destination_domain` = '1836016741'
),
Volume_metrics AS (
SELECT
    Status,
    Routers,
    Origin_Bridged_Asset,
    Origin_Domain,
    Destination_Domain,
    SUM(CASE WHEN CASt(Xcall_Date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) THEN Usd_Amount ELSE 0 END)
        AS Usd_Volume_1d,
    SUM(CASE WHEN CASt(Xcall_Date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) THEN Usd_Amount ELSE 0 END)
        AS Usd_Volume_7d,
    SUM(CASE WHEN CASt(Xcall_Date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) THEN Usd_Amount ELSE 0 END)
        AS Usd_Volume_30d,
    SUM(CASE WHEN CASt(Xcall_Date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) THEN CAST(Normalized_In as Numeric) ELSE 0 END)
        AS Volume_1d,
    SUM(CASE WHEN CASt(Xcall_Date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) THEN CAST(Normalized_In as Numeric) ELSE 0 END)
        AS Volume_7d,
    SUM(CASE WHEN CASt(Xcall_Date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) THEN CAST(Normalized_In as Numeric) ELSE 0 END)
        AS Volume_30d,
    MAX(CASt(Xcall_Date AS DATE)) AS Last_Transfer_Date,
    COUNTIF(Status = 'CompletedSlow') AS Slow_Txns
FROM
    ModeTransfers
GROUP BY
    1, 2, 3, 4, 5
),
Destination_Volume As (
    SELECT 
    Routers,
    Origin_Bridged_Asset,
    Destination_Domain,
    SUM(Usd_Volume_1d) as usd_volume_1d,
    SUM(Usd_Volume_7d) as usd_volume_7d,
    SUM(Usd_Volume_30d) as usd_volume_30d,
    SUM(Volume_1d) as volume_1d,
    SUM(Volume_7d) as volume_7d,
    SUM(Volume_30d) as volume_30d,
    FROM Volume_metrics
    GROUP BY 1,2,3
),
Destination_fast_Volume As (
    SELECT 
    Routers,
    Origin_Bridged_Asset,
    Destination_Domain,
    SUM(Usd_Volume_1d) as usd_volume_fast_1d,
    SUM(Usd_Volume_7d) as usd_volume_fast_7d,
    SUM(Usd_Volume_30d) as usd_volume_fast_30d,
    SUM(Volume_1d) as volume_fast_1d,
    SUM(Volume_7d) as volume_fast_7d,
    SUM(Volume_30d) as volume_fast_30d,
    FROM Volume_metrics
    WHERE Status = "CompletedFast"
    GROUP BY 1,2,3
),
Combined_metrics AS (
    SELECT *
    FROM
    Destination_Volume dv Left JOIN Destination_fast_Volume dfv ON dv.Routers = dfv.Routers 
    AND dv.Origin_Bridged_Asset = dfv.Origin_Bridged_Asset AND dv.Destination_Domain = dfv.Destination_Domain
),

SELECT * FROM Combined_metrics



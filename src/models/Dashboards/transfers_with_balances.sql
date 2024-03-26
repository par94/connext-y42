SELECT * FROM
{{ ref('transfers_mapped') }} tm LEFT JOIN {{ ref('routers_with_balances_mapped') }} rm ON
tm.`destination_domain` = rm.`domain` AND tm.`destination_transacting_asset` = rm.`adopted`
AND tm.`routers` = rm.`address`

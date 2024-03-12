--with cte as (
 --   select * from {{ this }}
---)
--select * from cte

select * from {{ ref('slippage_historical1') }}
union all
select * from {{ source('slippage_monitoring', 'slippage_monitoring') }}

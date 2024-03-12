--with cte as (
 --   select * from {{ this }}
---)
--select * from cte

select * from {{ ref('slippage_historical') }}
union all
select * from {{ source('slippage_monitoring', 'slippage_monitoring') }}

--INSERT INTO {{ this }}
select *
from {{ this }}

union all
select * from {{ source('slippage_monitoring', 'slippage_monitoring') }}

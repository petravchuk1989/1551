
select [UserId] Id, isnull([LastName], N'')+N' '+isnull([FirstName], N'') name
from [CRM_1551_System].[dbo].[User]
 where 
  #filter_columns#
  --#sort_columns#
  order by 1
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
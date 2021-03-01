select [Id], [name], [execution_term]
  from [dbo].[Assignment_Classes]
  where 
  #filter_columns#
  --#sort_columns#
  order by 1
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
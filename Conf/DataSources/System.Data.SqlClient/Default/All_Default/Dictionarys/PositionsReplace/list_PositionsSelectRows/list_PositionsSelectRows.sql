select Id, ISNULL([name], N'')+ISNULL(N' ('+[position]+N')', N'') [name]
  from [dbo].[Positions]
  where 
  #filter_columns#
  --#sort_columns#
  order by 1
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
  select [Id], [position], [name]
  from   [dbo].[Positions]
 where #filter_columns#
  --#sort_columns#
  order by case when [name] is null then 100500 else id end
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
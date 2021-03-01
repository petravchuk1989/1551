SELECT [Id]
      ,[name]
  FROM [dbo].[Districts]
 where 
  #filter_columns#
  --#sort_columns#
  order by 1
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only

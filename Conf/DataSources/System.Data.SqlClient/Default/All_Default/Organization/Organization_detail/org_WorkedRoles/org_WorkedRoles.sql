SELECT [Id]
      ,[name]
  FROM   [dbo].[Roles]
  where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
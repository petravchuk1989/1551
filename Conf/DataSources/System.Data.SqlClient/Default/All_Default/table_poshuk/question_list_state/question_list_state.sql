SELECT [Id]
      ,[name]
  FROM   [dbo].[Rating]
  where #filter_columns#
  #sort_columns#
  offset @pageOffsetRows rows fetch next @pageLimitRows rows only  
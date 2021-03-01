SELECT [Id]
      ,[name] as [Name]
  FROM   [dbo].[Districts]
  where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
SELECT [Id]
      ,[name]
      ,ltrim([Id])+N'-'+[name] [Idname]
  FROM   [dbo].[Rules]
  where #filter_columns#
  order by id--#sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
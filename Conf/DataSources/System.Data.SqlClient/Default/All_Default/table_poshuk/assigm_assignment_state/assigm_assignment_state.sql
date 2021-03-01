SELECT [Id]
      ,[name]
  FROM   [dbo].[AssignmentStates]
  where #filter_columns#
  #sort_columns#
  offset @pageOffsetRows rows fetch next @pageLimitRows rows only   
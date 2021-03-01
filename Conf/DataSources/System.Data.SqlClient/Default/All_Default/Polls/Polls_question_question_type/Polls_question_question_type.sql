  SELECT [Id]
		,[name]
  FROM   [dbo].[QuestionTypes]
  where id != 1
  and #filter_columns#
  #sort_columns#
  offset @pageOffsetRows rows fetch next @pageLimitRows rows only  
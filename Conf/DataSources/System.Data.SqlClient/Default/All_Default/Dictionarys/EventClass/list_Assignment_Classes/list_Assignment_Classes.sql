select [Id], [Name]
  from [dbo].[Assignment_Classes]
  where 
  #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
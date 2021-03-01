select Id, [Name]
  from [dbo].[Class_Resolutions]
  where 
  #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
 
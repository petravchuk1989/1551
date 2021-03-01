select Id, [emergensy_name] Name
  from [dbo].[Emergensy]
  where 
  #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
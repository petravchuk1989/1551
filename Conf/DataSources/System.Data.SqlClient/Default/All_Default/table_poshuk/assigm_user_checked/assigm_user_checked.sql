  SELECT 
	distinct
	[Workers].[Id],
	[Workers].[name] as user_checked
  FROM   [dbo].[Workers]
  
  inner Join   [dbo].[Roles]
  ON [Workers].roles_id = [Roles].Id
  where [Roles].id in (1,2 )
  and
   #filter_columns#
  #sort_columns#
  offset @pageOffsetRows rows fetch next @pageLimitRows rows only
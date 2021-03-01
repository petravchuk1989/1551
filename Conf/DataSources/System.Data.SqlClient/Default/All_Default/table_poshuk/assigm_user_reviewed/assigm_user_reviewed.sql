SELECT 
	distinct
	[Workers].[Id],
	[Workers].[name] as name_user_reviewed
  FROM   [dbo].[Workers]
  
  inner Join   [dbo].[Roles]
  ON [Workers].roles_id = [Roles].Id
  where [Roles].id in (3,4 )
  and #filter_columns#
  #sort_columns#
  offset @pageOffsetRows rows fetch next @pageLimitRows rows only     
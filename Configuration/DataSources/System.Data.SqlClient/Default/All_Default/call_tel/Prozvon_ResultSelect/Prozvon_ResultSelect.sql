SELECT [Id]
      ,[name]
  FROM [CRM_1551_Analitics].[dbo].[AssignmentResults]
  where #filter_columns# and code in (N'Independently', N'WasExplained', N'Actually', N'Done', N'ClosedAutomatically', N'MissedCall', N'ForWork')
  #sort_columns#
 --offset @pageOffsetRows rows fetch next @pageLimitRows rows only
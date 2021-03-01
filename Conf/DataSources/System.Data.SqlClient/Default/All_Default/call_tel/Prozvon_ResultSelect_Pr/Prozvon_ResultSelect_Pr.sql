SELECT [Id]
      ,[name]
  FROM   [dbo].[AssignmentResults]
  where   code in (N'Independently', N'Actually', N'Done', N'ClosedAutomatically', N'MissedCall', N'ForWork')
  AND #filter_columns#
  #sort_columns#
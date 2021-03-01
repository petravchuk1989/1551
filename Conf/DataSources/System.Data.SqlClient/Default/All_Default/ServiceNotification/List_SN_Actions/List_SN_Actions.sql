SELECT  [Id]
      ,[Name]
  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Actions]
  	where #filter_columns#
     #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
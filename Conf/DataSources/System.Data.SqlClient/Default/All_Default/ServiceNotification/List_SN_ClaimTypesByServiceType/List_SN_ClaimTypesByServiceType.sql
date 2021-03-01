SELECT  [ClaimTypeId] as [Id]
      ,[Name]
  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ClaimTypes]
  	where ServiceTypeId = @ServiceTypeId
      and #filter_columns#
     #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
-- declare @ServiceTypeId int = 14
-- declare @ActionId int = 3


SELECT t1.[Id]
	  ,t2.[Name] as [ClaimTypeName]
    ,t1.[Text]
      ,t1.[Text_without_Executor]
      ,t1.[Text_without_PlanDate]
      ,t1.[Text_without_Executor_PlanDate]
      ,t1.[IsActive]
FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ClaimTypesTexts_ToSend] as t1
inner join [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ClaimTypes] as t2 on t2.ClaimTypeId = t1.ClaimTypeId
left join [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Actions] as t3 on t3.Code = t1.[Action]
where t2.ServiceTypeId = @ServiceTypeId
and t3.Id = @ActionId
and  #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
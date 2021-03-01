
SELECT t1.[Id]
		,t1.ServiceTypeId
		,t3.[Name] as [ServiceTypeName] /*Тип послуги*/
		,t2.Id as [Action]
		,t2.[Name] as [ActionName] /*Нотифікація*/
		,t1.[Title] /*Текст заголовку*/
		,t1.UseClaimTypeTitle
		,t1.[Description] /*Текст опису*/
		,t1.[Description_without_Executor] /*Текст опису без виконавця*/
		,t1.UseClaimTypeDescription
		,t1.[Text]  /*Текст тіла*/
		,t1.[Text_without_Executor]  /*Текст тіла без виконавця*/
		,t1.[Text_without_PlanDate]  /*Текст тіла без планової дати завершення*/
		,t1.[Text_without_Executor_PlanDate]  /*Текст тіла без виконавця та планової дати завершення*/
		,t1.UseClaimTypeText
		,t1.[IsActive]
		-- ,case when t1.[IsActive] = 1 then N'Так' else N'Ні' end as [IsActive]
  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ServiceTypesTexts_ToSend] as t1
  left join [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Actions] as t2 on t2.Code = t1.[Action]
  left join [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ServiceTypes] as t3 on t3.ServiceTypeId = t1.[ServiceTypeId]
	WHERE  t1.[Id] = @Id
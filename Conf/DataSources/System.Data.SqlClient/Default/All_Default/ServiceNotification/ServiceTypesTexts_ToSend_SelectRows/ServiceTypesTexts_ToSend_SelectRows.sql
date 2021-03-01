SELECT t1.[Id]
		,t3.[Name] as [ServiceType] /*Тип послуги*/
		,t2.[Name] as [Actions] /*Нотифікація*/
		,case when t1.[UseClaimTypeTitle] = 0 then t1.[Title] else N'Використовувати з довідника по типам заявок' end as [Title] /*Текст заголовку*/
		,case when t1.[UseClaimTypeDescription] = 0 then t1.[Description] else N'Використовувати з довідника по типам заявок' end as [Description] /*Текст опису*/
		,case when t1.[UseClaimTypeDescription] = 0 then t1.[Description_without_Executor] else N'Використовувати з довідника по типам заявок' end as [Description_without_Executor] /*Текст опису без виконавця*/
		,case when t1.[UseClaimTypeText] = 0 then t1.[Text] else N'Використовувати з довідника по типам заявок' end as [Text]  /*Текст тіла*/
		,case when t1.[UseClaimTypeText] = 0 then t1.[Text_without_Executor] else N'Використовувати з довідника по типам заявок' end as [Text_without_Executor]  /*Текст тіла без виконавця*/
		,case when t1.[UseClaimTypeText] = 0 then t1.[Text_without_PlanDate] else N'Використовувати з довідника по типам заявок' end as [Text_without_PlanDate]  /*Текст тіла без планової дати завершення*/
		,case when t1.[UseClaimTypeText] = 0 then t1.[Text_without_Executor_PlanDate] else N'Використовувати з довідника по типам заявок' end as [Text_without_Executor_PlanDate]  /*Текст тіла без виконавця та планової дати завершення*/
		,t1.[IsActive]
		-- ,case when t1.[IsActive] = 1 then N'Так' else N'Ні' end as [IsActive]
  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ServiceTypesTexts_ToSend] as t1
  left join [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Actions] as t2 on t2.Code = t1.[Action]
  left join [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ServiceTypes] as t3 on t3.ServiceTypeId = t1.[ServiceTypeId]
	WHERE  #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only

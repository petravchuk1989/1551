
select JSON_QUERY((
		select * from (
								  SELECT 
									N'Title' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendTitle],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'
								UNION ALL
								  SELECT 
									N'Description' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendDescription],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'
								UNION ALL
								  SELECT 
									N'DescriptionWithoutExecutor' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendDescriptionWithoutExecutor],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'
								UNION ALL
								  SELECT 
									N'Text' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendText],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'
								UNION ALL
								  SELECT 
									N'TextWithoutExecutor' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendTextWithoutExecutor],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'
								UNION ALL
								  SELECT 
									N'TextWithoutPlanDate' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendTextWithoutPlanDate],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'
								UNION ALL
								  SELECT 
									N'TextWithoutExecutor_PlanDate' as [Code],
									JSON_QUERY(isnull((SELECT [Id], [Code], [Name]
								  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Macroses]
								  WHERE isnull([IsSendTextWithoutExecutor_PlanDate],0) = 1
									ORDER BY [Id]
									FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'Values'

		) as t1
		FOR JSON PATH, INCLUDE_NULL_VALUES
)) as Result
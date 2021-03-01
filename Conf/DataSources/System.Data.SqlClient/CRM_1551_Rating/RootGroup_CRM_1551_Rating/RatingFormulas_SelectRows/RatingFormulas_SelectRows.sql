
SELECT [Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel].[Id]
      ,[Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel].[Date_Start] as [Date_Start]
      ,[RatingFormulas].[name] as [RatingFormulaName]
      ,[Rating].[name] as [RatingName]
      ,[Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel].[comment]
      ,ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'') as [CreatedUserByName]
FROM [dbo].[Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel]
inner join [dbo].[RatingFormulas] on [RatingFormulas].[Id] = [Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel].[formula_id]
inner join [CRM_1551_Analitics].[dbo].[Rating] on [Rating].[Id] = [Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel].[RatingId]
left join [CRM_1551_System].[dbo].[User] on [Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel].[CreatedUserById] = [User].UserId collate Ukrainian_CI_AS
where  #filter_columns#
#sort_columns#
offset @pageOffsetRows rows fetch next @pageLimitRows rows only
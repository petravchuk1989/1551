

--declare @UserId nvarchar(128) = N'29796543-b903-48a6-9399-4840f6eac396' /*Київський міський голова*/
--declare @UserId nvarchar(128) = N'8b98a5ed-70ec-4bbf-b733-911b9b959428' /*Провідний інженер (ЖЕД-201, 206)*/
 --declare @UserId nvarchar(128) = N'4e4953a8-ae98-400a-982d-c122b0632bc0' /*співробітник Org 1800*/
  --declare @UserId nvarchar(128) = N'2d8f8913-76e9-4e0e-a5a8-a3602cc8a559' /*TestMedicina*/
 --declare @OrganizationId int --= 1800




declare @Rating_OrganizationId int
declare @Rating_IsRDA bit


if (
	SELECT count(1)
	FROM [CRM_1551_Analitics].[dbo].[OrganizationInResponsibilityRights]
	where [position_id] in (
			SELECT Id
			FROM [CRM_1551_Analitics].[dbo].[Positions]
			where [programuser_id] = @UserId
	)
	and [organization_id] in (2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009)
	) > 0
begin
	--человек с РДА. 
	set @Rating_IsRDA = 1;

	if @OrganizationId is null
	begin
		--Если пользователь находится в орг РДА ([OrganizationInResponsibilityRights]) и НЕ дает организацию во входящий параметр то информацию только с Rating_ResultTable (по организации топ 1 из [OrganizationInResponsibilityRights])
		set @Rating_OrganizationId = (SELECT top 1 [organization_id]
								FROM [CRM_1551_Analitics].[dbo].[OrganizationInResponsibilityRights] with (nolock)
								where [position_id] in (
										SELECT Id
										FROM [CRM_1551_Analitics].[dbo].[Positions] with (nolock)
										where [programuser_id] = @UserId
								)
								and [organization_id] in (2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009))
	end
	else
	begin
		--Если пользователь находится в орг РДА ([OrganizationInResponsibilityRights]) и дает организацию во входящий параметр то информацию только с Rating_ResultTable (по организации из параметра но проверяем правами таблицы OrganizationInResponsibilityRights)
		set @Rating_OrganizationId = (SELECT top 1 [organization_id]
								FROM [CRM_1551_Analitics].[dbo].[OrganizationInResponsibilityRights] with (nolock)
								where [position_id] in (
										SELECT Id
										FROM [CRM_1551_Analitics].[dbo].[Positions] with (nolock)
										where [programuser_id] = @UserId
								)
								and [organization_id] = @OrganizationId)
	end
end
else
begin
	--человек Не с РДА. 
	set @Rating_IsRDA = 0;

	if @OrganizationId is null
	begin
		--Если человек НЕ с РДА и НЕ дает орг ид (к пример 10) то показываем информацию с Rating_ResultTable_ByOrganization + Department_ResultTable по организации из его позиции Positions и перепроверить через OrganizationInResponsibilityRights
		set @Rating_OrganizationId = (SELECT top 1 [organization_id]
										FROM [CRM_1551_Analitics].[dbo].[OrganizationInResponsibilityRights] with (nolock)
										inner join [CRM_1551_Analitics].[dbo].[Positions]  with (nolock) on [Positions].Id = [OrganizationInResponsibilityRights].position_id and [Positions].organizations_id = [OrganizationInResponsibilityRights].organization_id and [Positions].[programuser_id] = @UserId
										)
	end
	else
	begin
		--Если человек НЕ с РДА и дает орг ид (к пример 12) то показываем информацию с Rating_ResultTable_ByOrganization + Department_ResultTable по организации из входящего параметра и перепроверить через OrganizationInResponsibilityRights
		set @Rating_OrganizationId = (SELECT top 1 [organization_id]
										FROM [CRM_1551_Analitics].[dbo].[OrganizationInResponsibilityRights] with (nolock)
										inner join [CRM_1551_Analitics].[dbo].[Positions] with (nolock) on [Positions].Id = [OrganizationInResponsibilityRights].position_id and [Positions].organizations_id = [OrganizationInResponsibilityRights].organization_id and [Positions].[programuser_id] = @UserId
										where [OrganizationInResponsibilityRights].[organization_id] = @OrganizationId)
	end
end



----------------------------------
--Generate list RDA Organizations
if object_id('tempdb..#temp_ListOrg') is not null drop table #temp_ListOrg
create table #temp_ListOrg(
OrgParentId int,
OrgName nvarchar(500),
OrgId int
)

declare @Org nvarchar(max)
declare @sql_RDA nvarchar(max)
/*Голосіївська РДА*/
set @Org = (SELECT [Organizations] FROM [CRM_1551_Analitics].[dbo].[OrganizationsAndParent] where ParentId =  @Rating_OrganizationId)
set @sql_RDA = N'SELECT '+rtrim(@Rating_OrganizationId)+N' as [ParentId], [Organizations].[short_name], [Organizations].[Id] FROM [CRM_1551_Analitics].[dbo].[Organizations] where [Organizations].Id in ('+@Org+N')'
insert into #temp_ListOrg ([OrgParentId], [OrgName], [OrgId])
exec sp_executesql @sql_RDA;

--select * from #temp_ListOrg order by [OrgId]
----------------------------------	



--select @Rating_OrganizationId, @Rating_IsRDA

if object_id('tempdb..#temp_HistryRating') is not null drop table #temp_HistryRating
create table #temp_HistryRating(
	[DateCalc] date,
	RatingId int,
	OrganizationId int,
	OrganizationName  nvarchar(500),
	[IntegratedMetric_PerformanceLevel] numeric(18,6),
	[PercentClosedOnTime] numeric(18,6),
	[PercentOfExecution] numeric(18,6),
	[PercentOnVeracity] numeric(18,6),
	[IndexOfSpeedToExecution] numeric(18,6),
	[IndexOfSpeedToExplain] numeric(18,6),
	[IndexOfFactToExecution] numeric(18,6),
	[PercentPleasureOfExecution] numeric(18,6),
)

if object_id('tempdb..#temp_HistryRatingDep') is not null drop table #temp_HistryRatingDep
create table #temp_HistryRatingDep(
	[DateCalc] date,
	RatingId int,
	OrganizationId int,
	OrganizationName  nvarchar(500),
	[vids_vz] numeric(18,2),
	[count_rzvv] int,
	[count_rzvnv] int,
	[count_rzvp] int
)



if @Rating_IsRDA = 1
begin

insert into #temp_HistryRating ([DateCalc],
								[RatingId],
								[OrganizationId],
								[OrganizationName],
								[IntegratedMetric_PerformanceLevel],
								[PercentClosedOnTime],
								[PercentOfExecution],
								[PercentOnVeracity],
								[IndexOfSpeedToExecution],
								[IndexOfSpeedToExplain],
								[IndexOfFactToExecution],
								[PercentPleasureOfExecution])
SELECT	 t1.[DateCalc]
		,t1.[RatingId]
		,t1.[RDAId] as [OrganizationId]
		,[Organizations].[short_name] as [OrganizationName]
		,t1.[IntegratedMetric_PerformanceLevel]
		,t1.[PercentClosedOnTime]
		,t1.[PercentOfExecution]
		,t1.[PercentOnVeracity]
		,t1.[IndexOfSpeedToExecution]
		,t1.[IndexOfSpeedToExplain]
		,t1.[IndexOfFactToExecution]
		,t1.[PercentPleasureOfExecution]
FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable] as t1 with (nolock)
left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.[RDAId]
where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc <= cast(getdate() as date)
and t1.RDAId = @Rating_OrganizationId 

select  JSON_QUERY((
		select   t.Rating as RatingName
				,t.RatingId
				,t.DateCalc
				,t.[IntegratedMetric_PerformanceLevel] as 'ResultMetric.CurrentValue'
				,(SELECT t1.[DateCalc]
							,t1.[IntegratedMetric_PerformanceLevel] as [Value]
							FROM #temp_HistryRating as t1 with (nolock)
							where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
							and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
							order by t1.[DateCalc]
							FOR JSON PATH, INCLUDE_NULL_VALUES) as 'ResultMetric.History'
				,JSON_QUERY(isnull((SELECT top 10 
							[Organizations].Id as [OrganizationId]
							,[Organizations].short_name as [OrganizationName]
							,t1.[IntegratedMetric_PerformanceLevel] as [Value]
							FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
							left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
							where t1.DateCalc = cast(getdate() as date)
							and t1.RatingId = t.RatingId
							and t1.[IntegratedMetric_PerformanceLevel] is not null
							and isnull(t1.[IntegratedMetric_PerformanceLevel],0) < 100
							and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
							order by isnull(t1.[IntegratedMetric_PerformanceLevel],0)
							FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'ResultMetric.TOP10'
		,'OtherIndicators' = (
					SELECT  t2.[CurrentValue]
						   ,t2.[Name]
						   ,t2.[Code]
						   ,JSON_QUERY(t2.[History]) as 'History'
						   ,JSON_QUERY(t2.[TOP10]) as 'TOP10'
					FROM (
							SELECT t.[PercentClosedOnTime] as 'CurrentValue'
								   ,N'% вчасно закритих' as 'Name'
								   ,N'PercentClosedOnTime' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentClosedOnTime] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentClosedOnTime] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentClosedOnTime] is not null
										and isnull(t1.[PercentClosedOnTime],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentClosedOnTime],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[PercentOfExecution] as 'CurrentValue'
								   ,N'% Виконання звернень' as 'Name'
								   ,N'PercentOfExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentOfExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentOfExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentOfExecution] is not null
										and isnull(t1.[PercentOfExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentOfExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[PercentOnVeracity] as 'CurrentValue'
								   ,N'% Достовірності виконання' as 'Name'
								   ,N'PercentOnVeracity' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentOnVeracity] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentOnVeracity] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentOnVeracity] is not null
										and isnull(t1.[PercentOnVeracity],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentOnVeracity],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[IndexOfSpeedToExecution] as 'CurrentValue'
								   ,N'Індекс швидкості виконання' as 'Name'
								   ,N'IndexOfSpeedToExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[IndexOfSpeedToExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[IndexOfSpeedToExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[IndexOfSpeedToExecution] is not null
										and isnull(t1.[IndexOfSpeedToExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[IndexOfSpeedToExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[IndexOfSpeedToExplain] as 'CurrentValue'
								   ,N'Індекс швидкості роз`яснення' as 'Name'
								   ,N'IndexOfSpeedToExplain' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[IndexOfSpeedToExplain] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[IndexOfSpeedToExplain] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[IndexOfSpeedToExplain] is not null
										and isnull(t1.[IndexOfSpeedToExplain],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[IndexOfSpeedToExplain],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[IndexOfFactToExecution] as 'CurrentValue'
								   ,N'Індекс фактичного виконання' as 'Name'
								   ,N'IndexOfFactToExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[IndexOfFactToExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[IndexOfFactToExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[IndexOfFactToExecution] is not null
										and isnull(t1.[IndexOfFactToExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[IndexOfFactToExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[PercentPleasureOfExecution] as 'CurrentValue'
								   ,N'% Задоволеності виконанням' as 'Name'
								   ,N'PercentPleasureOfExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentPleasureOfExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentPleasureOfExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentPleasureOfExecution] is not null
										and isnull(t1.[PercentPleasureOfExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentPleasureOfExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'		
					) t2
					FOR JSON PATH, INCLUDE_NULL_VALUES		
					)
		from (
			SELECT N'ЖКХ' as [Rating]
				  ,t1.RatingId
				  ,t1.DateCalc
				  ,t1.[PercentClosedOnTime]
				  ,t1.[PercentOfExecution]
				  ,t1.[PercentOnVeracity]
				  ,t1.[IndexOfSpeedToExecution]
				  ,t1.[IndexOfSpeedToExplain]
				  ,t1.[IndexOfFactToExecution]
				  ,t1.[PercentPleasureOfExecution]
				  ,t1.[IntegratedMetric_PerformanceLevel]
			  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable] as t1 with (nolock)
			  where t1.DateCalc = cast(getdate() as date)
			  and t1.RDAId = @Rating_OrganizationId and t1.RatingId = 1
			UNION ALL
			SELECT N'Благоустрій' as [Rating]
				  ,t1.RatingId
				  ,t1.DateCalc
				  ,t1.[PercentClosedOnTime]
				  ,t1.[PercentOfExecution]
				  ,t1.[PercentOnVeracity]
				  ,t1.[IndexOfSpeedToExecution]
				  ,t1.[IndexOfSpeedToExplain]
				  ,t1.[IndexOfFactToExecution]
				  ,t1.[PercentPleasureOfExecution]
				  ,t1.[IntegratedMetric_PerformanceLevel]
			  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable] as t1 with (nolock)
			  where t1.DateCalc = cast(getdate() as date)
			  and t1.RDAId = @Rating_OrganizationId and t1.RatingId = 2
			UNION ALL
			SELECT N'Життєдіяльність району' as [Rating]
				  ,t1.RatingId
				  ,t1.DateCalc
				  ,t1.[PercentClosedOnTime]
				  ,t1.[PercentOfExecution]
				  ,t1.[PercentOnVeracity]
				  ,t1.[IndexOfSpeedToExecution]
				  ,t1.[IndexOfSpeedToExplain]
				  ,t1.[IndexOfFactToExecution]
				  ,t1.[PercentPleasureOfExecution]
				  ,t1.[IntegratedMetric_PerformanceLevel]
			  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable] as t1 with (nolock)
			  where t1.DateCalc = cast(getdate() as date)
			  and t1.RDAId = @Rating_OrganizationId and t1.RatingId = 3
		) as t
		FOR JSON PATH, INCLUDE_NULL_VALUES
		)) as Result
end



if @Rating_IsRDA = 0 and (SELECT count(1)
						FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
						where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc <= cast(getdate() as date)
						and t1.OrganizationId = @Rating_OrganizationId ) > 0
begin
insert into #temp_HistryRating ([DateCalc],
								[RatingId],
								[OrganizationId],
								[OrganizationName],
								[IntegratedMetric_PerformanceLevel],
								[PercentClosedOnTime],
								[PercentOfExecution],
								[PercentOnVeracity],
								[IndexOfSpeedToExecution],
								[IndexOfSpeedToExplain],
								[IndexOfFactToExecution],
								[PercentPleasureOfExecution])
SELECT	 t1.[DateCalc]
		,t1.[RatingId]
		,t1.[OrganizationId]
		,[Organizations].[short_name] as [OrganizationName]
		,t1.[IntegratedMetric_PerformanceLevel]
		,t1.[PercentClosedOnTime]
		,t1.[PercentOfExecution]
		,t1.[PercentOnVeracity]
		,t1.[IndexOfSpeedToExecution]
		,t1.[IndexOfSpeedToExplain]
		,t1.[IndexOfFactToExecution]
		,t1.[PercentPleasureOfExecution]
FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.[OrganizationId]
where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc <= cast(getdate() as date)
and t1.OrganizationId = @Rating_OrganizationId 

select  JSON_QUERY((
		select   t.Rating as RatingName
				,t.RatingId
				,t.DateCalc
				,t.[IntegratedMetric_PerformanceLevel] as 'ResultMetric.CurrentValue'
				,(SELECT t1.[DateCalc]
							,t1.[IntegratedMetric_PerformanceLevel] as [Value]
							FROM #temp_HistryRating as t1
							where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
							and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
							order by t1.[DateCalc]
							FOR JSON PATH, INCLUDE_NULL_VALUES) as 'ResultMetric.History'
				,JSON_QUERY(isnull((SELECT top 10 
							[Organizations].Id as [OrganizationId]
							,[Organizations].short_name as [OrganizationName]
							,t1.[IntegratedMetric_PerformanceLevel] as [Value]
							FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
							left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
							where t1.DateCalc = cast(getdate() as date)
							and t1.RatingId = t.RatingId
							and t1.[IntegratedMetric_PerformanceLevel] is not null
							and isnull(t1.[IntegratedMetric_PerformanceLevel],0) < 100
							and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
							order by isnull(t1.[IntegratedMetric_PerformanceLevel],0)
							FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'ResultMetric.TOP10'
		,'OtherIndicators' = (
					SELECT  t2.[CurrentValue]
						   ,t2.[Name]
						   ,t2.[Code]
						   ,JSON_QUERY(t2.[History]) as 'History'
						   ,JSON_QUERY(t2.[TOP10]) as 'TOP10'
					FROM (
							SELECT t.[PercentClosedOnTime] as 'CurrentValue'
								   ,N'% вчасно закритих' as 'Name'
								   ,N'PercentClosedOnTime' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentClosedOnTime] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentClosedOnTime] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentClosedOnTime] is not null
										and isnull(t1.[PercentClosedOnTime],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentClosedOnTime],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[PercentOfExecution] as 'CurrentValue'
								   ,N'% Виконання звернень' as 'Name'
								   ,N'PercentOfExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentOfExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentOfExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentOfExecution] is not null
										and isnull(t1.[PercentOfExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentOfExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[PercentOnVeracity] as 'CurrentValue'
								   ,N'% Достовірності виконання' as 'Name'
								   ,N'PercentOnVeracity' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentOnVeracity] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentOnVeracity] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentOnVeracity] is not null
										and isnull(t1.[PercentOnVeracity],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentOnVeracity],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[IndexOfSpeedToExecution] as 'CurrentValue'
								   ,N'Індекс швидкості виконання' as 'Name'
								   ,N'IndexOfSpeedToExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[IndexOfSpeedToExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[IndexOfSpeedToExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[IndexOfSpeedToExecution] is not null
										and isnull(t1.[IndexOfSpeedToExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[IndexOfSpeedToExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[IndexOfSpeedToExplain] as 'CurrentValue'
								   ,N'Індекс швидкості роз`яснення' as 'Name'
								   ,N'IndexOfSpeedToExplain' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[IndexOfSpeedToExplain] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[IndexOfSpeedToExplain] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[IndexOfSpeedToExplain] is not null
										and isnull(t1.[IndexOfSpeedToExplain],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[IndexOfSpeedToExplain],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[IndexOfFactToExecution] as 'CurrentValue'
								   ,N'Індекс фактичного виконання' as 'Name'
								   ,N'IndexOfFactToExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[IndexOfFactToExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[IndexOfFactToExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[IndexOfFactToExecution] is not null
										and isnull(t1.[IndexOfFactToExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[IndexOfFactToExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[PercentPleasureOfExecution] as 'CurrentValue'
								   ,N'% Задоволеності виконанням' as 'Name'
								   ,N'PercentPleasureOfExecution' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[PercentPleasureOfExecution] as [Value]
												FROM  #temp_HistryRating as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = t.RatingId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[PercentPleasureOfExecution] as [Value]
										FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.OrganizationId
										where t1.DateCalc = cast(getdate() as date)
										and t1.RatingId = t.RatingId
										and t1.[PercentPleasureOfExecution] is not null
										and isnull(t1.[PercentPleasureOfExecution],0) < 100
										and t1.OrganizationId in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[PercentPleasureOfExecution],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'		
					) t2
					FOR JSON PATH, INCLUDE_NULL_VALUES		
					)
		from (
			SELECT N'ЖКХ' as [Rating]
				  ,t1.RatingId
				  ,t1.DateCalc
				  ,t1.[PercentClosedOnTime]
				  ,t1.[PercentOfExecution]
				  ,t1.[PercentOnVeracity]
				  ,t1.[IndexOfSpeedToExecution]
				  ,t1.[IndexOfSpeedToExplain]
				  ,t1.[IndexOfFactToExecution]
				  ,t1.[PercentPleasureOfExecution]
				  ,t1.[IntegratedMetric_PerformanceLevel]
			  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
			  where t1.DateCalc = cast(getdate() as date)
			  and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = 1
			UNION ALL
			SELECT N'Благоустрій' as [Rating]
				  ,t1.RatingId
				  ,t1.DateCalc
				  ,t1.[PercentClosedOnTime]
				  ,t1.[PercentOfExecution]
				  ,t1.[PercentOnVeracity]
				  ,t1.[IndexOfSpeedToExecution]
				  ,t1.[IndexOfSpeedToExplain]
				  ,t1.[IndexOfFactToExecution]
				  ,t1.[PercentPleasureOfExecution]
				  ,t1.[IntegratedMetric_PerformanceLevel]
			  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
			  where t1.DateCalc = cast(getdate() as date)
			  and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = 2
			UNION ALL
			SELECT N'Життєдіяльність району' as [Rating]
				  ,t1.RatingId
				  ,t1.DateCalc
				  ,t1.[PercentClosedOnTime]
				  ,t1.[PercentOfExecution]
				  ,t1.[PercentOnVeracity]
				  ,t1.[IndexOfSpeedToExecution]
				  ,t1.[IndexOfSpeedToExplain]
				  ,t1.[IndexOfFactToExecution]
				  ,t1.[PercentPleasureOfExecution]
				  ,t1.[IntegratedMetric_PerformanceLevel]
			  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
			  where t1.DateCalc = cast(getdate() as date)
			  and t1.OrganizationId = @Rating_OrganizationId and t1.RatingId = 3
		) as t
		FOR JSON PATH, INCLUDE_NULL_VALUES
		)) as Result
end



if @Rating_IsRDA = 0 and (SELECT count(1)
						FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
						where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc <= cast(getdate() as date)
						and t1.OrganizationId = @Rating_OrganizationId ) = 0
					and (SELECT count(1)
						FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
						where dateadd(day,1,t1.StateToDate) >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.StateToDate <= cast(getdate() as date)
						and t1.Organization_Id = @Rating_OrganizationId ) > 0
begin
insert into #temp_HistryRatingDep ([DateCalc],
								[OrganizationId],
								[OrganizationName],
								[vids_vz],
								[count_rzvv],
								[count_rzvnv],
								[count_rzvp])
SELECT	 dateadd(day,1,t1.StateToDate) as [DateCalc]
		,t1.[Organization_Id]
		,[Organizations].[short_name] as [OrganizationName]
		,t1.[vids_vz]
		,t1.[count_rzvv]
		,t1.[count_rzvnv]
		,t1.[count_rzvp]
FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.[Organization_Id]
where dateadd(day,1,t1.StateToDate) >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and dateadd(day,1,t1.StateToDate) <= cast(getdate() as date)
and t1.Organization_Id = @Rating_OrganizationId 

select  JSON_QUERY((
		select   t.Rating as RatingName
				,t.RatingId
				,t.DateCalc
				,t.[vids_vz] as 'ResultMetric.CurrentValue'
				,(SELECT t1.[DateCalc]
							,t1.[vids_vz] as [Value]
							FROM #temp_HistryRatingDep as t1
							where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
							and t1.OrganizationId = @Rating_OrganizationId
							order by t1.[DateCalc]
							FOR JSON PATH, INCLUDE_NULL_VALUES) as 'ResultMetric.History'
				,JSON_QUERY(isnull((SELECT top 10 
							[Organizations].Id as [OrganizationId]
							,[Organizations].short_name as [OrganizationName]
							,t1.[vids_vz] as [Value]
							FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
							left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.Organization_Id
							where dateadd(day,1,t1.StateToDate) = cast(getdate() as date)
							and t1.[vids_vz] is not null
							and isnull(t1.[vids_vz],0) < 100
							and t1.Organization_Id in (select [OrgId] from #temp_ListOrg)
							order by isnull(t1.[vids_vz],0)
							FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'ResultMetric.TOP10'
		,'OtherIndicators' = (
					SELECT  t2.[CurrentValue]
						   ,t2.[Name]
						   ,t2.[Code]
						   ,JSON_QUERY(t2.[History]) as 'History'
						   ,JSON_QUERY(t2.[TOP10]) as 'TOP10'
					FROM (
							
							SELECT t.count_rzvv as 'CurrentValue'
								   ,N'Вчасно' as 'Name'
								   ,N'count_rzvv' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[count_rzvv] as [Value]
												FROM  #temp_HistryRatingDep as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[count_rzvv] as [Value]
										FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.Organization_Id
										where dateadd(day,1,t1.StateToDate) = cast(getdate() as date)
										and t1.[count_rzvv] is not null
										and isnull(t1.[count_rzvv],0) < 100
										and t1.Organization_Id in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[count_rzvv],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.count_rzvnv as 'CurrentValue'
								   ,N'Невчасно' as 'Name'
								   ,N'count_rzvnv' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[count_rzvnv] as [Value]
												FROM  #temp_HistryRatingDep as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[count_rzvnv] as [Value]
										FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.Organization_Id
										where dateadd(day,1,t1.StateToDate) = cast(getdate() as date)
										and t1.[count_rzvnv] is not null
										and isnull(t1.[count_rzvnv],0) < 100
										and t1.Organization_Id in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[count_rzvnv],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'	
							UNION ALL
							SELECT t.[count_rzvp] as 'CurrentValue'
								   ,N'Протерміновано' as 'Name'
								   ,N'count_rzvp' as 'Code'
								   ,JSON_QUERY((SELECT t1.[DateCalc]
												,t1.[count_rzvp] as [Value]
												FROM  #temp_HistryRatingDep as t1
												where t1.DateCalc >= dateadd(month, -1, cast(left(rtrim(cast(getdate() as date)),8)+N'02' as date)) and t1.DateCalc < cast(getdate() as date)
												and t1.OrganizationId = @Rating_OrganizationId
												order by t1.[DateCalc] FOR JSON PATH, INCLUDE_NULL_VALUES)) as 'History'
									,JSON_QUERY(isnull((SELECT top 10 
										[Organizations].Id as [OrganizationId]
										,[Organizations].short_name as [OrganizationName]
										,t1.[count_rzvp] as [Value]
										FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
										left join [CRM_1551_Analitics].[dbo].[Organizations] with (nolock) on [Organizations].Id = t1.Organization_Id
										where dateadd(day,1,t1.StateToDate) = cast(getdate() as date)
										and t1.[count_rzvp] is not null
										and isnull(t1.[count_rzvp],0) < 100
										and t1.Organization_Id in (select [OrgId] from #temp_ListOrg)
										order by isnull(t1.[count_rzvp],0) FOR JSON PATH, INCLUDE_NULL_VALUES),N'[]')) as 'TOP10'			
					) t2
					FOR JSON PATH, INCLUDE_NULL_VALUES		
					)
		from (
			SELECT N'Департамент' as [Rating]
				  ,4 as RatingId
				  ,dateadd(day,1,t1.StateToDate) as DateCalc
				  ,t1.[vids_vz]
		,t1.[count_rzvv]
		,t1.[count_rzvnv]
		,t1.[count_rzvp]
			  FROM [CRM_1551_Rating_Department].[dbo].[Department_ResultTable] as t1 with (nolock)
			  where dateadd(day,1,t1.StateToDate) = cast(getdate() as date)
			  and t1.Organization_Id = @Rating_OrganizationId
		) as t
		FOR JSON PATH, INCLUDE_NULL_VALUES
		)) as Result
end
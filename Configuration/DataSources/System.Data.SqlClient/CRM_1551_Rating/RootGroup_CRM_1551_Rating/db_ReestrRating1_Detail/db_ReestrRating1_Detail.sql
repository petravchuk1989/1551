--declare @DateCalc date = N'2019-11-21', @RDAId int = 0, @RatingId int = 1


SELECT t1.[Id]
      ,t1.[DateCalc]
      ,t1.[Date_Start]
      ,t1.[Date_End]
      ,t1.[RatingId]
      ,t2.[Id] as [OrgId]
      ,t2.[short_name] as [OrgName]
      ,t1.[PreviousPeriod_Total]
      ,t1.[PreviousPeriod_Registered]
      ,t1.[PreviousPeriod_InTheWorks]
      ,t1.[PreviousPeriod_InTest]
      ,t1.[PreviousPeriod_ForRevision]
      ,t1.[PreviousPeriod_Closed]
      ,t1.[CurrentMonth_Total]
      ,t1.[CurrentMonth_Registered]
      ,t1.[CurrentMonth_InTheWorks]
      ,t1.[CurrentMonth_InTest]
      ,t1.[CurrentMonth_ForRevision]
      ,t1.[CurrentMonth_Closed]
      ,t1.[OfThem_Registered]
      ,t1.[OfThem_AtWork]
      ,t1.[OnTest_Done]
      ,t1.[OnTest_Explained]
      ,t1.[OnTest_CannotBeExecutedAtThisTime]
      ,t1.[ResultOfExecution_Done]
      ,t1.[ResultOfExecution_Explained]
      ,t1.[ResultOfExecution_Others]
      ,t1.[ForRevision_All]
      ,t1.[ForRevision_Total]
      ,t1.[ForRevision_1Time]
      ,t1.[ForRevision_2Times]
      ,t1.[ForRevision_3AndMore]
      ,t1.[ViewedByArtist_Total]
      ,t1.[ViewedByArtist_WrongTime]
      ,t1.[PercentClosedOnTime]
      ,t1.[PercentOfExecution]
      ,t1.[PercentOnVeracity]
      ,t1.[IndexOfSpeedToExecution]
      ,t1.[IndexOfSpeedToExplain]
      ,t1.[IndexOfFactToExecution]
      ,t1.[PercentPleasureOfExecution]
      ,t1.[IntegratedMetric_PerformanceLevel]
  FROM [dbo].[Rating_ResultTable_ByOrganization] as t1 with (nolock)
  left join [CRM_1551_Analitics].[dbo].[Organizations] as t2  with (nolock) on t2.Id = t1.OrganizationId 
  where t1.[DateCalc] = @DateCalc
  and t1.[RatingId] = @RatingId
  and (t1.[RDAId] = @RDAId or isnull(@RDAId,0) = 0)
  and [RDAId] @GlobalFilter_RDAId
  and (t1.[PreviousPeriod_Total]
      +t1.[PreviousPeriod_Registered]
      +t1.[PreviousPeriod_InTheWorks]
      +t1.[PreviousPeriod_InTest]
      +t1.[PreviousPeriod_ForRevision]
      +t1.[PreviousPeriod_Closed]
      +t1.[CurrentMonth_Total]
      +t1.[CurrentMonth_Registered]
      +t1.[CurrentMonth_InTheWorks]
      +t1.[CurrentMonth_InTest]
      +t1.[CurrentMonth_ForRevision]
      +t1.[CurrentMonth_Closed]
      +t1.[OfThem_Registered]
      +t1.[OfThem_AtWork]
      +t1.[OnTest_Done]
      +t1.[OnTest_Explained]
      +t1.[OnTest_CannotBeExecutedAtThisTime]
      +t1.[ResultOfExecution_Done]
      +t1.[ResultOfExecution_Explained]
      +t1.[ResultOfExecution_Others]
      +t1.[ForRevision_All]
      +t1.[ForRevision_Total]
      +t1.[ForRevision_1Time]
      +t1.[ForRevision_2Times]
      +t1.[ForRevision_3AndMore]
      +t1.[ViewedByArtist_Total]
      +t1.[ViewedByArtist_WrongTime]) > 0

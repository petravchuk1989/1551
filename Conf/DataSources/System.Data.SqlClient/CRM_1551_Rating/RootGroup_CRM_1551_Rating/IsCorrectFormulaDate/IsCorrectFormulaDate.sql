SELECT count(1) as Result     
FROM [dbo].[Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel]
where  [Date_Start] = dateadd(day,1,cast(@Date as date))
and [RatingId] = @RatingId

-- declare  @DateCalc date = N'2019-11-01' 
-- ,@RatingId int = 1
-- ,@RDAId int = 2000


if isnull(@RDAId,0) = 0
begin 
	SELECT [2000],[2001],[2002],[2003],[2004],[2005],[2006],[2007],[2008],[2009]
			 FROM ( select * from (
								  SELECT [RDAId],
								   IndexOfSpeedToExecution as [Value]
							  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable]
							  where [RDAId] is not null
							  and [RatingId] = @RatingId
							  and [DateCalc] = @DateCalc
	) as Table123) x
			 PIVOT
			 (MIN([Value])
			 FOR RDAId
			 IN([2000],[2001],[2002],[2003],[2004],[2005],[2006],[2007],[2008],[2009])
	 ) pvt
	 where isnull(pvt.[2000],0)+isnull(pvt.[2001],0)+isnull(pvt.[2002],0)+isnull(pvt.[2003],0)+isnull(pvt.[2004],0)+isnull(pvt.[2005],0)+isnull(pvt.[2006],0)+isnull(pvt.[2007],0)+isnull(pvt.[2008],0)+isnull(pvt.[2009],0) > 0
/*
	 UNION ALL 
	 SELECT  [2000],[2001],[2002],[2003],[2004],[2005],[2006],[2007],[2008],[2009]
			 FROM ( select * from (
								  SELECT [RDAId],
								   cast([Execution_Place] as numeric(18,2)) as [Value]
							  FROM [CRM_1551_Rating].[dbo].[Rating_DaysToExecution]
							  where [RDAId] is not null
							  and [RatingId] = @RatingId
							  and [DateCalc] = @DateCalc
	) as Table123) x
			 PIVOT
			 (AVG([Value])
			 FOR RDAId
			 IN([2000],[2001],[2002],[2003],[2004],[2005],[2006],[2007],[2008],[2009])
	 ) pvt
	 where isnull(pvt.[2000],0)+isnull(pvt.[2001],0)+isnull(pvt.[2002],0)+isnull(pvt.[2003],0)+isnull(pvt.[2004],0)+isnull(pvt.[2005],0)+isnull(pvt.[2006],0)+isnull(pvt.[2007],0)+isnull(pvt.[2008],0)+isnull(pvt.[2009],0) > 0
*/
end
else 
begin
	if object_id('tempdb..##temp_RatingResultData') is not null drop table ##temp_RatingResultData
	--if object_id('tempdb..##temp_RatingResultData2') is not null drop table ##temp_RatingResultData2

	declare @Col nvarchar(10) = rtrim(@RDAId)
	select * 
	into ##temp_RatingResultData
	from (
								  SELECT 
								   IndexOfSpeedToExecution as [Value]
							  FROM [CRM_1551_Rating].[dbo].[Rating_ResultTable]
							  where [RDAId] is not null
							  and [RatingId] = @RatingId
							  and [DateCalc] = @DateCalc
							  and [RDAId] = @RDAId
	) as Table123

	/*select * 
	into ##temp_RatingResultData2
	from (
							SELECT AVG(cast([Execution_Place] as numeric(18,2))) as [Value]
							  FROM [CRM_1551_Rating].[dbo].[Rating_DaysToExecution]
							  where [RDAId] is not null
							  and [RatingId] = @RatingId
							  and [DateCalc] = @DateCalc
							  and [RDAId] = @RDAId
							  and [Execution_Place] is not null
							group by [RDAId]
	) as Table123*/

	EXEC tempdb.sys.sp_rename N'##temp_RatingResultData.Value', @Col, N'COLUMN';
	--EXEC tempdb.sys.sp_rename N'##temp_RatingResultData2.Value', @Col, N'COLUMN';

	select *
	from ##temp_RatingResultData
	/*UNION ALL
	select *
	from ##temp_RatingResultData2*/
end
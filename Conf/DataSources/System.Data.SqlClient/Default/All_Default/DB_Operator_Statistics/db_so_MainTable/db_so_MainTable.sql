/*
DECLARE @date_from DATE='2020-10-01',
		@date_to DATE = GETDATE(),
		@organizations_Id NVARCHAR(200) = NULL
		 --N'1761, 1760';
*/

DECLARE @CallWay NVARCHAR(max) = (SELECT TOP 1 N'[' + [IP] + N'].' + N'[' + [DatabaseName] + N'].' FROM [dbo].[SetingConnetDatabase] WHERE [Code] = N'CallWayData');
DECLARE @date_from_t NVARCHAR(max) = CONVERT(DATE, CONVERT(DATE, @date_from)); 
DECLARE @date_to_t NVARCHAR(max) = CONVERT(DATE, CONVERT(DATE, @date_to));
IF OBJECT_ID('tempdb..#temp_CallStatistic') IS NOT NULL 
BEGIN
   DROP TABLE #temp_CallStatistic;
END

CREATE TABLE #temp_CallStatistic ([Id] INT, 
                                  [TalkTime] INT, 
                                  [OperatorCrm_Phone] NVARCHAR(50) COLLATE Ukrainian_CI_AS)
                                  WITH (DATA_COMPRESSION = PAGE);

DECLARE @oqcall_s NVARCHAR(max) = N'
select 
	[CallStatistic].Id CallStatistic_Id, 
	[CallStatistic].[TalkTime] CallStatistic_TalkTime, 
	[OperatorCrm].Phone COLLATE Ukrainian_CI_AS
from '+@CallWay+N'[dbo].[CallStatistic] 
inner join '+@CallWay+N'[dbo].[CallOperator] on [CallStatistic].Id=[CallOperator].CallStatisticId
inner join '+@CallWay+N'[dbo].[OperatorCrm] on [CallOperator].OperatorId=[OperatorCrm].Id
where convert(date, [CallStatistic].StartDate) between ''' + @date_from_t + N''' and ''' + @date_to_t + N'''';
--select @oqcall_s

INSERT INTO
   #temp_CallStatistic (Id, [TalkTime], OperatorCrm_Phone)
   EXEC (@oqcall_s);

IF OBJECT_ID('tempdb..#temp_CallSipChannel') IS NOT NULL 
BEGIN
   DROP TABLE #temp_CallSipChannel;
 END  
 CREATE TABLE #temp_CallSipChannel (SipCallId NVARCHAR(100) COLLATE Ukrainian_CI_AS,
                                    TalkTime INT)
                                    WITH (DATA_COMPRESSION = PAGE);
DECLARE @oqcall_csc NVARCHAR(max) = N'
select 
	[CallSipChannel].SipCallId COLLATE Ukrainian_CI_AS SipCallId,
	[CallStatistic].[TalkTime]
from '+@CallWay+N'[dbo].[CallSipChannel]
inner join '+@CallWay+N'[dbo].[CallStatistic] on [CallSipChannel].CallStatisticId=[CallStatistic].Id
where convert(date, [CallStatistic].StartDate) between ''' + @date_from_t + N''' and ''' + @date_to_t + N''''; 
--select @oqcall_csc

INSERT INTO
   #temp_CallSipChannel (SipCallId, TalkTime)
   EXEC (@oqcall_csc); 
IF OBJECT_ID('tempdb..#temp_positions_table') IS NOT NULL 
BEGIN
   DROP TABLE #temp_positions_table;
END   
CREATE TABLE #temp_positions_table ([Id] INT, 
                                    [organizations_id] INT, 
                                    [programuser_id] NVARCHAR(128) COLLATE Ukrainian_CI_AS) WITH (DATA_COMPRESSION = PAGE);
IF OBJECT_ID('tempdb..#temp_organizations_table') IS NOT NULL 
BEGIN   
   DROP TABLE #temp_organizations_table;
END   
IF @organizations_Id IS NULL 
BEGIN
INSERT INTO
   #temp_positions_table (Id, [organizations_id], programuser_id )
SELECT
   Id,
   [organizations_id],
   programuser_id COLLATE Ukrainian_CI_AS
FROM
   [dbo].[Positions];
END
ELSE 
BEGIN
SELECT
   value Id INTO #temp_organizations_table
FROM
   string_split(
      (
         SELECT
            REPLACE(@organizations_Id, N' ', N'')
      ),
      N','
   );
INSERT INTO
   #temp_positions_table (Id, [organizations_id], programuser_id)
SELECT
   [Positions].Id,
   [Positions].[organizations_id],
   [Positions].[programuser_id]
FROM
   [dbo].[Positions]
   INNER JOIN #temp_organizations_table ON [Positions].organizations_id=#temp_organizations_table.Id;
END 
--id_operator - вяжутся все таблички по нем
IF OBJECT_ID('tempdb..#temp_call') IS NOT NULL 
BEGIN
   DROP TABLE #temp_call;
END

SELECT
   [User].UserId user_id,
   ISNULL([User].[LastName] + N' ', N'') + ISNULL([User].[FirstName], N'') user_name,
   count([CallStatistic].Id) count_call,
   sum(
      CASE
         WHEN [CallStatistic].[TalkTime] < 10 THEN 1
         ELSE 0
      END
   ) count_10sec INTO #temp_call
FROM
   #temp_CallStatistic [CallStatistic]
   INNER JOIN 
   --  [CRM_1551_System].[dbo].[User]
   [#system_database_name#].[dbo].[User] 
   [User] ON [CallStatistic].OperatorCrm_Phone = [User].PhoneNumber
   INNER JOIN #temp_positions_table [Positions] ON [User].UserId=[Positions].programuser_id
GROUP BY
   [User].UserId,
   ISNULL([User].[LastName] + N' ', N'') + ISNULL([User].[FirstName], N'');

IF OBJECT_ID('tempdb..#temp_count_appeals') IS NOT NULL 
BEGIN
   DROP TABLE #temp_count_appeals;
END

SELECT
   [Appeals].[user_id],
   count(DISTINCT [Appeals].Id) count_appeals,
   count([Questions].Id) count_questions,
   sum(
      CASE
         WHEN [Consultations].consultation_type_id = 3 THEN 1
         ELSE 0
      END
   ) consult3,
   sum(
      CASE
         WHEN [Consultations].consultation_type_id = 2 THEN 1
         ELSE 0
      END
   ) consult2,
   sum(
      CASE
         WHEN [Consultations].consultation_type_id = 1 THEN 1
         ELSE 0
      END
   ) consult1,
   sum(
      CASE
         WHEN [Consultations].consultation_type_id = 4 THEN 1
         ELSE 0
      END
   ) consult4,
   CONVERT(
      INT,
      avg(
         CASE
            WHEN [Questions].Id IS NULL THEN CONVERT(FLOAT(53), [CallSipChannel].TalkTime)
         END
      )
   ) avg_cons_sec,
   sum(
      CASE
         WHEN [Questions].Id IS NULL
         AND [Consultations].Id IS NULL
         AND [CallSipChannel].SipCallId IS NOT NULL
         AND [CallSipChannel].TalkTime > 10 THEN 1
         ELSE 0
      END
   ) count_appeal_call 
   -- нужно найти звонки
   -- null pro_appeal_call 
   -- нужно найти звонки и в итоговой таблице найти процент
   INTO #temp_count_appeals
FROM
   [dbo].[Appeals] [Appeals] 
   INNER JOIN #temp_positions_table [Positions] ON [Appeals].[user_id]=[Positions].programuser_id
   LEFT JOIN [dbo].[Questions] [Questions] ON [Appeals].Id = [Questions].appeal_id
   LEFT JOIN [dbo].[Consultations] [Consultations] ON [Appeals].Id = [Consultations].appeal_id
   LEFT JOIN #temp_CallSipChannel [CallSipChannel] ON [Appeals].sipcallid=[CallSipChannel].SipCallId
WHERE
   (
      [receipt_source_id] IN (1, 8)
      AND ISNULL([Appeals].sipcallid, N'0') NOT IN (N'0', N'{sipCallId}')
      AND CONVERT(DATE, [Appeals].[registration_date])
      BETWEEN @date_from AND @date_to
   ) 
GROUP BY
   [Appeals].[user_id]; 
   ----select * from #temp_count_appeals
   /*тут*/
SELECT
   tc.user_id Id,
   user_name,
   tc.count_call,
   tc.count_10sec,
   tca.count_appeals,
   tca.count_questions,
   tca.consult3,
   tca.consult2,
   tca.consult1,
   tca.consult4,
   --tca.avg_cons_sec, 
   CASE
      WHEN len(tca.avg_cons_sec / 60) = 1 THEN N'0' + ltrim(tca.avg_cons_sec / 60)
      ELSE ltrim(tca.avg_cons_sec / 60)
   END + N':' + CASE
      WHEN len(tca.avg_cons_sec -(tca.avg_cons_sec / 60) * 60) = 1 THEN N'0' + ltrim(tca.avg_cons_sec -(tca.avg_cons_sec / 60) * 60)
      ELSE ltrim(tca.avg_cons_sec -(tca.avg_cons_sec / 60) * 60)
   END avg_cons_sec,
   tca.count_appeal_call,
   CONVERT(
      NUMERIC(6, 2),
      CONVERT(FLOAT(53), tca.count_appeal_call) / CONVERT(FLOAT(53), tca.count_appeals) * 100
   ) pro_appeal_call
FROM
   #temp_call tc
   INNER JOIN #temp_count_appeals tca ON tc.user_id=tca.user_id;
   
   --select * from #temp_count_appeals
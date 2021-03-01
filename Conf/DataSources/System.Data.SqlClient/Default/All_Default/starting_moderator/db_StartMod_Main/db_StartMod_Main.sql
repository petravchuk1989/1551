


 --declare @user_Id nvarchar(128)=N'test'


 declare @oldest datetime=(select min([ReceiptDate])
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where AppealFromSiteResultId=1)

 declare @datetime_from datetime = 
 (
 DATEADD(HOUR,
      DATEDIFF(HOUR,
         CONVERT(datetime, SWITCHOFFSET(datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 9, 0, 0, 0), DATEPART(TZOFFSET,datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 9, 0, 0, 0) AT TIME ZONE 'E. Europe Standard Time'))),
         datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 9, 0, 0, 0)
         ), datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 9, 0, 0, 0))
 )
 --datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 11, 0, 0, 0);
 declare @datetime_to datetime = 
 --datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 18, 0, 0, 0);
 (
 DATEADD(HOUR,
      DATEDIFF(HOUR,
         CONVERT(datetime, SWITCHOFFSET(datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 18, 0, 0, 0), DATEPART(TZOFFSET,datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 18, 0, 0, 0) AT TIME ZONE 'E. Europe Standard Time'))),
         datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 18, 0, 0, 0)
         ), datetimefromparts(year(getutcdate()), month(getutcdate()), day(getutcdate()), 18, 0, 0, 0))
 )

 --select @datetime_from, @datetime_to

  select 1 Id,

  (select count(Id)
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where AppealFromSiteResultId=1) on_moderation,

  --select datediff(ss, '2020-01-01 12:00:00', '2020-01-01 13:01:00')

  (select count([AppealsFromSite].Id)
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where AppealFromSiteResultId=1 and [ReceiptDate] between @datetime_from and @datetime_to
  and datediff(ss, [AppealsFromSite].[ReceiptDate], getutcdate())>2*60*60
  ) mutch_2hours,


  CONVERT(datetime, SWITCHOFFSET(@oldest, DATEPART(TZOFFSET,@oldest AT TIME ZONE 'E. Europe Standard Time'))) oldest,

--'2019-05-01 02:01:01.603' oldest,

  --4.1 если есть несколько, открываю самое старое
  --если нет, то открываю любое или там где EditByUserId пустое ?
  (select case when
  (select min(Id)
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where AppealFromSiteResultId=1 and EditByUserId=@user_Id) is not null

  then (select min(Id)
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where AppealFromSiteResultId=1 and EditByUserId=@user_Id)

  else (select min(Id)
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where AppealFromSiteResultId=1 and EditByUserId is null) end) appeal_id
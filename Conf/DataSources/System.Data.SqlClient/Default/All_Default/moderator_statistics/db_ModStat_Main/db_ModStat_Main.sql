


--select 1 Id, 
--100 on_moderation_2h, 
--200 registered_2h, 
--0.21 registered_percent, 
--330 come_avg, 
--0.11 come_avg_percent
/*
declare @date_from datetime='2020-05-01 12:10:02'
declare @date_to datetime='2020-06-21 12:10:02'
declare @user_Ids nvarchar(max)=N'29796543-b903-48a6-9399-4840f6eac396,Вася'
*/
/*
if OBJECT_ID('tempdb..#user') is not null drop table #user

create table #user (Id nvarchar(128))

if @user_Ids is null
	begin
		insert into #user (Id)
		select UserId from [CRM_1551_System].[dbo].[User]
	end
else
	begin
--[CRM_1551_System].[dbo].[User]
insert into #user (Id)
select value Id
from string_split(@user_Ids, N',')
	end
--select * from #user
*/
declare @date_from_l datetime= case when month(@date_from)<>month(@date_to) and year(@date_from)<>year(@date_to)
									then @date_to
									else dateadd(month, -1, @date_from)
									end
declare @date_to_l datetime= case when month(@date_from)<>month(@date_to) and year(@date_from)<>year(@date_to)
									then @date_from
									else dateadd(month, -1, @date_to)
									end

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


 declare @registered_2h int=
 (select count([AppealsFromSite].Id)
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
--inner join #user u on [AppealsFromSite].EditByUserId=u.Id
where convert(date, [ReceiptDate]) between @date_from and @date_to
and is_long_moderated='true')

declare @registered_2h_l int=
 (select count([AppealsFromSite].Id)
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
--inner join #user u on [AppealsFromSite].EditByUserId=u.Id
where convert(date, [ReceiptDate]) between @date_from_l and @date_to_l
and is_long_moderated='true')

declare @come_avg numeric(8,2)=
(
select convert(float, count([AppealsFromSite].Id))/convert(float, (datediff(dd, @date_from, @date_to)+1))
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
--inner join #user u on [AppealsFromSite].EditByUserId=u.Id
where convert(date, [ReceiptDate]) between @date_from and @date_to
and EditByUserId<>N'66e7784c-2760-4ddc-8c18-fbc66753aaae'
)

declare @come_avg_l numeric(8,2)=
(
select convert(float, count([AppealsFromSite].Id))/convert(float, (datediff(dd, @date_from, @date_to)+1))
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
--inner join #user u on [AppealsFromSite].EditByUserId=u.Id
where convert(date, [ReceiptDate]) between @date_from_l and @date_to_l
and EditByUserId<>N'66e7784c-2760-4ddc-8c18-fbc66753aaae'
)

select 1 Id, 
(select count([AppealsFromSite].Id)
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
--inner join #user u on [AppealsFromSite].EditByUserId=u.Id
where AppealFromSiteResultId=1 and [ReceiptDate] between @datetime_from and @datetime_to
and is_long_moderated is null and datediff(ss, [ReceiptDate], getutcdate())>2*60*60) on_moderation_2h,

@registered_2h registered_2h,

case when @registered_2h_l=0 then N''
else ltrim(convert(numeric(8,2),(@registered_2h-@registered_2h_l)/@registered_2h_l))
end registered_percent,

@come_avg come_avg,


case when @come_avg_l=0 then N''
else ltrim(convert(numeric(8,2),(@come_avg-@come_avg_l)/@come_avg_l))
end come_avg_percent


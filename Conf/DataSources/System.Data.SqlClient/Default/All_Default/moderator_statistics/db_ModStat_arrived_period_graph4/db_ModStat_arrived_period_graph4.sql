
/*
declare @date_from datetime='2019-05-01 12:10:02'
declare @date_to datetime='2019-07-30 12:10:02'
declare @user_Ids nvarchar(max)=N'29796543-b903-48a6-9399-4840f6eac396,Вася'
*/
declare @d date;
if OBJECT_ID('tempdb..#temp_day') is not null drop table #temp_day

set @d=@date_from

create table #temp_day (d date)

while @d<=@date_to
	begin

insert into #temp_day (d)
select @d

set @d=dateadd(day, 1, @d)
	end

--select * from #temp_day

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
	*/

declare @dates nvarchar(max)=
stuff((
select distinct N',['+ltrim(convert(date, [d]))+N']'
from #temp_day
for xml path ('')
),1,1,N'')



declare @query nvarchar(max)=N'
select AppealFromSiteResults_Id Id, leg_name, '+@dates+N'
from
(select [AppealsFromSite].Id, convert(date, [AppealsFromSite].[ReceiptDate]) [date], [AppealFromSiteResults].Id AppealFromSiteResults_Id,
[AppealFromSiteResults].name leg_name
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
inner join [CRM_1551_Site_Integration].[dbo].[AppealFromSiteResults] on [AppealsFromSite].AppealFromSiteResultId=[AppealFromSiteResults].Id
where convert(date, [AppealsFromSite].[ReceiptDate]) between '''+ltrim(convert(date, @date_from))+N''' and '''+ltrim(convert(date, @date_to))+N''') t
pivot
(
count(Id)
for [date] in ('+@dates+N')
) pvt
'
exec(@query)


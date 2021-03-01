

/*
declare @date_from datetime='2019-06-20 12:10:02'
declare @date_to datetime='2020-12-30 12:10:02'
declare @user_Ids nvarchar(max)=N'29796543-b903-48a6-9399-4840f6eac396,Вася'
*/

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


if OBJECT_ID('tempdb..#leg') is not null drop table #leg

select [AppealsFromSite].EditByUserId, 

isnull([User].[LastName], N'')+N' '+isnull([User].[FirstName], N'')+isnull(N' '+[User].[Patronymic], N'')
+N' - '+(select ltrim(count(Id)) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite])+

N' ('+ltrim(convert(numeric(8,2), convert(float,count([AppealsFromSite].Id))/convert(float, (select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
where [AppealsFromSite].AppealFromSiteResultId=3))*100))+N'%)' leg_name
into #leg
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
inner join #user on [AppealsFromSite].EditByUserId=#user.Id
inner join [CRM_1551_System].[dbo].[User] on [AppealsFromSite].EditByUserId=[User].UserId
where [AppealsFromSite].AppealFromSiteResultId=3
group by [AppealsFromSite].EditByUserId, isnull([User].[LastName], N'')+N' '+isnull([User].[FirstName], N'')+isnull(N' '+[User].[Patronymic], N'')


select EditByUserId Id, leg_name, [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23]
from 
(
select [AppealsFromSite].Id, l.EditByUserId, l.leg_name, datepart(hour, [ReceiptDate]) [hour]
from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
inner join #leg l on [AppealsFromSite].[EditByUserId]=l.EditByUserId
where [AppealsFromSite].AppealFromSiteResultId=3
and convert(date, [AppealsFromSite].[ReceiptDate])=convert(date, @date_from)
) t
pivot 
(
count(Id)
for [hour]
in ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23])
) pvt
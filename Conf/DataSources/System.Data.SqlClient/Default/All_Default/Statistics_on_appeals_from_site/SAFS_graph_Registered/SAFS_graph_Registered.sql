





/* 
declare @date_from date='2020-06-01',
  @date_to date='2020-09-30';
 */
   IF object_id('tempdb..#temp_main') IS NOT NULL DROP TABLE #temp_main

  create table #temp_main (Id int, [date] date, [indicator_value] int, user_name nvarchar(128), name nvarchar(200))

declare @date_table table (Id int identity(1,1), date date, nw int, nm int, ny int)
  declare @date_f date=convert(date, @date_from)

  while @date_f<=convert(date, @date_to)
  begin 
  insert into @date_table (date, nw, nm, ny)
  select @date_f, datepart(wk, @date_f), month(@date_f), year(@date_f)

  set @date_f=dateadd(dd, 1, @date_f)

  end

  --select * from @date_table

  if datediff(dd, @date_from, @date_to)<=30

    begin
		
		insert into #temp_main
			(Id, [date], [indicator_value], user_name, name)

	    select date_table.Id, date_table.date, isnull([indicator_value],0) [indicator_value], 
		ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'') user_name, ltrim(date_table.date) name
	    from @date_table date_table left join
	    [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=7
		left join [CRM_1551_System].[dbo].[User] on [Statistic].user_id=[User].UserId
    end

  if datediff(dd, @date_from, @date_to) between 31 and 90

	begin

		declare @dayweek table (Id int identity(1,1), nw int, first_date date, ny int)

		insert into @dayweek (nw, first_date, ny)
		select nw, min(date), ny
		from @date_table
		group by nw, ny

		insert into #temp_main
			(Id, [date], [indicator_value], user_name, name)

		--select --date_table.Id, 
		--datepart(ww, date_table.date) Id,
		--min(date_table.date) date, 
		--sum(isnull([indicator_value],0)) [indicator_value],
		--ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'') user_name,
		--ltrim(min(date_table.date)) name
	 --   from @date_table date_table left join
	 --   [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=7
		--left join [CRM_1551_System].[dbo].[User] on [Statistic].user_id=[User].UserId
		--group by datepart(ww, date_table.date), ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'')

		select dayweek.Id
		,dayweek.first_date [date]
		,sum(isnull([indicator_value],0)) [indicator_value]
		,ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'') user_name
		,dayweek.first_date [name]
		from @date_table date_table 
		left join [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=7
		left join [CRM_1551_System].[dbo].[User] on [Statistic].user_id=[User].UserId
		left join @dayweek dayweek on date_table.nw=dayweek.nw and date_table.ny=dayweek.ny
		group by dayweek.Id, dayweek.first_date, ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'')
	end

  if datediff(dd, @date_from, @date_to) >90

	begin

	declare @daymonth table (Id int identity(1,1), nm int, first_date date, ny int)

		insert into @daymonth (nm, first_date, ny)
		select nm, min(date), ny
		from @date_table
		group by nm, ny

		insert into #temp_main
			(Id, [date], [indicator_value], user_name, name)
		
		--select --date_table.Id, 
		--(ltrim(datepart(yy, date_table.date))+ltrim(datepart(mm, date_table.date)))*1 Id,
		--min(date_table.date) date, 
		--sum(isnull([indicator_value],0)) [indicator_value],
		----datename(mm,min(date_table.date))+N' '+datename(yy,min(date_table.date)) name
		----year(min(date_table.date))
		--ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'') user_name,
		--case 
		--when month(min(date_table.date))=1 then N'Січень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=2 then N'Лютий '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=3 then N'Березень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=4 then N'Квітень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=5 then N'Травень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=6 then N'Червень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=7 then N'Липень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=8 then N'Серпень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=9 then N'Вересень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=10 then N'Жовтень '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=11 then N'Листопад '+ltrim(year(min(date_table.date)))
		--when month(min(date_table.date))=12 then N'Грудень '+ltrim(year(min(date_table.date)))
		--end name
	 --   from @date_table date_table left join
	 --   [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=7
		--left join [CRM_1551_System].[dbo].[User] on [Statistic].user_id=[User].UserId
		--group by datepart(yy, date_table.date), datepart(mm, date_table.date), ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'')
		--order by min(date_table.date)

		select daymonth.Id, daymonth.first_date, sum(isnull([indicator_value],0)) [indicator_value],
		ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'') user_name,
		daymonth.first_date name
		from @date_table date_table left join
	    [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=7
		left join [CRM_1551_System].[dbo].[User] on [Statistic].user_id=[User].UserId
		left join @daymonth daymonth on date_table.nm=daymonth.nm and date_table.ny=daymonth.ny
		group by daymonth.Id, daymonth.first_date, ISNULL([User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'')
	end

-- declare @date_table table (Id int identity(1,1), date date)
--   declare @date_f date=convert(date, @date_from)

--   while @date_f<=convert(date, @date_to)
--   begin 
--   insert into @date_table (date)
--   select @date_f

--   set @date_f=dateadd(dd, 1, @date_f)

--   end

--   --select * from @date_table

--   select date_table.Id, date_table.date, isnull([indicator_value],0) [indicator_value]
--   from @date_table date_table left join
--   [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=6


-- select * 
-- from #temp_main


/* если что*/

declare @coloms nvarchar(max);
declare @coloms_isnull nvarchar(max);

declare @query nvarchar(max);

set @coloms=stuff((select distinct N', ['+ltrim(name)+N']' from #temp_main for xml path('')), 1,2, N'')
set @coloms_isnull=stuff((select distinct N', isnull(['+ltrim(name)+N'],0)'+N' ['+ltrim(name)+N']' from #temp_main for xml path('')), 1,2, N'')


--select @coloms_isnull

set @query = N'

select user_name, '+@coloms_isnull+N'
from (select name, user_name, indicator_value
from #temp_main) t

pivot
(
sum(indicator_value)

for [name] in ('+@coloms+N')

) pvt
'

exec (@query)


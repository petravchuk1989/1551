


/* 
declare @date_from date='2019-01-02',
  @date_to date='2020-08-29';
 */


declare @date_table table (Id int identity(1,1), date date)
  declare @date_f date=convert(date, @date_from)

  while @date_f<=convert(date, @date_to)
  begin 
  insert into @date_table (date)
  select @date_f

  set @date_f=dateadd(dd, 1, @date_f)

  end

  --select * from @date_table

  if datediff(dd, @date_from, @date_to)<=30

    begin
	    select date_table.Id, date_table.date, isnull([indicator_value],0) [indicator_value], ltrim(date_table.date) name
	    from @date_table date_table left join
	    [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=6
    end

  if datediff(dd, @date_from, @date_to) between 31 and 90

	begin
		select --date_table.Id, 
		datepart(ww, date_table.date) Id,
		min(date_table.date) date, 
		sum(isnull([indicator_value],0)) [indicator_value],
		ltrim(min(date_table.date)) name
	    from @date_table date_table left join
	    [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=6
		group by datepart(ww, date_table.date)
	end

  if datediff(dd, @date_from, @date_to) >90

	begin
		select --date_table.Id, 
		(ltrim(datepart(yy, date_table.date))+ltrim(datepart(mm, date_table.date)))*1 Id,
		min(date_table.date) date, 
		sum(isnull([indicator_value],0)) [indicator_value],
		--datename(mm,min(date_table.date))+N' '+datename(yy,min(date_table.date)) name
		--year(min(date_table.date))
		case 
		when month(min(date_table.date))=1 then N'Січень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=2 then N'Лютий '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=3 then N'Березень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=4 then N'Квітень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=5 then N'Травень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=6 then N'Червень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=7 then N'Липень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=8 then N'Серпень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=9 then N'Вересень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=10 then N'Жовтень '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=11 then N'Листопад '+ltrim(year(min(date_table.date)))
		when month(min(date_table.date))=12 then N'Грудень '+ltrim(year(min(date_table.date)))
		end name
	    from @date_table date_table left join
	    [CRM_1551_Site_Integration].[dbo].[Statistic] on date_table.date=[Statistic].date and [Statistic].diagram=6
		group by datepart(yy, date_table.date), datepart(mm, date_table.date)
		order by min(date_table.date)
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

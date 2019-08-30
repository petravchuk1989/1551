--  declare @org int = 0;
--  declare @dateFrom date = '2019-01-01';
--  declare @dateTo date = cast(current_timestamp as date);
--  declare @question_type_id int= 0;

 declare @question_type_t table (Id int)

if @question_type_id = 1
begin  
 insert into @question_type_t (Id)
 SELECT [Id] from [QuestionTypes]
 end
 else 
 begin 
 insert into @question_type_t (Id) 
select @question_type_id
end;

--select * from @question_type_t
if object_id('tempdb..#temp_Organizations') is not null drop table #temp_Organizations
begin
create table #temp_Organizations (Id int, short_name nvarchar(500))
end
	--declare @org_t table (Id int, short_name nvarchar(500))
	if @org = 0
	begin  
	 insert into #temp_Organizations (Id, short_name)
	 SELECT [Id], short_name 
	 from Organizations
	 end

	 else 
	 begin 
	 insert into #temp_Organizations (Id, short_name)
	--select @org
	SELECT [Id], short_name
	from Organizations
	where Id=@org or parent_organization_id=@org
	end


if object_id('tempdb..#temp_Main') is not null drop table #temp_Main

  select [Assignments].Id, [Assignments].[executor_organization_id] orgId, [Organizations].short_name orgName, 1 AllCount,
  case when /*close_date is not null and*/ (close_date <= execution_date) then 1 else 0 end inTimeQty,--- Закритих вчасно
  case when /*close_date is not null and*/ (close_date > execution_date) then 1 else 0 end outTimeQty,--- Закритих не вчасно
  case when assignment_state_id = 1 then 1 else 0 end waitTimeQty, --- Зареєстровано та не надійшло в роботу
  case when main_executor = 1 and AssignmentResultsId = 4 and assignment_state_id = 5  then 1 else 0 end doneClosedQty,--- Виконано та закрито
  case when main_executor = 1 and AssignmentResultsId = 5 and assignment_state_id = 4  then 1 else 0 end notDoneClosedQty,--- Виконано та на доопрацювання
  case when main_executor = 1 and AssignmentResultsId = 4 and assignment_state_id = 3 then 1 else 0 end doneOnCheckQty,--- Виконано та на перевірці
  case when assignment_state_id = 2  then 1 else 0 end inWorkQty --В роботі
  into #temp_Main
  from 
  [Assignments] with (nolock) --on [Assignments].executor_organization_id=[Organizations].Id
  inner join [Questions] with (nolock) on [Assignments].question_id=[Questions].Id
  inner join #temp_Organizations [Organizations] on [Assignments].executor_organization_id=[Organizations].Id
  where convert(date, Assignments.registration_date) between @dateFrom and @dateTo
  and Questions.question_type_id in (select Id from @question_type_t)
  --and [Organizations].Id in (select org from @org_t)
  --group by [Assignments].[executor_organization_id]


  /*select * from #temp_Main*/
  if object_id('tempdb..#temp_MainMain') is not null drop table #temp_MainMain

  select orgId Id, orgName, sum(AllCount) AllCount, sum(inTimeQty) inTimeQty, sum(outTimeQty) outTimeQty, sum(waitTimeQty) waitTimeQty,
  sum(doneClosedQty) doneClosedQty, sum(notDoneClosedQty) notDoneClosedQty, sum(doneOnCheckQty) doneOnCheckQty, sum(inWorkQty) inWorkQty
  into #temp_MainMain
  from #temp_Main
  group by orgId, orgName

  select top 100 #temp_MainMain.Id, #temp_MainMain.Id orgId, orgName, AllCount, inTimeQty, outTimeQty, waitTimeQty, doneClosedQty, doneOnCheckQty, notDoneClosedQty, inWorkQty,
--- Вираховуємо % вчасно закритих доручень організації виконавця
	case when cast(case when inWorkQty = 0
		    then cast(inTimeQty as numeric(16,8)) / cast(AllCount as numeric(16,8)) * 100
		  when inWorkQty != 0
		    then 
				case when (cast(AllCount as numeric(16,8)) - cast(inWorkQty as numeric(16,8))) > 0
				then cast(inTimeQty as numeric(16,8)) / (cast(AllCount as numeric(16,8)) - cast(inWorkQty as numeric(16,8))) * 100
				else 0 end
		  else 0 end as numeric(18,2)) = 0 then N'0'
	  else cast(cast(case when inWorkQty = 0 
		    then cast(inTimeQty as numeric(16,8)) / cast(AllCount as numeric(16,8)) * 100
		  when inWorkQty != 0
		    then case when (cast(AllCount as numeric(16,8)) - cast(inWorkQty as numeric(16,8))) > 0
				then cast(inTimeQty as numeric(16,8)) / (cast(AllCount as numeric(16,8)) - cast(inWorkQty as numeric(16,8))) * 100
				else 0 end
		  else 0 end as numeric(18,2)) as numeric(18,2))
	 end as inTimePercent
	 ,

	 case when doneClosedQty != 0 
then case when right(cast(cast(cast(doneClosedQty as numeric(16,8)) / (cast(doneClosedQty as numeric(16,8)) + cast(notDoneClosedQty as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),2) = 00 
then case when right(left(cast(cast(cast(doneClosedQty as numeric(16,8)) / (cast(doneClosedQty as numeric(16,8)) + cast(notDoneClosedQty as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),3),1) = N'.' 
then left(cast(cast(cast(doneClosedQty as numeric(16,8)) / (cast(doneClosedQty as numeric(16,8)) + cast(notDoneClosedQty as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),2) 
else left(cast(cast(cast(doneClosedQty as numeric(16,8)) / (cast(doneClosedQty as numeric(16,8)) + cast(notDoneClosedQty as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),3) end
else cast(cast(cast(doneClosedQty as numeric(16,8)) / (cast(doneClosedQty as numeric(16,8)) + cast(notDoneClosedQty as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)) end
else N'0' end + N'%'  as donePercent

  from 
  #temp_MainMain 
  --where Id=4028
  order by AllCount desc




--  declare @question_type_t table (Id int)

-- if @question_type_id = 1
-- begin  
--  insert into @question_type_t (Id)
--  SELECT [Id] from [QuestionTypes]
--  end
--  else 
--  begin 
--  insert into @question_type_t (Id) 
-- select @question_type_id
-- end;

-- --select * from @question_type_t

-- declare @org_t table (org int)
-- if @org = 0
-- begin  
--  insert into @org_t (org)
--  SELECT [Id] from Organizations
--  end
--  else 
--  begin insert into @org_t (org) 
-- select @org
-- end

-- select 
-- top 100 
-- ROW_NUMBER() OVER(ORDER BY COUNT(ass.Id) desc) as Id,
-- o.Id as orgId,
-- o.short_name as orgName, 
-- COUNT(ass.Id) AllCount, 
-- isnull(inTimeQty,0) as inTimeQty,
-- isnull(outTimeQty,0) as outTimeQty, isnull(waitTimeQty,0) as waitTimeQty,
-- isnull(doneClosedQty,0) as doneClosedQty, isnull(notDoneClosedQty,0) as notDoneClosedQty,
-- isnull(doneOnCheckQty,0) as doneOnCheckQty, isnull(inWorkQty,0) as inWorkQty,
-- --- Вираховуємо % вчасно закритих доручень організації виконавця
-- 	case when cast(case when isnull(inWorkQty,0) = 0
-- 		    then cast(isnull(inTimeQty,0) as numeric(16,8)) / cast(COUNT(ass.Id) as numeric(16,8)) * 100
-- 		  when isnull(inWorkQty,0) != 0
-- 		    then 
-- 				case when (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) > 0
-- 				then cast(isnull(inTimeQty,0) as numeric(16,8)) / (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) * 100
-- 				else 0 end
-- 		  else 0 end as numeric(18,2)) = 0 then N'0'
-- 	  else cast(cast(case when isnull(inWorkQty,0) = 0 
-- 		    then cast(isnull(inTimeQty,0) as numeric(16,8)) / cast(COUNT(ass.Id) as numeric(16,8)) * 100
-- 		  when isnull(inWorkQty,0) != 0
-- 		    then case when (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) > 0
-- 				then cast(isnull(inTimeQty,0) as numeric(16,8)) / (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) * 100
-- 				else 0 end
-- 		  else 0 end as numeric(18,2)) as numeric(18,2))
-- 	 end as inTimePercent,
	
--  --- Отримуємо % виконання
-- case when isnull(doneClosedQty,0) != 0 
-- then case when right(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),2) = 00 
-- then case when right(left(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),3),1) = N'.' 
-- then left(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),2) 
-- else left(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),3) end
-- else cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)) end
-- else N'0' end + N'%'  as donePercent
-- from Organizations o
-- join Assignments ass on ass.executor_organization_id = o.Id
-- left join Questions q on ass.question_id = q.Id
-- left join Appeals ap on ap.Id = q.appeal_id
-- --- Закритих вчасно
-- left join (select COUNT(ass.Id) as inTimeQty, executor_organization_id
--             from Assignments ass
-- 			left join Questions q on ass.question_id = q.Id 
-- 			where close_date is not null and (close_date <= execution_date) 
-- 			and ass.registration_date between @dateFrom and @dateTo
-- 			and q.question_type_id in (select Id from @question_type_t)
-- 			group by executor_organization_id) inTime on inTime.executor_organization_id = o.Id
-- --- Закритих не вчасно
-- left join (select COUNT(ass.Id) as outTimeQty, executor_organization_id
--             from Assignments ass
-- 			left join Questions q on ass.question_id = q.Id
-- 			where close_date is not null and (close_date > execution_date) 
-- 			and ass.registration_date between @dateFrom and @dateTo
-- 			and q.question_type_id in (select Id from @question_type_t)
-- 			group by executor_organization_id) outTime on outTime.executor_organization_id = o.Id
-- --- Зареєстровано та не надійшло в роботу
-- left join (select COUNT(ass.Id) as waitTimeQty, executor_organization_id
--             from Assignments ass
-- 			left join Questions q on ass.question_id = q.Id
-- 			where assignment_state_id = 1 
-- 			and ass.registration_date between @dateFrom and @dateTo
-- 			and q.question_type_id in (select Id from @question_type_t)
-- 			group by executor_organization_id) waitTime on waitTime.executor_organization_id = o.Id
-- --- Виконано та закрито 
-- left join (select COUNT(ass.Id) as doneClosedQty, executor_organization_id 
--           from Assignments ass
-- 		   left join Questions q on ass.question_id = q.Id
--           where main_executor = 1 and AssignmentResultsId = 4 and assignment_state_id = 5 
-- 		   and ass.registration_date between @dateFrom and @dateTo
-- 		   and q.question_type_id in (select Id from @question_type_t)
-- 		   group by executor_organization_id) doneClosed on doneClosed.executor_organization_id = o.Id
-- --- Виконано та на доопрацювання
-- left join (select COUNT(ass.Id) as notDoneClosedQty, executor_organization_id 
--           from Assignments ass 
-- 		   left join Questions q on ass.question_id = q.Id
--           where main_executor = 1 and AssignmentResultsId = 5 and assignment_state_id = 4 
-- 		   and ass.registration_date between @dateFrom and @dateTo
-- 		   and q.question_type_id in (select Id from @question_type_t)
-- 		   group by executor_organization_id) notDoneClosed on notDoneClosed.executor_organization_id = o.Id
-- --- Виконано та на перевірці
-- left join (select COUNT(ass.Id) as doneOnCheckQty, executor_organization_id 
--           from Assignments ass
-- 		   left join Questions q on ass.question_id = q.Id
--           where main_executor = 1 and AssignmentResultsId = 4 and assignment_state_id = 3 
-- 		   and ass.registration_date between @dateFrom and @dateTo
-- 		   and q.question_type_id in (select Id from @question_type_t)
-- 		   group by executor_organization_id) doneOnCheck on doneOnCheck.executor_organization_id = o.Id
-- --- В роботі
-- left join (select COUNT(ass.Id) as inWorkQty, executor_organization_id 
--           from Assignments ass
-- 		   left join Questions q on ass.question_id = q.Id
--           where assignment_state_id = 2  
-- 		   and ass.registration_date between @dateFrom and @dateTo
-- 		   and q.question_type_id in (select Id from @question_type_t)
-- 		   group by executor_organization_id) inWork on inWork.executor_organization_id = o.Id
-- where ass.registration_date between @dateFrom and @dateTo
-- and( o.Id in (select org from @org_t) or o.parent_organization_id in (select org from @org_t) )
-- and q.question_type_id in (select Id from @question_type_t)

-- group by o.Id, o.short_name, inTimeQty, outTimeQty, waitTimeQty, doneClosedQty, notDoneClosedQty, doneOnCheckQty, inWorkQty
-- order by AllCount desc
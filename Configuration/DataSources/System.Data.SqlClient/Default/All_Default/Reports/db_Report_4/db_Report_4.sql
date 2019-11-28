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

declare @org_t table (org int)
if @org = 0
begin  
 insert into @org_t (org)
 SELECT [Id] from Organizations
 end
 else 
 begin insert into @org_t (org) 
select @org
end

select 
top 100 
ROW_NUMBER() OVER(ORDER BY COUNT(ass.Id) desc) as Id,
o.Id as orgId,
o.short_name as orgName, 
COUNT(ass.Id) AllCount, 
isnull(inTimeQty,0) as inTimeQty,
isnull(outTimeQty,0) as outTimeQty, isnull(waitTimeQty,0) as waitTimeQty,
isnull(doneClosedQty,0) as doneClosedQty, isnull(notDoneClosedQty,0) as notDoneClosedQty,
isnull(doneOnCheckQty,0) as doneOnCheckQty, isnull(inWorkQty,0) as inWorkQty,
--- Вираховуємо % вчасно закритих доручень організації виконавця
	case when cast(case when isnull(inWorkQty,0) = 0
		    then cast(isnull(inTimeQty,0) as numeric(16,8)) / cast(COUNT(ass.Id) as numeric(16,8)) * 100
		  when isnull(inWorkQty,0) != 0
		    then 
				case when (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) > 0
				then cast(isnull(inTimeQty,0) as numeric(16,8)) / (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) * 100
				else 0 end
		  else 0 end as numeric(18,2)) = 0 then N'0'
	  else cast(cast(case when isnull(inWorkQty,0) = 0 
		    then cast(isnull(inTimeQty,0) as numeric(16,8)) / cast(COUNT(ass.Id) as numeric(16,8)) * 100
		  when isnull(inWorkQty,0) != 0
		    then case when (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) > 0
				then cast(isnull(inTimeQty,0) as numeric(16,8)) / (cast(COUNT(ass.Id) as numeric(16,8)) - cast(isnull(inWorkQty,0) as numeric(16,8))) * 100
				else 0 end
		  else 0 end as numeric(18,2)) as numeric(18,2))
	 end as inTimePercent,
	
 --- Отримуємо % виконання
case when isnull(doneClosedQty,0) != 0 
then case when right(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),2) = 00 
then case when right(left(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),3),1) = N'.' 
then left(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),2) 
else left(cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)),3) end
else cast(cast(cast(isnull(doneClosedQty,0) as numeric(16,8)) / (cast(isnull(doneClosedQty,0) as numeric(16,8)) + cast(isnull(notDoneClosedQty,0) as numeric(16,8))) * 100 as numeric(18,2) ) as nvarchar(10)) end
else N'0' end + N'%'  as donePercent
from Organizations o
join Assignments ass on ass.executor_organization_id = o.Id
left join Questions q on ass.question_id = q.Id
left join Appeals ap on ap.Id = q.appeal_id
--- Закритих вчасно
left join (select COUNT(ass.Id) as inTimeQty, executor_organization_id
            from Assignments ass
			left join Questions q on ass.question_id = q.Id 
			where close_date is not null and (close_date <= execution_date) 
			and ass.registration_date between @dateFrom and @dateTo
			and q.question_type_id in (select Id from @question_type_t)
			group by executor_organization_id) inTime on inTime.executor_organization_id = o.Id
--- Закритих не вчасно
left join (select COUNT(ass.Id) as outTimeQty, executor_organization_id
            from Assignments ass
			left join Questions q on ass.question_id = q.Id
			where close_date is not null and (close_date > execution_date) 
			and ass.registration_date between @dateFrom and @dateTo
			and q.question_type_id in (select Id from @question_type_t)
			group by executor_organization_id) outTime on outTime.executor_organization_id = o.Id
--- Зареєстровано та не надійшло в роботу
left join (select COUNT(ass.Id) as waitTimeQty, executor_organization_id
            from Assignments ass
			left join Questions q on ass.question_id = q.Id
			where assignment_state_id = 1 
			and ass.registration_date between @dateFrom and @dateTo
			and q.question_type_id in (select Id from @question_type_t)
			group by executor_organization_id) waitTime on waitTime.executor_organization_id = o.Id
--- Виконано та закрито 
left join (select COUNT(ass.Id) as doneClosedQty, executor_organization_id 
           from Assignments ass
		   left join Questions q on ass.question_id = q.Id
           where AssignmentResultsId in (4, 7, 10) and assignment_state_id = 5 
		   and ass.registration_date between @dateFrom and @dateTo
		   and q.question_type_id in (select Id from @question_type_t)
		   group by executor_organization_id) doneClosed on doneClosed.executor_organization_id = o.Id
--- Виконано та на доопрацювання
left join (select COUNT(ass.Id) as notDoneClosedQty, executor_organization_id 
           from Assignments ass 
		   left join Questions q on ass.question_id = q.Id
           where AssignmentResultsId in (5, 12) and assignment_state_id = 4 
		   and ass.registration_date between @dateFrom and @dateTo
		   and q.question_type_id in (select Id from @question_type_t)
		   group by executor_organization_id) notDoneClosed on notDoneClosed.executor_organization_id = o.Id
--- Виконано та на перевірці
left join (select COUNT(ass.Id) as doneOnCheckQty, executor_organization_id 
           from Assignments ass
		   left join Questions q on ass.question_id = q.Id
           where main_executor = 1 and AssignmentResultsId in (4, 7) and assignment_state_id = 3 
		   and ass.registration_date between @dateFrom and @dateTo
		   and q.question_type_id in (select Id from @question_type_t)
		   group by executor_organization_id) doneOnCheck on doneOnCheck.executor_organization_id = o.Id
--- В роботі
left join (select COUNT(ass.Id) as inWorkQty, executor_organization_id 
           from Assignments ass
		   left join Questions q on ass.question_id = q.Id
           where assignment_state_id = 2  
		   and ass.registration_date between @dateFrom and @dateTo
		   and q.question_type_id in (select Id from @question_type_t)
		   group by executor_organization_id) inWork on inWork.executor_organization_id = o.Id
where ass.registration_date between @dateFrom and @dateTo
and( o.Id in (select org from @org_t) or o.parent_organization_id in (select org from @org_t) )
and q.question_type_id in (select Id from @question_type_t)

group by o.Id, o.short_name, inTimeQty, outTimeQty, waitTimeQty, doneClosedQty, notDoneClosedQty, doneOnCheckQty, inWorkQty
order by AllCount desc
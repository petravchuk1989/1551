--declare @is_active int = null
--declare @DateStart date = '07-01-2020'
--declare @DateEnd date = '08-10-2020'

select Polls.[id] as Polls_Id, poll_name, case when cast([start_date] as date) > cast(GETDATE() as date) and is_active = 0 then 1
					  when cast([start_date] as date) > cast(GETDATE() as date) and is_active = 1 then 2
					  when cast([end_date] as date) <= cast(GETDATE() as date)  then 3
					  when cast([start_date] as date) <= cast(GETDATE() as date) and cast([end_date] as date) > cast(GETDATE() as date) and is_active = 1 then 4
					  when cast([start_date] as date) <= cast(GETDATE() as date) and cast([end_date] as date) > cast(GETDATE() as date) and is_active = 0 then 5  end as idIcon, 
is_active, 
start_date, 
end_date, 
PollDirection.id as PollDirId, 
PollDirection.name,  
AllApplicants.col_Applicants, 
IsPollsApplicants.col_IsPollsApplicants, 
IsNotPollsApplicants.col_IsNotApplicants,
Polls.people_limit,
(SELECT t1.[id] as 'polls_poll_direction_id',
		t2.[id] as 'poll_direction_id',
		t2.[name] as 'poll_direction_name'
	FROM [dbo].[Polls_PollDirections] as t1 with (nolock)
	left join [dbo].[PollDirection] as t2 on t2.id = t1.direction_id
	where  t1.[poll_id] = Polls.[id]
	FOR JSON PATH, INCLUDE_NULL_VALUES) as 'poll_directions'
from Polls
inner join Polls_PollDirections on Polls_PollDirections.poll_id = Polls.id
inner join PollDirection on PollDirection.id = Polls_PollDirections.direction_id
left join ( select poll_id, count(id) as col_Applicants from PollsApplicants  group by poll_id) AllApplicants on AllApplicants.poll_id = Polls.id
left join ( select poll_id, count(id) as col_IsPollsApplicants from PollsApplicants  where poll_date is not null group by poll_id) IsPollsApplicants on IsPollsApplicants.poll_id = Polls.id
left join ( select poll_id, count(id) as col_IsNotApplicants from PollsApplicants  where reject_poll = 1 group by poll_id) IsNotPollsApplicants on IsNotPollsApplicants.poll_id = Polls.id
where cast([start_date] as date) >= cast(@DateStart as date)  and cast(end_date as date) <= cast(@DateEnd as date) and
(is_active  = @is_active  or isnull(@is_active, 2) = 2) and
#filter_columns# 


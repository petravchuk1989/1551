select poll_name, is_active, start_date, end_date, PollDirection.name,  AllApplicants.col_Applicants, IsPollsApplicants.col_IsPollsApplicants, IsNotPollsApplicants.col_IsNotApplicants
from Polls
inner join Polls_PollDirections on Polls_PollDirections.poll_id = Polls.id
inner join PollDirection on PollDirection.id = Polls_PollDirections.direction_id
left join ( select poll_id, count(id) as col_Applicants from PollsApplicants  group by poll_id) AllApplicants on AllApplicants.poll_id = Polls.id
left join ( select poll_id, count(id) as col_IsPollsApplicants from PollsApplicants  where poll_date is not null group by poll_id) IsPollsApplicants on IsPollsApplicants.poll_id = Polls.id
left join ( select poll_id, count(id) as col_IsNotApplicants from PollsApplicants  where reject_poll = 1 group by poll_id) IsNotPollsApplicants on IsNotPollsApplicants.poll_id = Polls.id
where Polls.Id = @Id
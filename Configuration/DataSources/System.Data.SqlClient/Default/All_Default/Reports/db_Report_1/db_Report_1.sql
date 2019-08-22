select ROW_NUMBER() OVER(ORDER BY u.FirstName DESC) as Id,
u.LastName + isnull(' ' + u.FirstName, N'') + isnull(' ' + u.Patronymic,N'') 
			 as Operator
			,isnull(apQ.appealsQ,0) as AppealCount
			,ISNULL(qQ.questionsQ,0) as QuestionCount
			,isnull(dQ.DoneAssignments,0) as DoneAssignments
			,isnull(twQ.reWorkAssignments,0) as reWorkAssignments
			,isnull(nQ.notAnswerAssignments,0) as notAnswerAssignments
from CRM_1551_System.[dbo].[User] u
-- получить звернення где эдитор наш юзер 
left join (select COUNT(a.Id) as appealsQ, u.UserId 
from Appeals a 
join CRM_1551_System.[dbo].[User] u on a.user_edit_id = u.UserId
where a.start_date between @dateFrom and @dateTo 
group by u.UserId) apQ on apQ.UserId = u.UserId
-- получить питання где эдитор наш юзер 
left join (select COUNT(q.Id) as questionsQ, u.UserId 
from Questions q
join CRM_1551_System.[dbo].[User] u on q.user_edit_id = u.UserId
where q.registration_date between @dateFrom and @dateTo 
group by u.UserId) qQ on qQ.UserId = u.UserId
-- получить доручення где эдитор наш юзер и результат = Виконано
left join (select COUNT(a.Id) as DoneAssignments, u.UserId
from Assignments a
join CRM_1551_System.[dbo].[User] u on a.user_edit_id = u.UserId
where AssignmentResultsId = 4 and a.registration_date between @dateFrom and @dateTo
group by u.UserId) dQ on dQ.UserId = u.UserId
-- получить доручення где эдитор наш юзер и результат = На доопрацювання
left join (select COUNT(a.Id) as reWorkAssignments, u.UserId
from Assignments a
join CRM_1551_System.[dbo].[User] u on a.user_edit_id = u.UserId
where AssignmentResultsId = 5 and a.registration_date between @dateFrom and @dateTo
group by u.UserId) twQ on twQ.UserId = u.UserId
-- получить доручення где эдитор наш юзер и результат = Недозвон
left join (select sum(ar.missed_call_counter) as notAnswerAssignments, u.UserId
from AssignmentConsiderations ac
join AssignmentRevisions ar on ar.assignment_consideration_іd = ac.Id
join CRM_1551_System.[dbo].[User] u on ar.user_edit_id = u.UserId
where ac.create_date between @dateFrom and @dateTo
group by u.UserId
) nQ on nQ.UserId = u.UserId
where 
#filter_columns#
group by u.LastName, u.FirstName, u.Patronymic, qQ.questionsQ, apQ.appealsQ, dQ.DoneAssignments,
         twQ.reWorkAssignments, nQ.notAnswerAssignments 
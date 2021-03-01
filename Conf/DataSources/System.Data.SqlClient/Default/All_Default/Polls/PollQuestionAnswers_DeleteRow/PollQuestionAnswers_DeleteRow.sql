-- declare @poll_question_id int = 5
-- declare @user_id nvarchar(max) = N'test-user'

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

declare @poll_id int = (select top 1 [poll_id] from [dbo].[PollQuestions] where [Id] = @poll_question_id)


/*PollQuestionAnswers*/
delete from [dbo].[PollQuestionAnswers] where [poll_question_id] = @poll_question_id

/*PollQuestions*/
delete from [dbo].[PollQuestions] where [Id] = @poll_question_id

update [dbo].[PollQuestions] set [sequence_number] = t2.rnk
from [dbo].[PollQuestions]
inner join (
	  SELECT [id]
		  , RANK() OVER(PARTITION BY [poll_id] ORDER BY [id]) rnk
	  FROM [dbo].[PollQuestions]
	  where [poll_id] = @poll_id
	  ) as t2 on t2.id = [PollQuestions].id



--select * from [dbo].[PollQuestions] where poll_id = @poll_id
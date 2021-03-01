-- declare @json nvarchar(max)
-- set @json = N'{"poll_id":123, "poll_answer_type":2, "poll_question_name_ukr":"hgfhfghfgh", "poll_question_name_rus":"hfghfghfg", "poll_question_answers":[{"answer_name_ukr":"1","answer_name_rus":"1"},{"answer_name_ukr":"2","answer_name_rus":"44"},{"answer_name_ukr":"3","answer_name_rus":"3"}], "is_other_answer":false, "poll_question_id":8}'

-- declare @user_id nvarchar(max) = N'test-user'

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



if object_id('tempdb..#temp_OUT_poll_questions') is not NULL drop table #temp_OUT_poll_questions
create table #temp_OUT_poll_questions (
	[poll_id] int,
	[poll_answer_type] int,
	[poll_question_name_ukr] nvarchar(max),
	[poll_question_name_rus] nvarchar(max),
	[poll_question_id] int,
	[is_other_answer] bit
)

if object_id('tempdb..#temp_OUT_poll_question_answers') is not NULL drop table #temp_OUT_poll_question_answers
create table #temp_OUT_poll_question_answers (
	[answer_name_ukr] nvarchar(max),
	[answer_name_rus] nvarchar(max)
)

delete from #temp_OUT_poll_questions
insert into #temp_OUT_poll_questions ([poll_id],
									[poll_answer_type],
									[poll_question_name_ukr],
									[poll_question_name_rus],
									[poll_question_id],
									[is_other_answer])
SELECT *
	FROM OPENJSON(@json)
	with
(
	[poll_id] int '$.poll_id',
	[poll_answer_type] int '$.poll_answer_type',
	[poll_question_name_ukr] nvarchar(max) '$.poll_question_name_ukr',
	[poll_question_name_rus] nvarchar(max) '$.poll_question_name_rus',
	[poll_question_id] int '$.poll_question_id',
	[is_other_answer] bit '$.is_other_answer'	
);

delete from #temp_OUT_poll_question_answers
insert into #temp_OUT_poll_question_answers ([answer_name_ukr], [answer_name_rus])
SELECT [answer_name_ukr], [answer_name_rus]
FROM OPENJSON(@json)  
WITH (
		variants NVARCHAR(MAX) '$.poll_question_answers' AS JSON
)
OUTER APPLY OPENJSON(variants)
with
(
	[answer_name_ukr] nvarchar(500) '$.answer_name_ukr',
	[answer_name_rus] nvarchar(500) '$.answer_name_rus'
)

declare @poll_question_id int = (select top 1 [poll_question_id] from #temp_OUT_poll_questions)
declare @poll_id int = (select top 1 [poll_id] from #temp_OUT_poll_questions)


if (@poll_question_id) is not null
begin
	update [dbo].[PollQuestions] set [poll_question_name_ukr] = #temp_OUT_poll_questions.[poll_question_name_ukr],
									 [poll_question_name_rus] = #temp_OUT_poll_questions.[poll_question_name_rus],
									 [has_text_answer] = #temp_OUT_poll_questions.[is_other_answer],
									 [poll_answer_type_id] = #temp_OUT_poll_questions.[poll_answer_type],
									 [is_active] = 1,
									 [edit_date] = getutcdate(),
									 [user_edit_id] = @user_id

	from [dbo].[PollQuestions] 
	inner join #temp_OUT_poll_questions on #temp_OUT_poll_questions.poll_question_id = [PollQuestions].[id]
end
else
begin

	declare @output_PollQuestions table (Id int);

	insert into [dbo].[PollQuestions] ([poll_id]
									  ,[poll_question_name_ukr]
									  ,[poll_question_name_rus]
									  ,[sequence_number]
									  ,[is_active]
									  ,[has_text_answer]
									  ,[poll_answer_type_id]
									  ,[add_date]
									  ,[user_id]
									  ,[edit_date]
									  ,[user_edit_id])
	output [inserted].[Id] into @output_PollQuestions (Id)
	select  [poll_id],
			[poll_question_name_ukr],
			[poll_question_name_rus],
			0 as [sequence_number],
			1 as [is_active],
			[is_other_answer],
			[poll_answer_type],
			getutcdate(),
			@user_id,
			getutcdate(),
			@user_id
	from #temp_OUT_poll_questions

	set @poll_question_id = (select top 1 Id from @output_PollQuestions)
end




/*PollQuestionAnswers*/
delete from [dbo].[PollQuestionAnswers] where [poll_question_id] = @poll_question_id

declare @output_PollQuestionAnswers table (Id int);
insert into [dbo].[PollQuestionAnswers] ([poll_question_id]
     ,[answer_name_ukr]
     ,[answer_name_rus]
     ,[answer_sequence_number]
     ,[is_active]
     ,[add_date]
     ,[user_id]
     ,[edit_date]
     ,[user_edit_id])
output [inserted].[Id] into @output_PollQuestionAnswers (Id)
select  @poll_question_id,
		[answer_name_ukr],
	    [answer_name_rus],
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum,
		1 as [is_active],
		getutcdate(),
		@user_id,
		getutcdate(),
		@user_id
from #temp_OUT_poll_question_answers


update [dbo].[PollQuestions] set [sequence_number] = t2.rnk
from [dbo].[PollQuestions]
inner join (
	  SELECT [id]
		  , RANK() OVER(PARTITION BY [poll_id] ORDER BY [id]) rnk
	  FROM [dbo].[PollQuestions]
	  where [poll_id] = @poll_id
	  ) as t2 on t2.id = [PollQuestions].id



select @poll_question_id as [poll_question_id]
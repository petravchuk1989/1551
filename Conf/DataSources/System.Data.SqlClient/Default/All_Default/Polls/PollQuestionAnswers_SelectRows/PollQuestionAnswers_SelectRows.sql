-- declare @poll_id int = 123


select  JSON_QUERY((
		select   t.poll_id
				,t.poll_answer_type
				,t.poll_question_name_ukr
				,t.poll_question_name_rus
				,t.is_other_answer
				,t.poll_question_id
				,t.sequence_number
				,(SELECT t1.[answer_name_ukr] as 'answer_name_ukr',
						 t1.[answer_name_rus] as 'answer_name_rus',
						 t1.[answer_sequence_number] as 'answer_sequence_number'
							FROM [dbo].[PollQuestionAnswers] as t1 with (nolock)
							where  t1.[poll_question_id] = t.[poll_question_id]
							order by t1.[answer_sequence_number]
							FOR JSON PATH, INCLUDE_NULL_VALUES) as 'poll_question_answers'
		from (
			SELECT t1.[poll_id] as 'poll_id'
			,t1.[poll_answer_type_id] as 'poll_answer_type'
			,t1.[poll_question_name_ukr] as 'poll_question_name_ukr'
			,t1.[poll_question_name_rus] as 'poll_question_name_rus'
			,t1.[has_text_answer] as 'is_other_answer'
			,t1.[id] as 'poll_question_id'
			,t1.[sequence_number] as 'sequence_number'
			  FROM [dbo].[PollQuestions] as t1 with (nolock)
			  where t1.poll_id = @poll_id
		) as t
		FOR JSON PATH, INCLUDE_NULL_VALUES
		)) as Result



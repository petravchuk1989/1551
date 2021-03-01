--declare @question_id int =1234;

  select [Question_History].Id, [QuestionTypes].name QuestionType, [Objects].name [Object], [Organizations].short_name,
  [Question_History].question_content, [Organizations2].short_name executor, [Question_History].control_date
  , [QuestionStates].name QuestionState
  from   [dbo].[Question_History]
  left join   [dbo].[QuestionTypes] on [Question_History].question_type_id=[QuestionTypes].Id
  left join   [dbo].[Objects] on [Question_History].[object_id]=[Objects].Id
  left join   [dbo].[Organizations] on [Question_History].organization_id=[Organizations].Id
  left join   [dbo].[Assignments] on [Question_History].last_assignment_for_execution_id=[Assignments].Id
  left join   [dbo].[Organizations] [Organizations2] on [Assignments].executor_organization_id=[Organizations2].Id
  left join   [dbo].[QuestionStates] on [Question_History].question_state_id=[QuestionStates].Id
  where [Question_History].question_id=@question_id
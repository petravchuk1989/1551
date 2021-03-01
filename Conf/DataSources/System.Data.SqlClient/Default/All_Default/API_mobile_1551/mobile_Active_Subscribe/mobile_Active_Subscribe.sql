


 --DECLARE @user_id NVARCHAR(128) = N'5b37daab-e5bd-46c4-bb26-e04d160ec966';

SELECT
  aqt.Id,
  aqt.[assignment_id],
  --a
  asq.[registration_number] [assignment_registration_number],
  asq.[registration_date] [assignment_registration_date],
  asap.full_name [assignment_full_name],
  asap.[ApplicantAdress] [assignment_ApplicantAdress],
  aso.name [assignment_object_name], 
  asqt.name [assignment_question_type_name],
  asq.[question_content] [assignment_question_content],
  ass.name [assignment_state_name],
  asr.name [assignment_result_name],
  --a
  aqt.[event_id],
  --e
  ee.Id [event_number],
  eec.name [event_class_name],
  eet.name [event_type_name],
  eo.name [event_object_name],
  eeorga.name [event_organization_name],
  ee.comment [event_comment],
  ee.start_date [event_start_date],
  ee.plan_end_date [event_plan_end_date],
  ee.real_end_date [event_real_end_date],
  --e
  aqt.[question_type_id],
  [QuestionTypes].[name] AS [question_type_name],
  qt_par.Id AS [parent_question_type_id],
  qt_par.[name] AS [parent_question_type_name],
  aqt.[object_id],
  [Objects].[name] AS [object_name],
  aqt.[statecode]
FROM
  [dbo].[AttentionQuestionAndEvent] aqt
  LEFT JOIN [dbo].[QuestionTypes] [QuestionTypes] ON aqt.question_type_id = [QuestionTypes].Id
  LEFT JOIN [dbo].[Objects] [Objects] ON aqt.[object_id] = [Objects].Id
  LEFT JOIN [dbo].[QuestionTypes] qt_par ON [QuestionTypes].question_type_id = qt_par.Id
  --a
  left join [dbo].[Assignments] asa on aqt.assignment_id=asa.Id
  left join [dbo].[Questions] asq on asa.question_id=asq.Id
  left join [dbo].[Applicants] asap on asq.appeal_id=asap.Id
  left join [dbo].[Objects] aso on asq.object_id=aso.Id
  left join [dbo].[QuestionTypes] asqt on asq.question_type_id=asqt.Id
  left join [dbo].[AssignmentStates] ass on asa.assignment_state_id=ass.Id
  left join [dbo].[AssignmentResults] asr on asa.AssignmentResultsId=asr.Id
  --a
  --e
  left join [dbo].[Events] ee on aqt.event_id=ee.Id
  left join [dbo].[Event_Class] eec on ee.event_class_id=eec.Id
  left join [dbo].[EventTypes] eet on ee.event_type_id=eet.Id
  left join [dbo].[EventObjects] eeo on ee.Id=eeo.event_id and eeo.in_form='true'
  left join [dbo].[Objects] eo on eeo.object_id=eo.Id
  left join [dbo].[EventOrganizers] eeorg on ee.Id=eeorg.event_id and eeorg.[main]='true'
  left join [dbo].[Organizations] eeorga on eeorg.organization_id=eeorga.Id

  --e

WHERE
  aqt.[user_id] = @user_id
  AND aqt.is_active = 1
  AND #filter_columns#
      #sort_columns#
OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY;

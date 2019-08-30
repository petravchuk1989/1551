

if( select active from [Events] where Id = @Id) = 'false'
begin
	return
end
else
begin  
  UPDATE [dbo].[Events]
      SET   
            [real_end_date]= @real_end_date
		   ,[active]= N'false'
           ,[user_id]= @user_id
           ,[executor_comment]=@coment_executor
		WHERE Id = @Id
	--select 'Update is good'

	update Questions
		set question_state_id = 5
		,[edit_date] = GETUTCDATE()
        ,[user_edit_id] = @user_id
	where Id in (
				select  q.Id
				FROM [Events] as e
    				left join EventQuestionsTypes as eqt on eqt.event_id = e.Id 
    				left join [EventObjects] as eo on eo.event_id = e.Id
    				left join Questions as q on q.question_type_id = eqt.question_type_id and q.[object_id] = eo.[object_id]
    				left join Assignments on Assignments.Id = q.last_assignment_for_execution_id
    				left join Organizations on Organizations.Id = Assignments.executor_organization_id
				where e.Id = @Id
				and q.answer_form_id = 2
				and q.registration_date >= e.registration_date
				and eqt.[is_hard_connection] = 1
	)
	 
	 update Assignments 
	 set assignment_state_id = 3 --OnCheck
		,user_edit_id = @user_id
		,[LogUpdated_Query] = N'ak_CloseEvent_ROW39'
		,edit_date = GETUTCDATE()
		,AssignmentResultsId = 4 -- Done
		,AssignmentResolutionsId = null	 where Id in (select Id from Assignments 
				where question_id in (select  q.Id
										FROM [Events] as e
    										left join EventQuestionsTypes as eqt on eqt.event_id = e.Id 
    										left join [EventObjects] as eo on eo.event_id = e.Id
    										left join Questions as q on q.question_type_id = eqt.question_type_id and q.[object_id] = eo.[object_id]
    										left join Assignments on Assignments.Id = q.last_assignment_for_execution_id
    										left join Organizations on Organizations.Id = Assignments.executor_organization_id
										where e.Id = @Id
										and q.answer_form_id = 2
										and q.registration_date >= e.registration_date
										and eqt.[is_hard_connection] = 1)
					and assignment_state_id <> 5 and assignment_type_id = 1
				)


	update AssignmentConsiderations
	 set user_edit_id = @user_id
		,edit_date = GETUTCDATE()
		,assignment_result_id = 4 -- Done
		,assignment_resolution_id = null
		,short_answer =  @coment_executor
	 where Id in (select current_assignment_consideration_id from Assignments 
				where question_id in (select  q.Id
										FROM [Events] as e
    										left join EventQuestionsTypes as eqt on eqt.event_id = e.Id 
    										left join [EventObjects] as eo on eo.event_id = e.Id
    										left join Questions as q on q.question_type_id = eqt.question_type_id and q.[object_id] = eo.[object_id]
    										left join Assignments on Assignments.Id = q.last_assignment_for_execution_id
    										left join Organizations on Organizations.Id = Assignments.executor_organization_id
										where e.Id = @Id
										and q.answer_form_id = 2
										and q.registration_date >= e.registration_date
										and eqt.[is_hard_connection] = 1)
					and assignment_state_id <> 5 and assignment_type_id = 1
				)
	
end



/*
update [CRM_1551_Analitics].[dbo].[Events]
  set [active]=N'false'
  where id=@Id
  
  UPDATE [dbo].[Events]
      SET   
            -- [name]= @event_name
        --   ,[event_type_id]= @event_type_id
        --   ,[question_type_id]= @question_type_id удалена по заявке CRM1551-276
        --   ,[gorodok_id]= @gorodok_id
        --   ,[start_date]= @start_date
           ,[plan_end_date]= @plan_end_date
           ,[real_end_date]= @real_end_date
           --,[active]= @active
           ,[comment]= @comment
           ,[area]  = @area
        --   ,[user_id]= @user_id
           ,[audio_start_date]= @audio_start_date
           ,[audio_end_date]= @audio_end_date
           ,[Standart_audio]= @Standart_audio
           ,[say_liveAddress_id]= @say_liveAddress_id
           ,[say_organization_id]  = @say_organization_id
           ,[say_phone_for_information] = @say_phone_for_information
           ,[phone_for_information] = @phone_for_information
           ,[say_plan_end_date]= @say_plan_end_date
           ,[audio_on] = @audio_on
           ,[executor_comment]=@coment_executor
           --,[File] = @file
		WHERE Id = @Id

update EventObjects set object_id = @object_id
	where event_id = @Id
	
update [dbo].[EventOrganizers]
       set  [organization_id] = @executor_id
where event_id = @Id

*/
-- declare @UserId nvarchar(128) = N'29796543-b903-48a6-9399-4840f6eac396'
-- declare @Group nvarchar(100) = N'event'



if @Group = N'question'
begin
	  SELECT [AttentionQuestionAndEvent].Id
	  		,[Questions].Id as [ReferenceId]
			,[Questions].registration_number as [RegistrationNumber] /*Номер*/
			,[Questions].registration_date as [RegistrationDate] /*Дата реєстрації*/
			,[QuestionTypes].[name] as [TypeName] /*Тип*/
			,[QuestionStates].[name] as [StateName] /*Стан*/
			,[Organizations].[name] as [OrganizationName] /*Виконавець*/
			,[Questions].control_date as [ControlDate] /*Дата контролю*/
			,Notif.[Text] as [NotificationText] /*Остання нотифікація*/
			,Notif.[CreatedOn] as [NotificationCreatedAt] /*Дата відправки*/
 	  FROM [dbo].[AttentionQuestionAndEvent]
	  inner join [dbo].[Questions] on [Questions].Id = [AttentionQuestionAndEvent].[question_id]
	  inner join [dbo].[QuestionTypes] on [QuestionTypes].Id = [Questions].[question_type_id]
	  inner join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].[question_state_id]
	  inner join [dbo].[Assignments] on [Assignments].Id = [Questions].[last_assignment_for_execution_id]
	  inner join [dbo].[Organizations] on [Organizations].Id = [Assignments].[executor_organization_id]
	  left join (
					select [Url], [CreatedOn], [Text]
					from [CRM_1551_System].[dbo].[Notification] 
					where Id in (
						select max(t1.Id) as MaxId 
						from [CRM_1551_System].[dbo].[Notification] as t1
						where t1.[Url] is not null
						group by t1.[Url]
					)
	  ) as Notif on Notif.[Url] = (N'/sections/Questions/edit/'+rtrim([AttentionQuestionAndEvent].[question_id]))
	  where [AttentionQuestionAndEvent].[user_id] = @UserId
	  and [AttentionQuestionAndEvent].[question_id] is not null
end


if @Group = N'assignment'
begin
	  SELECT [AttentionQuestionAndEvent].Id
	  		,[Assignments].Id as [ReferenceId]
			,[Questions].registration_number as [RegistrationNumber] /*Номер*/
			,[Assignments].registration_date as [RegistrationDate] /*Дата реєстрації*/
			,[QuestionTypes].[name] as [TypeName] /*Тип*/
			,[AssignmentStates].[name] as [StateName] /*Стан*/
			,[Organizations].[name] as [OrganizationName] /*Виконавець*/
			,[Assignments].[execution_date] as [ControlDate] /*Дата контролю*/
			,Notif.[Text] as [NotificationText] /*Остання нотифікація*/
			,Notif.[CreatedOn] as [NotificationCreatedAt] /*Дата відправки*/
 	  FROM [dbo].[AttentionQuestionAndEvent]
	  inner join [dbo].[Assignments] on [Assignments].Id = [AttentionQuestionAndEvent].[assignment_id]
	  inner join [dbo].[AssignmentStates] on [AssignmentStates].Id = [Assignments].[assignment_state_id]
	  inner join [dbo].[Questions] on [Questions].Id = [Assignments].[question_id]
	  inner join [dbo].[QuestionTypes] on [QuestionTypes].Id = [Questions].[question_type_id]
	  inner join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].[question_state_id]
	  inner join [dbo].[Organizations] on [Organizations].Id = [Assignments].[executor_organization_id]
	  left join (
					select [Url], [CreatedOn], [Text]
					from [CRM_1551_System].[dbo].[Notification] 
					where Id in (
						select max(t1.Id) as MaxId 
						from [CRM_1551_System].[dbo].[Notification] as t1
						where t1.[Url] is not null
						group by t1.[Url]
					)
	  ) as Notif on Notif.[Url] = (N'/sections/Assignments/edit/'+rtrim([AttentionQuestionAndEvent].[assignment_id]))
	  where [AttentionQuestionAndEvent].[user_id] = @UserId
	  and [AttentionQuestionAndEvent].[assignment_id] is not null
end


if @Group = N'event'
begin
	  SELECT [AttentionQuestionAndEvent].Id
	  		,[Events].Id as [ReferenceId]
			,[Events].Id as [RegistrationNumber] /*Номер*/
			,[Events].[start_date] as [RegistrationDate] /*Дата реєстрації*/
			,[Event_Class].[name] as [TypeName] /*Тип*/
			,case when isnull([Events].[active],0) = 1 then N'В роботі' else N'Закрито' end as [StateName] /*Стан*/
			,[Organizations].[name] as [OrganizationName] /*Виконавець*/
			,[Events].[plan_end_date] as [ControlDate] /*Дата контролю*/
			,Notif.[Text] as [NotificationText] /*Остання нотифікація*/
			,Notif.[CreatedOn] as [NotificationCreatedAt] /*Дата відправки*/
 	  FROM [dbo].[AttentionQuestionAndEvent]
	  inner join [dbo].[Events] on [Events].Id = [AttentionQuestionAndEvent].[event_id]
	  left join [dbo].[Event_Class] on [Event_Class].Id = [Events].[event_class_id]
	  left join [dbo].[EventOrganizers] on [EventOrganizers].event_id = [Events].[Id] and isnull([EventOrganizers].[main],0) = 1
	  inner join [dbo].[Organizations] on [Organizations].Id = [EventOrganizers].[organization_id]
	  left join (
					select [Url], [CreatedOn], [Text]
					from [CRM_1551_System].[dbo].[Notification] 
					where Id in (
						select max(t1.Id) as MaxId 
						from [CRM_1551_System].[dbo].[Notification] as t1
						where t1.[Url] is not null
						group by t1.[Url]
					)
	  ) as Notif on Notif.[Url] = (N'/sections/Events/edit/'+rtrim([AttentionQuestionAndEvent].[event_id]))
	  where [AttentionQuestionAndEvent].[user_id] = @UserId
	  and [AttentionQuestionAndEvent].[event_id] is not null
end




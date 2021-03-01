
--declare @phone_nunber nvarchar(50)=N'044-564-96-50'; 

IF object_id('tempdb..#temp_main_info') IS NOT NULL DROP TABLE #temp_main_info

  select [Positions].Id, [Positions].name Positions_Name
  
  into #temp_main_info
  from [CRM_1551_Analitics].[dbo].[Positions]
  where --charindex(@phone_nunber, [Positions].phone_number, 1)>0
  charindex(@phone_nunber, 
  replace([Positions].[phone_number], N'-', N'')
  , 1)>0


select [Assignments].Id, [Questions].registration_number Registration_Number, [AssignmentStates].name [AssignmentState], [QuestionTypes].name QuestionType,
  STUFF(N'. '+ISNULL([StreetTypes].shortname+N' ', N'')+ISNULL([Streets].name, N'')+ISNULL(N'. '+[Buildings].name, N'')+ISNULL(N'. П. '+[Questions].entrance, N'')+ISNULL(N'. кв. '+[Questions].flat, N''),1,2,N'') Place_Problem, 
  temp_main_info.Positions_Name,
  [Assignments].execution_date Control_Date, [AssignmentConsiderations].[short_answer] Comment,
  [Applicants].full_name Applicant_Name, [Applicants].ApplicantAdress, [Questions].question_content Content
  ,[Assignments].[Registration_date]
  from [CRM_1551_Analitics].[dbo].[Assignments]
  inner join [CRM_1551_Analitics].[dbo].[Questions] on [Assignments].question_id=[Questions].Id
  inner join #temp_main_info temp_main_info on [Assignments].executor_person_id=temp_main_info.Id 
  inner join [CRM_1551_Analitics].[dbo].[AssignmentStates] on [Assignments].assignment_state_id=[AssignmentStates].Id
  left join [CRM_1551_Analitics].[dbo].[QuestionTypes] on [Questions].question_type_id=[QuestionTypes].Id
  left join [CRM_1551_Analitics].[dbo].[Appeals] on [Questions].appeal_id=[Appeals].Id
  left join [CRM_1551_Analitics].[dbo].[Applicants] on [Appeals].applicant_id=[Applicants].Id
  left join [CRM_1551_Analitics].[dbo].[AssignmentConsiderations] on [Assignments].current_assignment_consideration_id=[AssignmentConsiderations].Id
  left join [CRM_1551_Analitics].[dbo].[Objects] on [Questions].object_id=[Objects].Id
  left join [CRM_1551_Analitics].[dbo].[Buildings] on [Objects].builbing_id=[Buildings].Id
  left join [CRM_1551_Analitics].[dbo].[Streets] on [Buildings].street_id=[Streets].Id
  left join [CRM_1551_Analitics].[dbo].[StreetTypes] on [Streets].street_type_id=[StreetTypes].Id
  where [Assignments].[assignment_state_id] in (1/*Зареєстровано*/, 2/*В роботі*/)
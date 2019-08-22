 -- declare @ids nvarchar(200)=N'1,2,3';
  --declare @user nvarchar(200)=N'Вася'
  declare @t nvarchar(max)=N'

  update [CRM_1551_Analitics].[dbo].[Assignments]
  set assignment_state_id=3
  ,[AssignmentResultsId]=4 
  ,[AssignmentResolutionsId]=4
  ,edit_date = GETUTCDATE()
  ,user_edit_id = N'''+ @user + N'''
  ,[LogUpdated_Query] = N''Coordinator_Button_Prozvon_Row11'''+N'
  where Id in ( '+ @ids+N')'+
  N'
  
  update [CRM_1551_Analitics].[dbo].[AssignmentConsiderations]
  set [assignment_result_id]=4 
  ,[assignment_resolution_id]=4 
  ,edit_date = GETUTCDATE()
  ,user_edit_id = N'''+ @user + N'''
--   where assignment_id=in ( '+ @ids+N')
  where Id in ( select current_assignment_consideration_id from Assignments where Id in ('+@Ids+N') )
  '
  
  
  
  --select @t
  exec (@t)
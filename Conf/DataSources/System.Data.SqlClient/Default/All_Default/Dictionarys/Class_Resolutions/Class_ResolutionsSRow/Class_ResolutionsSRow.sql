
select cr.Id
 ,cr.[assignment_class_id]
 ,cr.[name]
 ,cr.[event_class_id]
 ,cr.[create_assignment_class_id]
 ,cr.[assignment_result_id]
 ,cr.[assignment_resolution_id]
 ,stuff(ISNULL(N' '+[User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'')+ISNULL(N' '+[User].[Patronymic], N''), 1,1,N'') [user_name]
 ,stuff(ISNULL(N' '+[User_Edit].[LastName], N'')+ISNULL(N' '+[User_Edit].[FirstName], N'')+ISNULL(N' '+[User_Edit].[Patronymic], N''), 1,1,N'') [user_edit_name]
 ,cr.[create_date]
 ,cr.[edit_date]

 ,ac.name [assignment_class_name]
 ,acc.name [create_assignment_class_name]
 ,[AssignmentResults].name [assignment_result_name]
 ,[AssignmentResolutions].name [assignment_resolution_name]
 ,[Event_Class].name [event_class_name]
 ,cr.Id class_resolutions_Id
 from [dbo].[Class_Resolutions] cr
 left join [dbo].[Assignment_Classes] ac on cr.assignment_class_id=ac.Id
 left join #system_database_name#.[dbo].[User] [User_Edit] on cr.user_edit_id=[User_Edit].[UserId]
 left join #system_database_name#.[dbo].[User] on cr.user_id=[User].[UserId]
 left join [dbo].[Assignment_Classes] acc on cr.[create_assignment_class_id]=acc.Id
 left join [dbo].[AssignmentResults] on cr.assignment_result_id=[AssignmentResults].Id
 left join [dbo].[AssignmentResolutions] on cr.assignment_resolution_id=[AssignmentResolutions].Id
 left join [dbo].[Event_Class] on cr.event_class_id=[Event_Class].Id
 where cr.Id=@Id
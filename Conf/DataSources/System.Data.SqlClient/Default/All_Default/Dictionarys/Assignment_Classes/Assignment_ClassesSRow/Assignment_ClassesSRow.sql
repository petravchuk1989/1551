SELECT ac.[Id]
      ,ac.[name]
      ,ac.[execution_term]
      ,ac.[create_date]
      ,stuff(ISNULL(N' '+[User].[LastName], N'')+ISNULL(N' '+[User].[FirstName], N'')+ISNULL(N' '+[User].[Patronymic], N''), 1,1,N'') [user_name]
	  ,ac.[edit_date]
      ,stuff(ISNULL(N' '+[User_Edit].[LastName], N'')+ISNULL(N' '+[User_Edit].[FirstName], N'')+ISNULL(N' '+[User_Edit].[Patronymic], N''), 1,1,N'') [user_edit_name]
      ,ac.[Id] assignment_classes_Id
  from [dbo].[Assignment_Classes] ac
  left join #system_database_name#.[dbo].[User] [User_Edit] on ac.user_edit_id=[User_Edit].[UserId]
  left join #system_database_name#.[dbo].[User] on ac.user_id=[User].[UserId]
  --left join 
  where Id=@Id
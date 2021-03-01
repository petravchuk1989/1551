insert into   [dbo].[FiltersForControler]
  (
  [user_id]
      ,[district_id]
      ,[questiondirection_id]
	  ,[organization_id]
      ,[create_date]
  )

  select 
  @user_id
      ,@district_id
      ,@questiondirection_id
	  ,@department_id
      ,getutcdate()
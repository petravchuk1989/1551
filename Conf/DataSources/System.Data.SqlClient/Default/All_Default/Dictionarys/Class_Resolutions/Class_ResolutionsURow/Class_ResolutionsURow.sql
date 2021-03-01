update [dbo].[Class_Resolutions]
set [assignment_class_id]=@assignment_class_id
      ,[name]=@name
      ,[event_class_id]=@event_class_id
      ,[create_assignment_class_id]=@create_assignment_class_id
      ,[assignment_result_id]=@assignment_result_id
      ,[assignment_resolution_id]=@assignment_resolution_id
      --,[create_date]=getutcdate()
      --,[user_id]=@user_id
      ,[edit_date]=getutcdate()
      ,[user_edit_id]=@user_id
where Id=@Id
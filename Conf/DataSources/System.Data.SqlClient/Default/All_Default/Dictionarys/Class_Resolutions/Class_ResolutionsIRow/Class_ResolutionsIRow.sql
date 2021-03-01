declare @new_id int;
  declare @output table (Id int);


insert into [dbo].[Class_Resolutions]
  (
  [assignment_class_id]
      ,[name]
      ,[event_class_id]
      ,[create_assignment_class_id]
      ,[assignment_result_id]
      ,[assignment_resolution_id]
      ,[create_date]
      ,[user_id]
      ,[edit_date]
      ,[user_edit_id]
  )

output [inserted].[Id] into @output (Id)

  select @assignment_class_id
      ,@name
      ,@event_class_id
      ,@create_assignment_class_id
      ,@assignment_result_id
      ,@assignment_resolution_id
      ,getutcdate() [create_date]
      ,@user_id
      ,getutcdate() [edit_date]
      ,@user_id

      set @new_id=(select top 1 Id from @output )

      select @new_id	as [Id]
return;
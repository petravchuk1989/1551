insert into [dbo].[PersonExecutorChooseObjects]
 ([person_executor_choose_id]
     ,[object_id]
     ,[user_id]
     ,[create_date]
     ,[user_edit_id]
     ,[edit_date])

	select @person_executor_choose_id
      ,[Objects].Id [object_id]
      ,@user_id
      ,getutcdate() [create_date]
      ,@user_id
      ,getutcdate() [edit_date]
	from [dbo].[Objects]
      left join [dbo].[PersonExecutorChooseObjects] on [Objects].Id=[PersonExecutorChooseObjects].object_id and [PersonExecutorChooseObjects].person_executor_choose_id=@person_executor_choose_id
      where [Objects].district_id=@district_id and [PersonExecutorChooseObjects].Id is null

declare @new_id int;
  declare @output table (Id int);

insert into [dbo].[Assignment_Classes]
  (
  [name]
      ,[execution_term]
      ,[create_date]
      ,[user_id]
      ,[edit_date]
      ,[user_edit_id]
  )

  output [inserted].[Id] into @output (Id)

  select @name
      ,@execution_term
      ,getutcdate() create_date
      ,@user_id
      ,getutcdate() edit_date
      ,@user_id [user_edit_id]


    set @new_id=(select top 1 Id from @output )

      select @new_id	as [Id]
return;
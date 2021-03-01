declare @output table (Id int)
declare @new_id int;

insert into [CRM_1551_Site_Integration].[dbo].[ReportsInfo]
  (
  [reportcode]
      ,[diagramcode]
      ,[valuecode]
      ,[content]
      ,[user_id]
      ,[add_date]
      ,[user_edit_id]
      ,[edit_date]
 )

output inserted.Id into @output(Id)

 select @reportcode
      ,@diagramcode
      ,@valuecode
      ,@content
      ,@user_id
      ,getutcdate()
      ,@user_id
      ,getutcdate()

set @new_id = (select top 1 Id from @output)
select @new_id Id
return;
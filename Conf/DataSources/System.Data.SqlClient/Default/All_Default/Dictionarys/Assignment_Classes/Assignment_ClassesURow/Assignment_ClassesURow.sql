update [dbo].[Assignment_Classes]
set [name]=@name, 
[execution_term]=@execution_term,
edit_date=getutcdate(),
[user_edit_id]=@user_id 
where Id=@Id
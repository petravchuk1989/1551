
INSERT INTO [dbo].[EventFiles]
           ([event_id]
           ,[name]
           ,[file]
           ,[user]
           ,[add_date]
           ,[edit_user_id]
           ,[edit_date])
     VALUES
           (@event_id
           ,@name
           ,@file
           ,@user
           ,GETUTCDATE()
           ,@user
           ,GETUTCDATE()
           )



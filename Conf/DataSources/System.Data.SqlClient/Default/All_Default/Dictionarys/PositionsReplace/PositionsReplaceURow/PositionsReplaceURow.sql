update [dbo].[PositionsReplace]
	set [position_id]=@position_id
      ,[replace_position_id]=@replace_position_id
      ,[date_from]=@date_from
      ,[date_to]=@date_to
      --,[create_date]
      --,[user_id]=@user_id
      ,[edit_date]=getutcdate()
      ,[user_edit_id]=@user_Id
	where Id=@Id
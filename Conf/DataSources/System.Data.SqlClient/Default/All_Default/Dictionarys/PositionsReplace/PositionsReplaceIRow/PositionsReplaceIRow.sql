insert into [dbo].[PositionsReplace]
  (
  [position_id]
      ,[replace_position_id]
      ,[date_from]
      ,[date_to]
      ,[create_date]
      ,[user_id]
      ,[edit_date]
      ,[user_edit_id]
  )
  select
  @position_id
      ,@replace_position_id
      ,@date_from
      ,@date_to
      ,getutcdate()
      ,@user_id
      ,getutcdate()
      ,@user_id
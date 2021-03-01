select [PositionsHelpers].Id, [PositionsHelpers].[main_position_id], [Positions1].name main_position_name,
  [PositionsHelpers].helper_position_id, [Positions2].name helper_position_name,
  1 [type_id], N'помічник' [type_name],
  [PositionsHelpers].[edit_date], [User].UserName
  from   [dbo].[PositionsHelpers]
  left join   [dbo].[Positions] [Positions1] on [PositionsHelpers].[main_position_id]=[Positions1].Id
  left join   [dbo].[Positions] [Positions2] on [PositionsHelpers].[helper_position_id]=[Positions2].Id
  left join [#system_database_name#].[dbo].[User] on [PositionsHelpers].user_id=[User].UserId
  where [PositionsHelpers].Id=@id
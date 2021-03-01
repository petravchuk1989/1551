  select [PositionsReplace].Id, [PositionsReplace].date_from, [PositionsReplace].date_to, [PositionsReplace].position_id, [Positions].Id replace_position_id, [Positions].position replace_position_name
  from [dbo].[PositionsReplace]
  inner join [dbo].[Positions] on [PositionsReplace].replace_position_id=[Positions].Id
  where [PositionsReplace].Id=@Id
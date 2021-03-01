select [PositionsReplace].Id, [PositionsReplace].date_from, [PositionsReplace].date_to, [Positions].position
  from [dbo].[PositionsReplace]
  inner join [dbo].[Positions] on [PositionsReplace].replace_position_id=[Positions].Id
    where [PositionsReplace].position_id=@position_id 
    and
  #filter_columns#
  --#sort_columns#
  order by 1
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
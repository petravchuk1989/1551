--declare @position_id int=94; 

--declare @position_id int;

select Id, name, [type]
from (
  select [PositionsHelpers].Id, [Positions2].[name], N'помічник' [type]
  from   [dbo].[PositionsHelpers]
  inner join   [dbo].[Positions] on [PositionsHelpers].[main_position_id]=[Positions].Id
  inner join   [dbo].[Positions] [Positions2] on [PositionsHelpers].helper_position_id=[Positions2].Id
  where [Positions].Id=@position_id
  union all
  select [PositionsHelpers].Id, [Positions2].[name], N'допомагає' [type]
  from   [dbo].[PositionsHelpers]
  inner join   [dbo].[Positions] on [PositionsHelpers].[helper_position_id]=[Positions].Id
  inner join   [dbo].[Positions] [Positions2] on [PositionsHelpers].main_position_id=[Positions2].Id
  where [Positions].Id=@position_id
  
  ) a
   where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
 
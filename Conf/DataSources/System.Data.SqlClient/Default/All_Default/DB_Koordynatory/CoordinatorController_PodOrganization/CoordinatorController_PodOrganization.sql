select Id, [short_name]
  from   [dbo].[Organizations]
  where [programworker]=N'true'
--   and #filter_columns#
--   #sort_columns#
--  offset @pageOffsetRows rows fetch next @pageLimitRows rows only
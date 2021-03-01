select id
, name
-- ,short_name
,concat([short_name], ' ( ' + address + ')') as [short_name]
  from   [dbo].[Organizations]
 where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only

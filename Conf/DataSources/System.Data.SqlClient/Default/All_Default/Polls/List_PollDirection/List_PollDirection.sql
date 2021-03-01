select [Id], [Name] 
from [dbo].[PollDirection]
where #filter_columns#
#sort_columns#
offset @pageOffsetRows rows fetch next @pageLimitRows rows only
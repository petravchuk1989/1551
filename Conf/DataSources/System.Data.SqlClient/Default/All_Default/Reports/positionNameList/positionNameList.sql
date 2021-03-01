SELECT Id, position + '(' + name + ')' as Name
 FROM   [dbo].[Positions] 
 where 
	 #filter_columns#
     #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
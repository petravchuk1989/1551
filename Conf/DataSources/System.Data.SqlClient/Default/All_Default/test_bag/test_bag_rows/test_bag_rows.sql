SELECT 
	Id,
	SystemUserId,
  SystemUser
FROM dbo.Test_Bag 
WHERE
  #filter_columns#
  #sort_columns#
  OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY;
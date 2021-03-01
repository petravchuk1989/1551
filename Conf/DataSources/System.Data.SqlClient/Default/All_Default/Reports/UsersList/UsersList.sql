SELECT
	u.UserId AS Id,
	u.LastName + isnull(' ' + u.FirstName, N'') + isnull(' ' + u.Patronymic, N'') AS Operator
FROM
	[#system_database_name#].[dbo].[User] u 
	--    CRM_1551_System.dbo.[User] u
WHERE
	#filter_columns#
	#sort_columns#
	OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
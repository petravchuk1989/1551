
SELECT
	Id,
	[add_date],
	[name] AS [Name],
	[File]
FROM [dbo].[EventFiles]
WHERE Id = @Id

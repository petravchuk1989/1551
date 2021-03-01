-- DECLARE @Id INT = NULL,
-- 		@Name NVARCHAR(500);

SELECT
	qt.[Id],
	qt.[Name],
	qt.[question_type_id] AS [parentId],
	pqt.[name] AS [parentName],
	qt.[Index]
FROM
	dbo.[QuestionTypes] qt
	LEFT JOIN dbo.[QuestionTypes] pqt ON qt.question_type_id = pqt.Id
WHERE
	qt.Id = IIF(@Id IS NULL, qt.Id, @Id)
AND qt.[name] = IIF(@Name IS NULL, qt.[name], @Name) 
AND #filter_columns#
	#sort_columns#
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
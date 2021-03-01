-- DECLARE @Id INT = 2971516,
-- 		@table NVARCHAR(MAX) = N'AssignmentConsDocFiles';

IF (@table = N'AssignmentConsDocFiles')
BEGIN
	SELECT
		doc_file.[Id],
		doc_file.[name]
	FROM [dbo].[Assignments] ass WITH (NOLOCK)
	INNER JOIN [dbo].[AssignmentConsiderations] cons WITH (NOLOCK) ON cons.[assignment_id] = ass.[Id]
	INNER JOIN [dbo].[AssignmentConsDocuments] cons_doc WITH (NOLOCK) ON cons_doc.[assignment_сons_id] = cons.[Id]
	INNER JOIN [dbo].[AssignmentConsDocFiles] doc_file WITH (NOLOCK) ON doc_file.[assignment_cons_doc_id] = cons_doc.[Id]
	WHERE ass.[Id] = @Id
	ORDER BY 1
	OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
END

ELSE IF (@table = N'QuestionDocFiles')
BEGIN
	SELECT
		q_doc_file.[Id],
		q_doc_file.[name]
	FROM [dbo].[Assignments] ass WITH (NOLOCK)
	INNER JOIN [dbo].[QuestionDocFiles] q_doc_file WITH (NOLOCK) ON q_doc_file.[question_id] = ass.[question_id]
	WHERE ass.[Id] = @Id
	ORDER BY 1
	OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
END

ELSE IF (@table = N'EventFiles')
BEGIN
	SELECT 
		[Id],
		[name]
	FROM [dbo].[EventFiles] WITH (NOLOCK)
	WHERE [event_id] = @Id
	ORDER BY 1
	OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
END
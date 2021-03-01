-- DECLARE @appeal_id INT = 7346694,
-- 		    @question_id INT = 7747505;

IF (@question_id IS NOT NULL)
BEGIN
SELECT
  [AssignmentConsDocFiles].[Id] AS [AssignmentConsDocId],
  [AssignmentConsDocFiles].[name] AS [AssignmentConsDocName],
  [AssignmentConsDocFiles].[File] AS [AssignmentConsDocFile],
  [Questions].Id AS Question_id
FROM
  [dbo].[AssignmentConsDocFiles] [AssignmentConsDocFiles]
  LEFT JOIN [dbo].[AssignmentConsDocuments] [AssignmentConsDocuments] ON [AssignmentConsDocFiles].assignment_cons_doc_id = [AssignmentConsDocuments].Id
  LEFT JOIN [dbo].[AssignmentConsiderations] [AssignmentConsiderations] ON [AssignmentConsDocuments].assignment_сons_id = [AssignmentConsiderations].Id
  LEFT JOIN [dbo].[Assignments] [Assignments] ON [AssignmentConsiderations].assignment_id = [Assignments].Id
  LEFT JOIN [dbo].[Questions] [Questions] ON [Assignments].question_id = [Questions].Id
WHERE
  [Questions].Id = @question_id; 
END
ELSE IF (@question_id IS NULL) AND 
		(@appeal_id IS NOT NULL)
BEGIN
SELECT
  [AssignmentConsDocFiles].[Id] AS [AssignmentConsDocId],
  [AssignmentConsDocFiles].[name] AS [AssignmentConsDocName],
  [AssignmentConsDocFiles].[File] AS [AssignmentConsDocFile],
  [Questions].Id AS Question_id
FROM
  [dbo].[AssignmentConsDocFiles] [AssignmentConsDocFiles]
  LEFT JOIN [dbo].[AssignmentConsDocuments] [AssignmentConsDocuments] ON [AssignmentConsDocFiles].assignment_cons_doc_id = [AssignmentConsDocuments].Id
  LEFT JOIN [dbo].[AssignmentConsiderations] [AssignmentConsiderations] ON [AssignmentConsDocuments].assignment_сons_id = [AssignmentConsiderations].Id
  LEFT JOIN [dbo].[Assignments] [Assignments] ON [AssignmentConsiderations].assignment_id = [Assignments].Id
  LEFT JOIN [dbo].[Questions] [Questions] ON [Assignments].question_id = [Questions].Id
WHERE
  [Questions].appeal_id = @appeal_id;
END
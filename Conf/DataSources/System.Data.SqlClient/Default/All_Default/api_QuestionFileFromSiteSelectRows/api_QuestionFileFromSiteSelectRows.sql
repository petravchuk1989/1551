select [QuestionDocFiles].Id as [QuestionFileId], 
	   [QuestionDocFiles].name  as [QuestionFileName], 
	   [QuestionDocFiles].[File] as [QuestionFile]
  from    [dbo].[Questions]
--   inner join   [dbo].[QuestionDocuments] on [QuestionDocuments].question_id=[Questions].Id  
  inner join   [dbo].[QuestionDocFiles] on [QuestionDocFiles].question_id=[Questions].Id
  where [Questions].appeal_id=@appeal_id
--   and #filter_columns#
--   #sort_columns#
--  offset @pageOffsetRows rows fetch next @pageLimitRows rows only
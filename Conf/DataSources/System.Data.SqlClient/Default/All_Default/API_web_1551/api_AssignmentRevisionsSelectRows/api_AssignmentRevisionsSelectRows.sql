  select [AssignmentConsiderations].assignment_id Id, [AssignmentRevisions].grade, [AssignmentRevisions].grade_comment
  from   [dbo].[AssignmentRevisions]
  inner join   [dbo].[AssignmentConsiderations] on [AssignmentRevisions].assignment_consideration_іd=[AssignmentConsiderations].Id
  where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
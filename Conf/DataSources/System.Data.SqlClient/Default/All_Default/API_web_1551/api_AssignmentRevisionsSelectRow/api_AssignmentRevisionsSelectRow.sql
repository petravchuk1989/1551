select [AssignmentConsiderations].Id, [AssignmentRevisions].grade, [AssignmentRevisions].grade_comment
  from   [dbo].[AssignmentRevisions]
  inner join   [dbo].[AssignmentConsiderations] on [AssignmentRevisions].assignment_consideration_іd=[AssignmentConsiderations].Id
  where [AssignmentConsiderations].assignment_id=@Id
select 0 [Id], N'Усі' [name]
  union all
  select [Id], [name]
  from   [dbo].[QuestionTypes]
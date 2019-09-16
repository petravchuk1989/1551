with [Organisations] as (
    select
       t1.[Id]
      ,t1.[Name]
      ,t1.[ParentId]
	  ,t1.comments
      ,CONVERT(nvarchar(max), isnull(t1.[Name],N'')) as [Path]
    from (select [Id] ,[name] as [Name] ,[question_type_id] as [ParentId], comments
	      from [dbo].[QuestionTypes] where active = 1) as t1
    where [ParentId] is NULL
    union all
    select
       t1.[Id]
      ,t1.[Name]
      ,t1.[ParentId]
	  ,t1.comments
      ,CONVERT(nvarchar(max), isnull([Path],N'') + N'\' + isnull(t1.[Name],N'')) as [Path]
    from (select [Id] ,[name] as [Name] ,[question_type_id] as [ParentId], comments
	      from [dbo].[QuestionTypes] where active = 1) as t1
    join [Organisations] on [Organisations].[Id] = t1.[ParentId]
)
select
       [Id]
      ,[Name]
	    ,comments
      ,[Path]
from [Organisations]
where #filter_columns#
#sort_columns#
offset @pageOffsetRows rows fetch next @pageLimitRows rows only
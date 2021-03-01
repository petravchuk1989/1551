select Id, [File], [FileName] as [Name]
  from   [dbo].[Events]
  where Id=@id
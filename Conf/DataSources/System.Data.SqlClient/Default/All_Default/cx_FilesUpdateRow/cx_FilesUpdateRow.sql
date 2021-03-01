UPDATE
       [dbo].[Events]
SET
     [File] = @File,
     [FileName] = @Name
WHERE
     Id = @EventId ;
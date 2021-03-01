-- declare @UserId nvarchar(128) = N'29796543-b903-48a6-9399-4840f6eac396'
-- declare @Group nvarchar(100) = N'question'
-- declare @JSON nvarchar(max) = N'[{"Id":28},{"Id":27},{"Id":31}]'


delete from [dbo].[AttentionQuestionAndEvent]
where Id in (
				SELECT [Id]
				FROM OPENJSON ( @JSON )  
				WITH (   
						[Id] Int '$.Id'  
				)
		)
and [user_id] = @UserId
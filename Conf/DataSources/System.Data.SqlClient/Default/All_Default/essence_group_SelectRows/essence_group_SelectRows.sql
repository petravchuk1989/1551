-- declare @UserId nvarchar(128) = N'29796543-b903-48a6-9399-4840f6eac396'



SELECT N'question' as [Group], count(1) as [Value]
  FROM [dbo].[AttentionQuestionAndEvent]
  where [user_id] = @UserId
  and [question_id] is not null
UNION ALL  
SELECT N'assignment' as [Group], count(1) as [Value]
  FROM [dbo].[AttentionQuestionAndEvent]
  where [user_id] = @UserId
  and [assignment_id] is not null
UNION ALL   
SELECT N'event' as [Group], count(1) as [Value]
  FROM [dbo].[AttentionQuestionAndEvent]
  where [user_id] = @UserId
  and [event_id] is not null
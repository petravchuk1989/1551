  --DECLARE @userId NVARCHAR(128) = N'646d6b5e-9f27-4764-9612-f18d04fea509',
  --		 @eventId INT = 309;

DECLARE @EventObjects_Row NVARCHAR(MAX) = 
	STUFF((SELECT ', '+ [name] 
           FROM [dbo].[Objects]
		   WHERE [Id] IN (SELECT 
							  [object_id] 
						  FROM dbo.[EventObjects] 
						  WHERE [event_id] = @eventId)
           FOR XML PATH('')), 1, 1, '');

DECLARE @is_event_files_exists BIT;
SELECT 
	@is_event_files_exists = 
	IIF(COUNT(1) > 0, 1, 0)
FROM [dbo].[EventFiles]
WHERE [event_id] = @eventId;

DECLARE @event_questions_count INT;
SELECT 
	@event_questions_count = COUNT(1)
FROM [dbo].[Questions]
WHERE [event_id] = @eventId;

DECLARE @event_assignments_array NVARCHAR(MAX);
DECLARE @assigments_tab TABLE (Id INT, registration_number NVARCHAR(50));
INSERT INTO @assigments_tab
SELECT 
	ass.[Id],
	q.[registration_number]
FROM [dbo].[Assignments] ass
INNER JOIN [dbo].[Questions] q ON q.[Id] = ass.[question_id]
WHERE ass.[my_event_id] = @eventId;

SET @event_assignments_array = (
SELECT 
	[Id],
	[registration_number]
FROM @assigments_tab
FOR JSON AUTO,
INCLUDE_NULL_VALUES);


SELECT 
DISTINCT
	e_class.[name] AS [class_name],
	e_type.[name] AS [type_name],
	@EventObjects_Row AS [event_object],
	org.[short_name] AS [organization_name],
	e.[comment],
	e.[start_date],
	e.[plan_end_date],
	e.[real_end_date],
	e.[executor_comment],
	@is_event_files_exists AS [event_files_exists],
	@event_questions_count AS [event_questions_count],
	@event_assignments_array AS [event_assignments],
	case 
		when [AttentionQuestionAndEvent].event_id is not null then 1
		else 0 end active_subscribe
FROM [dbo].[Events] e
LEFT JOIN [dbo].[EventObjects] e_obj ON e_obj.[event_id] = e.[Id] 
LEFT JOIN [dbo].[Event_Class] e_class ON e_class.[Id] = e.[event_class_id]
LEFT JOIN [dbo].[EventTypes] e_type ON e_type.[Id] = e.[event_type_id]
LEFT JOIN [dbo].[EventOrganizers] e_org ON e_org.[event_id] = e.[Id]
	AND main = 1
LEFT JOIN [dbo].[Organizations] org ON org.[Id] = e_org.[organization_id]
left join [dbo].[AttentionQuestionAndEvent] on e.Id=[AttentionQuestionAndEvent].event_id and [AttentionQuestionAndEvent].user_id=@userId
WHERE e.[Id] = @eventId
ORDER BY 1
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY
;
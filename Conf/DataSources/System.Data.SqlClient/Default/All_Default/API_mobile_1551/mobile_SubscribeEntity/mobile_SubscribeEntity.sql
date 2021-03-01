/*
DECLARE @userId NVARCHAR(128) = N'29796543-b903-48a6-9399-4840f6eac396';
DECLARE @entityId INT = NULL;
DECLARE @entityName NVARCHAR(50) = NULL;
DECLARE @action BIT = 1;
DECLARE @question_type_id INT = NULL;
DECLARE @object_id INT = NULL;
DECLARE @statecode NVARCHAR(50) = 'in_work_assignment';
*/

DECLARE @resultOK TABLE (val NVARCHAR(5));
INSERT INTO @resultOK
SELECT N'OK';

DECLARE @ass_id INT = IIF(@entityName = 'assignment', @entityId, NULL);
DECLARE @que_id INT = IIF(@entityName = 'question', @entityId, NULL);
DECLARE @eve_id INT = IIF(@entityName = 'event', @entityId, NULL);

DECLARE @update_info TABLE (Id INT);
DECLARE @insert_info TABLE (Id INT);
DECLARE @upId INT;

DECLARE @att_id INT;
SELECT 
	@att_id = [Id] 
FROM dbo.[AttentionQuestionAndEvent] 
WHERE [user_id] = @userId
	  AND ISNULL([assignment_id],0) = ISNULL(@ass_id,0)
	  AND ISNULL([question_id],0) = ISNULL(@que_id,0)
	  AND ISNULL([event_id],0) = ISNULL(@eve_id,0)
	  AND ISNULL([question_type_id],0) = ISNULL(@question_type_id,0)
	  AND ISNULL([object_id],0) = ISNULL(@object_id,0)
	  AND ISNULL([statecode],'0') = ISNULL(@statecode,'0');

IF (@action = 1)
BEGIN
	IF (@att_id IS NOT NULL)
	BEGIN
		UPDATE dbo.[AttentionQuestionAndEvent]
			SET [is_active] = 1
		OUTPUT inserted.Id INTO @update_info (Id) 
		WHERE Id = @att_id;
		
		SET @upId = (SELECT TOP 1 [Id] FROM @update_info);
		IF (@upId IS NOT NULL)
		BEGIN 
			SELECT 
				val AS result
			FROM @resultOK
			WHERE #filter_columns#
				ORDER BY 1
			OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
		END
	END 
	ELSE
	BEGIN
	INSERT INTO dbo.[AttentionQuestionAndEvent] ([user_id],
											 [question_id],
											 [assignment_id],
											 [event_id],
											 [question_type_id],
											 [object_id],
											 [statecode],
											 [create_date],
											 [is_active],
											 [ExternalDataSources_id])
						OUTPUT inserted.Id INTO @insert_info (Id) 
						VALUES (@userId,
								IIF(@entityName = N'question', @entityId, NULL),
								IIF(@entityName = N'assignment', @entityId, NULL),
								IIF(@entityName = N'event', @entityId, NULL),
								IIF(@question_type_id IS NOT NULL, @question_type_id, NULL),
								IIF(@object_id IS NOT NULL, @object_id, NULL),
								IIF(@statecode IS NOT NULL, @statecode, NULL),
								GETDATE(),
								1, -- активний
								2  -- Мобільний додаток
								);

	DECLARE @newVal INT = (SELECT TOP 1 [Id] FROM @insert_info);

	IF(@newVal IS NOT NULL)
	BEGIN 
		SELECT 
			val AS result
		FROM @resultOK
		WHERE #filter_columns#
			ORDER BY 1
		OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
	END
	END
END
ELSE IF (@action = 0)
BEGIN

	IF(@att_id IS NOT NULL)
	BEGIN 
		UPDATE dbo.[AttentionQuestionAndEvent] 
			SET [is_active] = 0
		OUTPUT inserted.Id INTO @update_info
		WHERE [Id] = @att_id;

		SET @upId = (SELECT TOP 1 [Id] FROM @update_info);
		IF (@upId IS NOT NULL)
		BEGIN 
			SELECT 
				val AS result
			FROM @resultOK
			WHERE #filter_columns#
				ORDER BY 1
			OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
		END
	END
END
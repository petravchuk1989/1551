--  DECLARE @user_edit_id NVARCHAR(128)=N'bc1b17e2-ffee-41b1-860a-41e1bae57ffd';
								   																	
SET @executor_person_id = IIF(IIF(@executor_person_id = '',NULL,@executor_person_id) = 0,NULL,IIF(@executor_person_id = '',NULL,@executor_person_id));
-- проверка если открыто более одного окна с дорученням
IF (SELECT
		[edit_date]
	FROM dbo.[Assignments]
	WHERE Id = @Id)
	<> @date_in_form
BEGIN
	RAISERROR (N'З моменту відкриття картки дані вже було змінено. Оновіть сторінку, щоб побачити зміни.', 16,1);
	RETURN;
END
IF(@result_id = 3) AND (@transfer_to_organization_id IS NULL)
BEGIN
RAISERROR(N'Поле "Можливий виконавець" пусте, заповніть його', 16, 1);
RETURN;
END
DECLARE @sertors TABLE (Id INT);

INSERT INTO @sertors (Id)

SELECT [Assignments].Id
FROM [dbo].[Positions] [Positions] 
INNER JOIN [dbo].[PersonExecutorChoose] [PersonExecutorChoose] ON [PersonExecutorChoose].position_id=[Positions].id
INNER JOIN [dbo].[PersonExecutorChooseObjects] [PersonExecutorChooseObjects] ON [PersonExecutorChooseObjects].person_executor_choose_id=[PersonExecutorChoose].Id
INNER JOIN [dbo].[Territories] [Territories] ON [PersonExecutorChooseObjects].object_id=[Territories].object_id
INNER JOIN [dbo].[QuestionsInTerritory] [QuestionsInTerritory] ON [Territories].Id=[QuestionsInTerritory].territory_id
INNER JOIN [dbo].[Questions] [Questions] ON [QuestionsInTerritory].question_id=[Questions].Id
INNER JOIN [dbo].[Assignments] [Assignments] ON [Questions].Id=[Assignments].question_id
WHERE [Positions].programuser_id=@user_edit_id  AND [Positions].role_id=8 AND [Assignments].Id=@Id;

DECLARE @org1761 TABLE (Id INT);
WITH
	cte1 -- все подчиненные 3 и 3 1761
AS ( SELECT Id,
		[parent_organization_id] ParentId
		FROM [dbo].[Organizations] t
		WHERE Id = 1761
		UNION ALL
		SELECT tp.Id,
		tp.[parent_organization_id] ParentId
		FROM [dbo].[Organizations] tp 
		INNER JOIN cte1 curr ON tp.[parent_organization_id] = curr.Id ),
org_user AS
(
SELECT organizations_id FROM [dbo].[Positions]
WHERE programuser_id=@user_edit_id
)

INSERT INTO @org1761 (Id)
SELECT Id 
FROM cte1 INNER JOIN org_user ON cte1.Id=org_user.organizations_id;


IF 
(
SELECT TOP 1 oirr.editable
FROM [dbo].[Assignments] a INNER JOIN 
[dbo].[OrganizationInResponsibilityRights] oirr ON a.[executor_organization_id]=oirr.organization_id
INNER JOIN [dbo].[Positions] p ON oirr.position_id=p.Id
WHERE a.Id=@Id AND P.programuser_id=@user_edit_id)='true'
OR EXISTS(SELECT TOP 1 id FROM @org1761) OR EXISTS(SELECT TOP 1 Id FROM @sertors)

BEGIN

DECLARE @output TABLE (
[Id] INT
);
DECLARE @output_con TABLE (
Id INT
);
DECLARE @new_con INT;
DECLARE @ass_id INT;
DECLARE @ass_cons_id INT;
DECLARE @parent_id INT = (SELECT
	organization_id
FROM Assignments Assignments
WHERE Id = @Id);
SET	@ass_cons_id = (SELECT
		Id
	FROM AssignmentConsiderations AssignmentConsiderations
	WHERE Id = @current_consid);
DECLARE @result_of_checking INT;
DECLARE @is_main_exec BIT;
---> Проверка изменений state, result, resolution, executor_organization_id
DECLARE @currentState INT = (SELECT assignment_state_id FROM dbo.Assignments WHERE Id = @Id);
DECLARE @currentResult INT = (SELECT AssignmentResultsId FROM dbo.Assignments WHERE Id = @Id);
DECLARE @currentResolution INT = (SELECT ISNULL(AssignmentResolutionsId, 0) FROM dbo.Assignments WHERE Id = @Id);
DECLARE @currentOrgExecutor INT = (SELECT executor_organization_id FROM dbo.Assignments WHERE Id = @Id);
	
DECLARE @IsStateChange BIT = (SELECT IIF(@currentState = @ass_state_id, 0, 1));
DECLARE @IsResultChange BIT = (SELECT IIF(@currentResult = @result_id, 0, 1));
DECLARE @IsResolutionChange BIT = (SELECT IIF(@currentResolution = ISNULL(@resolution_id, 0), 0, 1));
DECLARE @IsOrgExecutorChange BIT = (SELECT IIF(@currentOrgExecutor = @performer_id, 0, 1));
---> Если стан, результат, резолюция и орг.исполнителя остались прежними, то
-- процедуру проверки переходов пропускаем, а только апдейтим поля executor_person_id и short_answer (если они изменились)
IF (@IsStateChange = 0 AND @IsResultChange = 0 AND @IsResolutionChange = 0 AND @IsOrgExecutorChange = 0)
BEGIN
DECLARE @currentPersonExecutor INT = (SELECT executor_person_id FROM dbo.Assignments  WHERE Id = @Id);
DECLARE @currentShortAnswer NVARCHAR(500) = (SELECT short_answer FROM dbo.AssignmentConsiderations WHERE Id = @ass_cons_id);
DECLARE @mainAssId INT = (SELECT last_assignment_for_execution_id FROM dbo.[Questions] WHERE Id = @question_id);
---> сделать текущий Assignment главным
	IF(@mainAssId <> @Id) 
	AND (@main_executor = 1)
	BEGIN
	UPDATE dbo.[Assignments]
		SET main_executor = 0 
	WHERE Id = @mainAssId;

	UPDATE dbo.[Assignments]
		SET main_executor = 1
	WHERE Id = @Id;

	UPDATE dbo.[Questions] 
		SET last_assignment_for_execution_id = @Id
	WHERE Id = @question_id;
	END
---> замена "Виконавець в організації"
	IF(@executor_person_id IS NOT NULL)
	BEGIN
	UPDATE [dbo].[Assignments]
				SET [edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[executor_person_id] = @executor_person_id
					,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row10'
				WHERE Id = @Id;
	END
---> проставить "Коментар виконавця"
	IF(@short_answer IS NOT NULL)
	BEGIN
	UPDATE AssignmentConsiderations
			SET short_answer = @short_answer
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
			WHERE Id = @current_consid;
	END	
END
---> обработка изменений по "Резолюція класу"
ELSE IF(@class_resolution_id IS NOT NULL) 
AND (SELECT [class_resolution_id] FROM dbo.Assignments WHERE [Id] = @Id) IS NULL
BEGIN
	SET XACT_ABORT ON;
	BEGIN TRY
	BEGIN TRANSACTION;
	BEGIN
	DECLARE @class_resolution_org INT = (SELECT [executor_organization_id] FROM dbo.[Class_Resolutions] WHERE Id = @class_resolution_id);
	DECLARE @new_result_id INT = (SELECT [assignment_result_id] FROM dbo.[Class_Resolutions] WHERE Id = @class_resolution_id);
	DECLARE @new_resolution_id INT = (SELECT [assignment_resolution_id] FROM dbo.[Class_Resolutions] WHERE Id = @class_resolution_id);
	DECLARE @event_class_id INT = (SELECT [event_class_id] FROM dbo.[Class_Resolutions] WHERE Id = @class_resolution_id); 
	DECLARE @create_assignment_class_id INT = (SELECT [create_assignment_class_id] FROM dbo.[Class_Resolutions] WHERE Id = @class_resolution_id);
	DECLARE @prev_main BIT = (SELECT [main_executor] FROM dbo.[Assignments] WHERE Id = @Id);
	DECLARE @event_info TABLE (Id INT);
	DECLARE @now DATETIME = GETUTCDATE();
	DECLARE @new_state_id INT = (SELECT 
								 DISTINCT 
								 	[new_assignment_state_id]
								 FROM [dbo].[TransitionAssignmentStates] 
								 WHERE new_assignment_resolution_id = @new_resolution_id 
								 AND new_assignment_result_id = @new_result_id);
	
	UPDATE [dbo].[Assignments]
	SET [class_resolution_id] = @class_resolution_id,
	 	[AssignmentResultsId] = @new_result_id,
	 	[AssignmentResolutionsId] = @new_resolution_id,
		[assignment_state_id] = @new_state_id,
	 	[edit_date] = @now,
	 	[user_edit_id] = @user_edit_id,
	 	[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row11'
	WHERE Id = @Id;
	 
	UPDATE dbo.AssignmentConsiderations
	SET [consideration_date] = @now,
	 	[assignment_result_id] = @new_result_id,
	 	[assignment_resolution_id] = @new_resolution_id,
	 	[edit_date] = @now,
	 	[user_edit_id] = @user_edit_id,
	 	[short_answer] = @short_answer
	WHERE Id = @current_consid;

	INSERT INTO [dbo].[AssignmentRevisions]
				([assignment_consideration_іd]
				,[control_type_id]
				,[assignment_resolution_id]
				,[user_id]
				,[edit_date]
				,[user_edit_id])
	VALUES (@current_consid
			,1
			,@new_resolution_id
			,@user_edit_id
			,@now
			,@user_edit_id
			);
	--> Создать проблему (Event) под резолюцию класса, если надо
	IF(@event_class_id IS NOT NULL) 
	AND (SELECT [event_id] FROM dbo.[Questions] WHERE Id = @question_id)
	IS NULL
	BEGIN
	DECLARE @event_assignment_class_id INT = (SELECT [assignment_class_id] FROM dbo.[Event_Class] WHERE Id = @event_class_id);
	DECLARE @event_type_id INT = (SELECT [event_type_id] FROM dbo.[Event_Class] WHERE Id = @event_class_id);
	DECLARE @area INT = (SELECT [object_id] FROM dbo.[Questions] WHERE Id = @question_id);
	DECLARE @exec_term INT = (SELECT [execution_term] FROM dbo.[Event_Class] WHERE Id = @event_class_id)/24;
	DECLARE @plan_end_time DATETIME = (SELECT DATEADD(DAY, @exec_term, @now));
	DECLARE @event_organization_id INT = (SELECT TOP 1 [organizations_id] FROM dbo.[Positions] WHERE programuser_id = @user_edit_id);
	DECLARE @event_comment NVARCHAR(250) = (SELECT [name] FROM dbo.[Class_Resolutions] WHERE Id = @class_resolution_id) + 
											SPACE(1) + CONVERT(VARCHAR(10), @plan_end_time, 111);
	
	INSERT INTO dbo.[Events] ([registration_date],
	 						  [event_type_id],
	 						  [start_date],
	 						  [plan_end_date],
	 						  [active],
	 						  [comment],
	 						  [area],
	 						  [user_id],
	 						  [event_class_id],
							  [created_from_assignment_id])
	 		OUTPUT inserted.Id INTO @event_info (Id)
	 		VALUES(@now,
	 			   @event_type_id,
	 			   @now,
	 			   @plan_end_time,
	 			   1,
	 			   @event_comment,
	 			   @area,
	 			   @user_edit_id,
	 			   @event_class_id,
				   @Id);

	DECLARE @new_event_id INT = (SELECT TOP 1 [Id] FROM @event_info);
	INSERT INTO dbo.[EventObjects] ([event_id],
						  			[object_id],
						  			[in_form])
			VALUES(@new_event_id,
				   @area,
				   1);

	INSERT INTO dbo.[EventOrganizers] ([event_id],
									   [organization_id],
									   [executor_id],
									   [main])
			VALUES(@new_event_id,
				   @event_organization_id,
				   NULL,
				   1);

	INSERT INTO dbo.[EventQuestionsTypes] ([event_id],
										   [question_type_id],
										   [is_hard_connection])		
			SELECT 
				@new_event_id,
				e_class_q_type.[question_type_id],
				e_class_q_type.[is_hard_connection]
			FROM dbo.[EventClass_QuestionType] AS e_class_q_type
			WHERE event_class_id = @event_class_id;

		UPDATE dbo.[Questions] 
			SET [event_id] = @new_event_id
		WHERE Id = @question_id;
				   
			IF(@event_assignment_class_id IS NOT NULL)
			BEGIN
				IF(@class_resolution_org IS NULL)
					BEGIN
						RAISERROR(N'Для обраного класу резорюції не вказано відповідальну організацію', 16, 1);
						RETURN;
				END
			DECLARE @event_question_type_id INT = (SELECT [question_type_id] FROM dbo.[Questions] WHERE Id = @question_id);
			DECLARE @event_assignment_exec_date DATETIME;
			DECLARE @event_assignment_info TABLE (Id INT);
			DECLARE @event_assignment_consideration_info TABLE (Id INT);
			EXEC @event_assignment_exec_date = dbo.fn_GetExecutionTerm 
	 						@question_type_id = @event_question_type_id, 
	 						@assignment_class_id = @event_assignment_class_id;

			INSERT INTO dbo.[Assignments] ([question_id],
	 							   [assignment_type_id],
	 							   [registration_date],
	 							   [assignment_state_id],
	 							   [organization_id],
	 							   [executor_organization_id],
	 							   [main_executor],
	 							   [execution_date],
	 							   [user_id],
	 							   [edit_date],
	 							   [user_edit_id],
	 							   [AssignmentResultsId],
	 							   [LogUpdated_Query],
	 							   [assignment_class_id],
	 							   [my_event_id])
				OUTPUT inserted.Id INTO @event_assignment_info (Id)
	 			VALUES (@question_id,
	 					1,
	 					@now,
	 					1,
	 					@class_resolution_org,
	 					@class_resolution_org,
	 					@prev_main,
	 					@event_assignment_exec_date,
	 					@user_edit_id,
	 					@now,
	 					@user_edit_id,
	 					1,
	 					N'cx_App_Que_Assignments_Update_Row12',
	 					@event_assignment_class_id,
	 					@new_event_id);

			DECLARE @event_assignment_new_id INT = (SELECT TOP 1 Id FROM @event_assignment_info);					
	 
			INSERT INTO dbo.AssignmentConsiderations (
	 							[assignment_id], 
	 							[consideration_date], 
	 							[assignment_result_id], 
	 							[assignment_resolution_id], 
	 							[user_id], 
	 							[edit_date], 
	 							[user_edit_id], 
	 							[first_executor_organization_id], 
	 							[create_date], 
	 							[transfer_date])
	 		OUTPUT inserted.Id INTO @event_assignment_consideration_info (Id)
	 		VALUES(@event_assignment_new_id,
	 			   @now,
	 			   1,
	 			   NULL,
	 			   @user_edit_id,
	 			   @now,
	 			   @user_edit_id,
	 			   @class_resolution_org,
	 			   @now,
	 			   @now);
	 	
				DECLARE @event_assignment_new_cons_id INT = (SELECT TOP 1 [Id] FROM @event_assignment_consideration_info);

				UPDATE dbo.[Assignments] 
				 	SET [current_assignment_consideration_id] = @event_assignment_new_cons_id
				WHERE Id = @event_assignment_new_id;

				IF(@prev_main = 1)
				BEGIN
				UPDATE dbo.[Assignments] 
				 	SET [main_executor] = 0
				WHERE Id = @Id;

				UPDATE dbo.[Questions] 
					SET [last_assignment_for_execution_id] = @event_assignment_new_id
				WHERE Id = @question_id;
				END
			END	    
	
	END

	IF(@create_assignment_class_id IS NOT NULL)
	BEGIN
		IF(@class_resolution_org IS NULL)
		BEGIN
			RAISERROR(N'Для обраного класу резорюції не вказано відповідальну організацію', 16, 1);
			RETURN;
		END
	DECLARE @question_type_id INT = (SELECT [question_type_id] FROM dbo.[Questions] WHERE Id = @question_id);
	DECLARE @my_event_id INT = (SELECT TOP 1 [Id] FROM @event_info);
	DECLARE @assignment_info TABLE (Id INT);
	DECLARE @assignment_exec_date DATETIME;
	EXEC @assignment_exec_date = dbo.fn_GetExecutionTerm 
	 						@question_type_id = @question_type_id, 
	 						@assignment_class_id = @create_assignment_class_id;
	 
	INSERT INTO dbo.[Assignments] ([question_id],
	 							   [assignment_type_id],
	 							   [registration_date],
	 							   [assignment_state_id],
	 							   [organization_id],
	 							   [executor_organization_id],
	 							   [main_executor],
	 							   [execution_date],
	 							   [user_id],
	 							   [edit_date],
	 							   [user_edit_id],
	 							   [AssignmentResultsId],
	 							   [LogUpdated_Query],
	 							   [assignment_class_id],
	 							   [my_event_id])
	 			OUTPUT inserted.Id INTO @assignment_info (Id)
	 			VALUES (@question_id,
	 					1,
	 					@now,
	 					1,
	 					@class_resolution_org,
	 					@class_resolution_org,
	 					@prev_main,
	 					@assignment_exec_date,
	 					@user_edit_id,
	 					@now,
	 					@user_edit_id,
	 					1,
	 					N'cx_App_Que_Assignments_Update_Row13',
	 					@create_assignment_class_id,
	 					@my_event_id);
	 
	DECLARE @new_assignment_id INT = (SELECT TOP 1 [Id] FROM @assignment_info);
	DECLARE @consideration_info TABLE (Id INT);
	 
	INSERT INTO dbo.AssignmentConsiderations (
	 							[assignment_id], 
	 							[consideration_date], 
	 							[assignment_result_id], 
	 							[assignment_resolution_id], 
	 							[user_id], 
	 							[edit_date], 
	 							[user_edit_id], 
	 							[first_executor_organization_id], 
	 							[create_date], 
	 							[transfer_date])
	 		OUTPUT inserted.Id INTO @consideration_info (Id)
	 		VALUES(@new_assignment_id,
	 			   @now,
	 			   1,
	 			   NULL,
	 			   @user_edit_id,
	 			   @now,
	 			   @user_edit_id,
	 			   @class_resolution_org,
	 			   @now,
	 			   @now);
	 	
	DECLARE @new_cons_id INT = (SELECT TOP 1 [Id] FROM @consideration_info);
	UPDATE dbo.[Assignments] 
	 	SET [current_assignment_consideration_id] = @new_cons_id
	WHERE Id = @new_assignment_id;

	IF(@prev_main = 1)
	BEGIN
	UPDATE dbo.[Assignments] 
	 	SET [main_executor] = 0
	WHERE Id = @Id;

	UPDATE dbo.[Questions] 
		SET [last_assignment_for_execution_id] = @new_assignment_id
	WHERE Id = @question_id;
	END

	END
	END
	COMMIT TRANSACTION;
	RETURN;
	END TRY
	BEGIN CATCH 
	IF (XACT_STATE()) = -1  
	    BEGIN  
	        DECLARE @error NVARCHAR(MAX) = (SELECT ERROR_MESSAGE()); 
			RAISERROR (@error, 16, 1); 
	        ROLLBACK TRANSACTION;  
	    END;  
	END CATCH;
END
ELSE 
BEGIN
EXEC [dbo].pr_check_right_choice_result_resolution @Id
												,@result_id
												,@resolution_id
												,@ass_state_id
												,@result_of_checking OUTPUT;
IF @result_of_checking = 0
BEGIN
RAISERROR (N'Стан доручення залишився попереднім, оновіть сторінку, та спробуйте ще раз', 16, 1);
RETURN;
END;

IF (SELECT
		assignment_state_id
	FROM Assignments Assignments
	WHERE Id = @Id)
= (SELECT
		[Id]
	FROM [dbo].[AssignmentStates] AssignmentStates
	WHERE code = 'Closed')
BEGIN
RETURN;
END
ELSE
BEGIN
	--если результат, резолюция не изменились и...
	IF @result_id = (SELECT
				AssignmentResultsId
			FROM Assignments
			WHERE Id = @Id)
		AND (@resolution_id = (SELECT
				AssignmentResolutionsId
			FROM Assignments
			WHERE Id = @Id)
		OR @resolution_id IS NULL)
	-- and @performer_id = @parent_id
	BEGIN
		-- если виконавець не изменился но апдейтим только коментарий исполнителя + сис.поля
		IF @performer_id = (SELECT
					executor_organization_id
				FROM Assignments
				WHERE Id = @Id) --@parent_id
		BEGIN
			IF @executor_person_id <> (SELECT
						ISNULL(executor_person_id, 0)
					FROM Assignments
					WHERE Id = @Id)
			BEGIN
				UPDATE [dbo].[Assignments]
				SET [edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[executor_person_id] = @executor_person_id
					,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row49'
				WHERE Id = @Id;
			END;

			UPDATE AssignmentConsiderations
			SET short_answer = @short_answer
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
			WHERE Id = @current_consid;
			RETURN;
		END;
		ELSE
		-- если виконавець изменился то логика как при "Перерозподіл на підрядну організацію (если поменялся исполнитель)"
		BEGIN
			UPDATE [dbo].[Assignments]
			SET [assignment_state_id] = @ass_state_id
				,[executor_organization_id] = @performer_id -- новый исполнитель на кого переопределили
				,[execution_date] = @execution_date
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,[executor_person_id] = @executor_person_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row51'
			WHERE Id = @Id;

			UPDATE dbo.AssignmentConsiderations
			SET [short_answer] = @short_answer
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,[consideration_date] = GETUTCDATE()
			WHERE Id = @current_consid;

			DELETE FROM @output_con;
			INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
			, [consideration_date]
			, [assignment_result_id]
			, [assignment_resolution_id]
			, [user_id]
			, [edit_date]
			, [user_edit_id]
			, [first_executor_organization_id]
			, create_date
			, transfer_date
			, [short_answer])
			OUTPUT INSERTED.Id INTO @output_con ([Id])
				VALUES (@Id, GETUTCDATE(), @result_id, @resolution_id, @user_edit_id, GETUTCDATE(), @user_edit_id, @performer_id  -- новый исполнитель на кого переопределили
				, GETUTCDATE(), GETUTCDATE(), @short_answer);

			SET @new_con = (SELECT TOP (1)
					Id
				FROM @output_con);
			UPDATE [Assignments]
			SET current_assignment_consideration_id = @new_con
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row95'
			WHERE Id = @Id;
			RETURN;
		END;
	END
	ELSE
	BEGIN -- (F11)
		IF @result_id = 13 
			BEGIN 
				DECLARE @outputHistory TABLE (Id INT);
				DECLARE @Operation VARCHAR(128);
				declare @Missed_call_counter int = isnull((select isnull(max([Missed_call_counter]),0) from [dbo].[AssignmentDetailHistory] with (nolock) where [Assignment_id] = @Id),0)+1
				SET @Operation = 'UPDATE';
				INSERT INTO [dbo].[AssignmentDetailHistory] ([Assignment_id]
													,[SourceHistory]
													,[Operation]
													,[Missed_call_counter]	
													,[MissedCallComment]
													,[User_id]
													,[Edit_date]
													)
				output [inserted].[Id] INTO @outputHistory (Id)
				VALUES ( @Id, N'Call', @Operation, @Missed_call_counter, @control_comment, @user_edit_id, GETUTCDATE() );

				DECLARE @app_id INT;
				SET @app_id = (SELECT TOP 1 Id FROM @outputHistory);
			END;

		-- 	Перерозподіл на підрядну організацію (если поменялся исполнитель)
		IF @result_id = 1
			AND @resolution_id IS NULL
		BEGIN
			DECLARE @turn_organization_id INT;
			--AL. если предыдущий результат - "Не в компетенции" тo
			IF (SELECT
						AssignmentResultsId
					FROM Assignments
					WHERE Id = @Id)
				= 3
			BEGIN
				DECLARE @transfer INT;  -- output param
				SET @performer_id = @transfer_to_organization_id;

				EXEC pr_OrganizationalCheck @Id
											,@performer_id
											,@transfer OUTPUT;
				IF @transfer = 0
				BEGIN
					SET @turn_organization_id = 1762;
					SET @result_id = 3;
					SET @resolution_id = 1;
					SET @ass_state_id = 3;

					UPDATE AssignmentConsiderations
					SET consideration_date = GETUTCDATE()
						,short_answer = @short_answer
						,transfer_to_organization_id = @transfer_to_organization_id
						,[assignment_result_id] = @result_id
						,[assignment_resolution_id] = @resolution_id
						,turn_organization_id = @turn_organization_id
						,[edit_date] = GETUTCDATE()
					WHERE Id = @current_consid;

					UPDATE [Assignments]
					SET AssignmentResultsId = @result_id
						,AssignmentResolutionsId = @resolution_id
						,[assignment_state_id] = @ass_state_id
						,[edit_date] = GETUTCDATE()
						,[user_edit_id] = @user_edit_id
						,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row159'
					WHERE Id = @Id;

					INSERT INTO [dbo].[AssignmentRevisions] ([assignment_consideration_іd]
					, [control_type_id]
					, [assignment_resolution_id]
					, [control_comment]
					, [user_id]
					, [rework_counter]
					, [edit_date]
					, [user_edit_id])
						VALUES (@current_consid --@ass_cons_id
						, 1 -- @control_type_id
						, @resolution_id, @control_comment, @user_edit_id, @rework_counter, GETUTCDATE(), @user_edit_id);
					RETURN;
				END
			END


			IF @performer_id <> (SELECT
						organization_id
					FROM Assignments
					WHERE Id = @Id)
			BEGIN

				UPDATE [dbo].[Assignments]
				SET [assignment_state_id] = @ass_state_id
					,[executor_organization_id] = @performer_id -- новый исполнитель на кого переопределили
					,executor_person_id = @executor_person_id
					,[execution_date] = @execution_date
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row115'
					,[AssignmentResultsId] = @result_id
					,AssignmentResolutionsId = @resolution_id
				WHERE Id = @Id;

				UPDATE dbo.AssignmentConsiderations
				SET [short_answer] = @short_answer
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[consideration_date] = GETUTCDATE()
				WHERE Id = @current_consid; -- assignment_id = @Id

				DELETE FROM @output_con;
				INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
				, [consideration_date]
				, [assignment_result_id]
				, [assignment_resolution_id]
				, [user_id]
				, [edit_date]
				, [user_edit_id]
				, [first_executor_organization_id]
				, create_date
				, transfer_date
				, [short_answer])
				OUTPUT INSERTED.Id INTO @output_con ([Id])
					VALUES (@Id, GETUTCDATE(), 1, NULL, @user_edit_id, GETUTCDATE(), @user_edit_id, @performer_id  -- новый исполнитель на кого переопределили
					, GETUTCDATE(), GETUTCDATE(), @short_answer);

				SET @new_con = (SELECT TOP (1)
						Id
					FROM @output_con);
				UPDATE [Assignments]
				SET current_assignment_consideration_id = @new_con
					,[edit_date] = GETUTCDATE()
				WHERE Id = @Id;
			END
			-- 	execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END


		-- 9 Прийнято в роботу	AcceptedInWork 
		IF @result_id = 9
			AND @resolution_id IS NULL
		BEGIN
			-- Прийняття доручення в роботу  (2 В роботі InWork)
			-- if @ass_state_id = 2  
			UPDATE AssignmentConsiderations
			SET transfer_date = GETUTCDATE()
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,[assignment_result_id] = @result_id
				,[assignment_resolution_id] = @resolution_id
				,[short_answer] = @short_answer
			WHERE Id = @current_consid;

			UPDATE [Assignments]
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,[assignment_state_id] = @ass_state_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row186'
			WHERE Id = @Id;
			-- 			execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END


		-- 3 Не в компетенції	NotInTheCompetence 
		-- 14 Повернуто в батьківську організацію	returnedToParentOrganization
		IF @result_id = 3
			AND @resolution_id = 14
		BEGIN
			-- Якщо можливий виконавець знаходиться Не в організаційній структурі батьківської організації, 
			-- то доручення формується з станом - На перевірці, результатом - Не в компетенції. резолюція - Повернуто в 1551. (CRM1551-221)
			-- процедура проверяет pr_check_relatives - если возможный исполнитель является дочерней орг.родителя то возвращает "1"
			-- принимает парам.1- родитель, парам.2 - возможный исполнитель, парам.3 - возвращаемый параметр проверки 
			DECLARE @check BIT;
			EXEC pr_check_relatives @parent_id
									,@transfer_to_organization_id
									,@check OUTPUT;
			IF @check = 1
			BEGIN
				UPDATE dbo.AssignmentConsiderations
				SET consideration_date = GETUTCDATE()
					,short_answer = @short_answer
					,transfer_to_organization_id = @transfer_to_organization_id
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[assignment_result_id] = @result_id
					,[assignment_resolution_id] = @resolution_id
				WHERE Id = @current_consid;

				UPDATE [Assignments]
				SET AssignmentResultsId = @result_id
					,AssignmentResolutionsId = @resolution_id
					,assignment_state_id = @ass_state_id -- 04_04
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row223'
				WHERE Id = @Id;


				DELETE FROM @output_con;
				INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
				, [consideration_date]
				, [assignment_result_id]
				, [assignment_resolution_id]
				, [user_id]
				, [edit_date]
				, [user_edit_id]
				, [first_executor_organization_id]
				, create_date
				, transfer_date
				, turn_organization_id
				, transfer_to_organization_id
				, short_answer)
				OUTPUT INSERTED.Id INTO @output_con ([Id])
					VALUES (@Id, GETUTCDATE(), @result_id, @resolution_id, @user_edit_id, GETUTCDATE(), @user_edit_id, (SELECT organization_id FROM Assignments WHERE Id = @Id), GETUTCDATE(), GETUTCDATE(), (SELECT organization_id FROM Assignments WHERE Id = @Id), @transfer_to_organization_id, @short_answer);

				SET @new_con = (SELECT TOP (1)
						Id
					FROM @output_con);
				UPDATE [Assignments]
				SET current_assignment_consideration_id = @new_con
					,[edit_date] = GETUTCDATE()
				WHERE Id = @Id;
			-- execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			END

			ELSE

			BEGIN
				SET @result_id = 3; -- Не в компетенції
				SET @resolution_id = 1; -- Повернуто в 1551
				SET @ass_state_id = 3; -- На перевірці

				UPDATE AssignmentConsiderations
				SET consideration_date = GETUTCDATE()
					,short_answer = @short_answer
					,transfer_to_organization_id = @transfer_to_organization_id
					,[assignment_result_id] = @result_id
					,[assignment_resolution_id] = @resolution_id
					,turn_organization_id = 1762
					,[edit_date] = GETUTCDATE()
				WHERE Id = @current_consid;

				UPDATE [Assignments]
				SET AssignmentResultsId = @result_id
					,AssignmentResolutionsId = @resolution_id
					,[assignment_state_id] = @ass_state_id
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row288'
				WHERE Id = @Id;

				INSERT INTO [dbo].[AssignmentRevisions] ([assignment_consideration_іd]
				, [control_type_id]
				, [assignment_resolution_id]
				, [control_comment]
				--    ,[control_date]
				, [user_id]
				, [rework_counter]
				, [edit_date]
				, [user_edit_id])
				VALUES (@current_consid --@ass_cons_id
						,1  -- @control_type_id = Контроль, Продзвон, Контроль заявником
						,@resolution_id -- @assignment_resolution_id
						,@control_comment
					--    ,getutcdate() 
						,@user_edit_id --@user_id
					-- ,@rework_counter_count
						,@rework_counter, GETUTCDATE() --@edit_date
						,@user_edit_id);
			END
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END


		-- 3 Не в компетенції	NotInTheCompetence  
		-- 1 Повернуто в 1551	returnedIn1551
		IF @result_id = 3
			AND @resolution_id = 1
		BEGIN
			UPDATE AssignmentConsiderations
			SET consideration_date = GETUTCDATE()
				,short_answer = @short_answer
				,transfer_to_organization_id = @transfer_to_organization_id
				,[assignment_result_id] = @result_id
				,[assignment_resolution_id] = @resolution_id
				,turn_organization_id = 1762
				,[edit_date] = GETUTCDATE()
			WHERE Id = @current_consid;

			UPDATE [Assignments]
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,[assignment_state_id] = @ass_state_id
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row339'
			WHERE Id = @Id;

			INSERT INTO [dbo].[AssignmentRevisions] ([assignment_consideration_іd]
			, [control_type_id]
			, [assignment_resolution_id]
			, [control_comment]
			--    ,[control_date]
			, [user_id]
			, [rework_counter]
			, [edit_date]
			, [user_edit_id])
				VALUES (@current_consid --@ass_cons_id
				, 1 -- @control_type_id = Контроль, Продзвон, Контроль заявником
				, @resolution_id -- @assignment_resolution_id
				, @control_comment
				--    ,getutcdate() 
				, @user_edit_id --@user_id
				-- ,@rework_counter_count
				, @rework_counter, GETUTCDATE() --@edit_date
				, @user_edit_id);
			-- 			execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END

		-- Если перенаправлено за належністю из 1551
		IF (SELECT
					AssignmentResolutionsId
				FROM Assignments
				WHERE Id = @Id)
			= 1 -- Повернуто в 1551	returnedIn1551
		BEGIN -- tt
			--   возвращается тому-же виконавцю, тоесть не в комтепенции Не подтверждено
			-- 6 Повернуто виконавцю	returnedToTheArtist
			-- 3 Перенаправлено за належністю	RedirectedByAffiliation
			IF @result_id = 6
				AND @resolution_id = 3
			BEGIN

				--if @transfer_to_organization_id = (select first_executor_organization_id from AssignmentConsiderations where Id = @current_consid) 
				--or @transfer_to_organization_id is null
				--begin
				SET @transfer_to_organization_id = (SELECT
						first_executor_organization_id
					FROM AssignmentConsiderations
					WHERE Id = @current_consid);
				-- Стан = зареєстровано	
				SET @ass_state_id = 1;
				-- закрываем Ревижн, + новый AssignmentConsiderations на того же самого исполнителя.
				UPDATE [dbo].[AssignmentRevisions]
				SET [assignment_resolution_id] = @resolution_id
					,organization_id = @transfer_to_organization_id
					,[control_comment] = @control_comment
					,[rework_counter] = @rework_counter
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,control_result_id = @resolution_id
					,control_date = GETUTCDATE()
				WHERE assignment_consideration_іd = @current_consid;

				UPDATE Assignments
				SET AssignmentResultsId = @result_id -- Какие результат и резолучия должны быть????
					,AssignmentResolutionsId = @resolution_id
					,assignment_state_id = @ass_state_id
					,edit_date = GETUTCDATE()
					,user_edit_id = @user_edit_id
					,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row404'
				WHERE Id = @Id;

				DELETE FROM @output_con;
				INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
				, [consideration_date]
				, [assignment_result_id]
				, [assignment_resolution_id]
				, [user_id]
				, [edit_date]
				, [user_edit_id]
				, [first_executor_organization_id]
				, create_date
				, transfer_date
				, [short_answer])
				OUTPUT INSERTED.Id INTO @output_con ([Id])
					VALUES (@Id, GETUTCDATE(), @result_id, @resolution_id, @user_edit_id, GETUTCDATE(), @user_edit_id, @transfer_to_organization_id, GETUTCDATE(), GETUTCDATE(), @short_answer);

				SET @new_con = (SELECT
									max(Id)
								FROM
									dbo.[AssignmentConsiderations] 
								WHERE assignment_id = @Id);
				UPDATE [Assignments]
				SET current_assignment_consideration_id = @new_con
					,[edit_date] = GETUTCDATE()
				WHERE Id = @Id;

				--end
				-- execute define_status_Question @question_id
				-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
				RETURN;
			END

			-- 3 Не в компетенції	NotInTheCompetence
			-- 3 Перенаправлено за належністю	RedirectedByAffiliation
			IF @result_id = 3
				AND @resolution_id = 3
			BEGIN -- 3\3
				--закрываем старое  Assignments и AssignmentConsiderations и AssignmentRevisions
				UPDATE Assignments
				SET
				--main_executor = 0
				close_date = GETUTCDATE()
				,AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,assignment_state_id = @ass_state_id -- 04_04
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row458'
				WHERE Id = @Id;

				UPDATE dbo.AssignmentConsiderations
				SET consideration_date = GETUTCDATE()
					,assignment_result_id = @result_id
					,assignment_resolution_id = @resolution_id
					,transfer_to_organization_id = @transfer_to_organization_id
					,edit_date = GETUTCDATE()
					,user_edit_id = @user_edit_id
					,[short_answer] = @short_answer
				WHERE Id = @current_consid; -- assignment_id = @Id

				UPDATE [dbo].AssignmentRevisions
				SET [assignment_resolution_id] = @resolution_id
					,organization_id = @transfer_to_organization_id
					,[control_comment] = @control_comment
					,[rework_counter] = @rework_counter
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,control_result_id = @resolution_id
					,control_date = GETUTCDATE()
				WHERE assignment_consideration_іd = @current_consid;

				DELETE FROM @output;
				DELETE FROM @output_con;

				-- если на Можливого виконавеця нет доруч. в этом вопросе то создаем новый  Assignments и AssignmentConsiderations...
				IF NOT EXISTS (SELECT
							1
						FROM Assignments
						WHERE question_id = (SELECT
								question_id
							FROM Assignments
							WHERE Id = @Id)
						AND executor_organization_id = @transfer_to_organization_id)
				BEGIN

					DECLARE @tested_transfer INT;
					DECLARE @ass_id_for_main INT;
					EXEC [dbo].Check_transfer_organizations @Id
															,@transfer_to_organization_id
															,@tested_transfer OUTPUT
															,@ass_id_for_main OUTPUT;

					IF @tested_transfer = 0
					BEGIN
						-- создаем новое Assignments и AssignmentConsiderations
						INSERT INTO [dbo].[Assignments] ([question_id]
						, [assignment_type_id]
						, [registration_date]
						, [assignment_state_id]
						, [state_change_date]
						, [organization_id]
						, [executor_organization_id]
						, [main_executor]
						, [execution_date]
						, [user_id]
						, [edit_date]
						, [user_edit_id]
						, AssignmentResultsId
						, AssignmentResolutionsId
						, LogUpdated_Query)
						OUTPUT INSERTED.Id INTO @output ([Id])
							SELECT
								ass.question_id
								,ass.assignment_type_id
								,GETUTCDATE()
								,1	--Зареєстровано
								,GETUTCDATE()
								--,(select first_executor_organization_id from AssignmentConsiderations where Id=@current_consid)
								,@transfer_to_organization_id
								,@transfer_to_organization_id
								--   ,1 --main
								,main_executor
								,ass.execution_date
								,@user_edit_id
								,GETUTCDATE()
								,@user_edit_id
								,1	--Очікує прийому в роботу
								,NULL
								,N'cx_App_Que_Assignments_Update_Row522'
							FROM Assignments AS ass
							WHERE ass.Id = @Id;

						SET @ass_id = (SELECT TOP 1
								[Id]
							FROM @output);

						INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
						, [consideration_date]
						, [assignment_result_id]
						, [assignment_resolution_id]
						, [user_id]
						, [edit_date]
						, [user_edit_id]
						, turn_organization_id
						, [first_executor_organization_id]
						, [short_answer]
						, create_date)
						OUTPUT INSERTED.Id INTO @output_con ([Id])
							SELECT
								@ass_id
								,GETUTCDATE()
								,1	--Очікує прийому в роботу
								,NULL
								,@user_edit_id
								,GETUTCDATE()
								,@user_edit_id
								,NULL
								--   ,first_executor_organization_id
								,@transfer_to_organization_id
								,@short_answer
								,GETUTCDATE()
							FROM AssignmentConsiderations
							WHERE Id = @current_consid;

						--  проверка если это главное доручення то меняем в Вопросе last_assignment_for_execution_id
						IF (SELECT
									main_executor
								FROM Assignments
								WHERE Id = @Id)
							= 1
						BEGIN
							UPDATE [dbo].[Questions]
							SET last_assignment_for_execution_id = @ass_id
								,edit_date = GETUTCDATE()
								,user_edit_id = @user_edit_id
							WHERE last_assignment_for_execution_id = @Id;
						END

						SET @new_con = (SELECT TOP (1)
								Id
							FROM @output_con);
						UPDATE [dbo].[Assignments]
						SET main_executor = 0
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row563'
							,[edit_date]=GETUTCDATE()
						WHERE Id = @Id;
						UPDATE [Assignments]
						SET current_assignment_consideration_id = @new_con
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row590'
							,[edit_date] = GETUTCDATE()
						WHERE Id = @ass_id;
					END
					ELSE -- if @tested_transfer = 1
					BEGIN
						UPDATE [Assignments]
						SET main_executor = 1
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row600'
							,edit_date = GETUTCDATE()
							,user_edit_id = @user_edit_id
						WHERE Id = @ass_id_for_main;

						UPDATE [dbo].[Questions]
						SET last_assignment_for_execution_id = @ass_id_for_main
							,edit_date = GETUTCDATE()
							,user_edit_id = @user_edit_id
						WHERE Id = @question_id;

						UPDATE Assignments
						SET main_executor = 0
							,edit_date = GETUTCDATE()
							,user_edit_id = @user_edit_id
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row616'
						WHERE Id = @Id;

					END
				-- update [Assignments] set main_executor = 0,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row596' where Id = @Id
				--select  @ass_id as Id
				END
				ELSE
				BEGIN
					-- update [Assignments] set main_executor = 0,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row572' where Id = @Id
					SELECT
						@is_main_exec = main_executor
					FROM Assignments
					WHERE Id = @Id;

					-- Id-ка доручення в этом вопросе где есть можливий
					DECLARE @New_Ass INT = (SELECT TOP 1
							Id
						FROM Assignments
						WHERE question_id = (SELECT
								question_id
							FROM Assignments
							WHERE Id = @Id)
						AND executor_organization_id = @transfer_to_organization_id);

					-- Есть доручення на можливого, закрытое с резултатом Не в компетенции
					IF EXISTS (SELECT
								1
							FROM Assignments
							WHERE question_id = (SELECT
									question_id
								FROM Assignments
								WHERE Id = @Id)
							AND executor_organization_id = @transfer_to_organization_id
							AND AssignmentResultsId = 3
							AND AssignmentResolutionsId = 3)
					BEGIN
						UPDATE [Assignments]
						SET main_executor = @is_main_exec
							,[AssignmentResultsId] = 1
							,[assignment_state_id] = 1
							,[AssignmentResolutionsId] = NULL
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update__Row581'
							,close_date = NULL
							,edit_date = GETUTCDATE()
							,user_edit_id = @user_edit_id
						WHERE Id = @New_Ass;

						INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
						, [consideration_date]
						, [assignment_result_id]
						, [assignment_resolution_id]
						, [user_id]
						, [edit_date]
						, [user_edit_id]
						, turn_organization_id
						, [first_executor_organization_id]
						, [short_answer]
						, create_date)
						OUTPUT INSERTED.Id INTO @output_con ([Id])
							SELECT
								@New_Ass
								,GETUTCDATE()
								,1	--Очікує прийому в роботу
								,NULL
								,@user_edit_id
								,GETUTCDATE()
								,@user_edit_id
								,NULL
								--   ,first_executor_organization_id
								,@transfer_to_organization_id
								,[short_answer]
								,GETUTCDATE()
							FROM AssignmentConsiderations
							WHERE Id = @current_consid;

						UPDATE [Assignments]
						SET main_executor = 0
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row639'
							,[edit_date]=GETUTCDATE()
						WHERE Id = @Id;

						SET @new_con = (SELECT TOP (1)
								Id
							FROM @output_con);
						UPDATE [Assignments]
						SET current_assignment_consideration_id = @new_con
							,[edit_date] = GETUTCDATE()
						WHERE Id = @New_Ass;

					END
					ELSE
					BEGIN
						UPDATE [Assignments]
						SET main_executor = 1
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row613'
							,edit_date = GETUTCDATE()
							,user_edit_id = @user_edit_id
						WHERE Id = @New_Ass;
						UPDATE [Assignments]
						SET main_executor = 0
							,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row646'
							,edit_date = GETUTCDATE()
							,user_edit_id = @user_edit_id
						WHERE question_id = @question_id
						AND Id <> @New_Ass;

						---> last_assignment_for_execution_id под новый Assignment
						UPDATE dbo.[Questions]
						SET last_assignment_for_execution_id = @New_Ass
						WHERE Id = (SELECT question_id FROM Assignments WHERE Id = @New_Ass);
							
					END
				END
				RETURN;
			END -- 3\3
		END -- tt

		-- 6 Повернуто виконавцю	returnedToTheArtist
		-- 3 Перенаправлено за належністю	RedirectedByAffiliation
		IF @result_id = 6
			AND @resolution_id = 3
		BEGIN
			--set @transfer_to_organization_id = (select first_executor_organization_id from AssignmentConsiderations where Id = @current_consid)

			SET @transfer_to_organization_id = (SELECT
					executor_organization_id
				FROM Assignments
				WHERE Id = @Id);
		-- Стан = зареєстровано	
			SET @ass_state_id = 1;
				
			UPDATE Assignments
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,assignment_state_id = @ass_state_id -- 04_04
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row632'
			WHERE Id = @Id;

			UPDATE dbo.AssignmentConsiderations
			SET consideration_date = GETUTCDATE()
				,assignment_result_id = @result_id
				,assignment_resolution_id = @resolution_id
				,transfer_to_organization_id = @transfer_to_organization_id
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,[short_answer] = @short_answer
			WHERE Id = @current_consid;

			DELETE FROM @output_con;
			INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
			, [consideration_date]
			, [assignment_result_id]
			, [assignment_resolution_id]
			, [user_id]
			, [edit_date]
			, [user_edit_id]
			, [first_executor_organization_id]
			, create_date
			, transfer_date
			, [short_answer])
			OUTPUT INSERTED.Id INTO @output_con ([Id])
				VALUES (@Id, GETUTCDATE(), @result_id, @resolution_id, @user_edit_id, GETUTCDATE(), @user_edit_id, @transfer_to_organization_id, GETUTCDATE(), GETUTCDATE(), @short_answer);

			SET @new_con = (SELECT TOP (1)
					Id
				FROM @output_con);
			UPDATE [Assignments]
			SET current_assignment_consideration_id = @new_con
				,[edit_date] = GETUTCDATE()
			WHERE Id = @Id;
			-- 			execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END

		-- 1 Очікує прийому в роботу	WaitingForWork
		-- 3 Перенаправлено за належністю	RedirectedByAffiliation
		IF @result_id = 1
			AND @resolution_id = 3
		BEGIN

			UPDATE Assignments
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,assignment_state_id = @ass_state_id -- 04_04
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,executor_organization_id = @transfer_to_organization_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row695'
			WHERE Id = @Id;

			UPDATE dbo.AssignmentConsiderations
			SET consideration_date = GETUTCDATE()
				,assignment_result_id = @result_id
				,assignment_resolution_id = @resolution_id
				,transfer_to_organization_id = @transfer_to_organization_id
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,[short_answer] = @short_answer
			WHERE Id = @current_consid;

			DELETE FROM @output_con;

			INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
			, [consideration_date]
			, [assignment_result_id]
			, [assignment_resolution_id]
			, [user_id]
			, [edit_date]
			, [user_edit_id]
			, turn_organization_id
			, [first_executor_organization_id]
			, [short_answer]
			, create_date)
			OUTPUT INSERTED.Id INTO @output_con ([Id])
				SELECT
					@Id
					,GETUTCDATE()
					,@result_id
					,@resolution_id
					,@user_edit_id
					,GETUTCDATE()
					,@user_edit_id
					,NULL
					,@transfer_to_organization_id
					,@short_answer
					,GETUTCDATE()
				FROM AssignmentConsiderations
				WHERE Id = @current_consid;

			SET @new_con = (SELECT
								max(Id)
							FROM
								dbo.[AssignmentConsiderations] 
							WHERE assignment_id = @Id);
			UPDATE [Assignments]
			SET current_assignment_consideration_id = @new_con
				,[edit_date] = GETUTCDATE()
			WHERE Id = @Id; -- @ass_id
			-- 			execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END

		-- 04_04_2019
		--Результат: 4 Виконано, резолюція – 4 Очікує підтвердження заявником
		--Результат: 7 Роз’яснено, резолюція – 5 Потребує перевірки куратором
		--Результат: 8 Не можливо виконати в даний період, резолюція – 12 Потребує фінансування/Включено в план-програму
		IF (@result_id = 4
			AND @resolution_id = 4)
			OR (@result_id = 7
			AND @resolution_id = 5)
			OR (@result_id = 8
			AND @resolution_id = 12)
		BEGIN
			UPDATE Assignments
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				--,executor_organization_id = @transfer_to_organization_id
				,assignment_state_id = @ass_state_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row756'
			WHERE Id = @Id;

			UPDATE dbo.AssignmentConsiderations
			SET consideration_date = GETUTCDATE()
				,assignment_result_id = @result_id
				,assignment_resolution_id = @resolution_id
				--,transfer_to_organization_id = @transfer_to_organization_id
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				,[short_answer] = @short_answer
			WHERE Id = @current_consid;


			INSERT INTO [dbo].[AssignmentRevisions] ([assignment_consideration_іd]
			, [control_type_id]
			, [assignment_resolution_id]
			, [control_comment]
			--    ,[control_date]
			, [user_id]
			, [rework_counter]
			, [edit_date]
			, [user_edit_id]
			--,create_date
			)
				VALUES (@current_consid --@ass_cons_id
				, 2  -- @control_type_id = Контроль, Продзвон, Контроль заявником
				, @resolution_id -- @assignment_resolution_id
				, @control_comment
				--    ,getutcdate() 
				, @user_edit_id --@user_id
				-- ,@rework_counter_count
				, @rework_counter, GETUTCDATE() --@edit_date
				, @user_edit_id
				--,@create_date
				);
			-- 		execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END

		--Результат: 5 На доопрацювання,   резолюція – 8 Виконання не підтверджено завником
		-- 7 Спростовано куратором
		IF @result_id = 5
			AND (@resolution_id = 8
			OR @resolution_id = 7)
		BEGIN
			DECLARE @rework_counter_count INT;

			IF @rework_counter IS NOT NULL
				OR @rework_counter <> 0
			--if @result_id = 5
			BEGIN
				SET @rework_counter_count = @rework_counter + 1;
			END
			ELSE
			BEGIN
				SET @rework_counter_count = @rework_counter;
			END

			UPDATE [dbo].[AssignmentRevisions]
			SET [assignment_resolution_id] = @resolution_id
				,[control_comment] = @control_comment
				,[rework_counter] = @rework_counter_count
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,control_date = GETUTCDATE()
				,control_result_id = @result_id
			WHERE [assignment_consideration_іd] = @ass_cons_id;

			UPDATE Assignments
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				--,executor_organization_id = @transfer_to_organization_id
				,assignment_state_id = @ass_state_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row837'
			WHERE Id = @Id;

			DELETE FROM @output_con;

			INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
			, [consideration_date]
			, [assignment_result_id]
			, [assignment_resolution_id]
			, [user_id]
			, [edit_date]
			, [user_edit_id]
			, turn_organization_id
			, [first_executor_organization_id]
			, [short_answer]
			, create_date)
			OUTPUT INSERTED.Id INTO @output_con ([Id])
				SELECT
					@Id
					,GETUTCDATE()
					,@result_id
					,@resolution_id
					,@user_edit_id
					,GETUTCDATE()
					,@user_edit_id
					,NULL
					--,@transfer_to_organization_id
					,first_executor_organization_id
					,@short_answer
					,GETUTCDATE()
				FROM AssignmentConsiderations
				WHERE Id = @current_consid;

			SET @new_con = (SELECT
								max(Id)
							FROM
								dbo.[AssignmentConsiderations] 
							WHERE assignment_id = @Id);
			UPDATE [Assignments]
			SET current_assignment_consideration_id = @new_con
				,[edit_date] = GETUTCDATE()
			WHERE Id = @Id;

			-- execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END


		--Результат: 12 Фактично,   резолюція - 7 Спростовано куратором 8-Виконання не підтверджено завником
		IF @result_id = 12
			AND (@resolution_id = 7
			OR @resolution_id = 8)
		BEGIN
			UPDATE [dbo].[AssignmentRevisions]
			SET [assignment_resolution_id] = @resolution_id
				,[control_comment] = @control_comment
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,control_date = GETUTCDATE()
				,control_result_id = @result_id
				,rework_counter = @rework_counter + 1
			WHERE [assignment_consideration_іd] = @ass_cons_id;

			UPDATE Assignments
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,edit_date = GETUTCDATE()
				,user_edit_id = @user_edit_id
				--,executor_organization_id = @transfer_to_organization_id
				,assignment_state_id = @ass_state_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row907'
			WHERE Id = @Id;

			DELETE FROM @output_con;

			INSERT INTO dbo.AssignmentConsiderations ([assignment_id]
			, [consideration_date]
			, [assignment_result_id]
			, [assignment_resolution_id]
			, [user_id]
			, [edit_date]
			, [user_edit_id]
			, turn_organization_id
			, [first_executor_organization_id]
			, [short_answer]
			, create_date)
			OUTPUT INSERTED.Id INTO @output_con ([Id])
				SELECT
					@Id
					,GETUTCDATE()
					,@result_id
					,@resolution_id
					,@user_edit_id
					,GETUTCDATE()
					,@user_edit_id
					,NULL
					--,@transfer_to_organization_id
					,first_executor_organization_id
					,@short_answer
					,GETUTCDATE()
				FROM AssignmentConsiderations
				WHERE Id = @current_consid;

			SET @new_con = (SELECT TOP (1)
					Id
				FROM @output_con);
			UPDATE [Assignments]
			SET current_assignment_consideration_id = @new_con
				,[edit_date] = GETUTCDATE()
			WHERE Id = @Id;

			-- execute define_status_Question @question_id
			-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id
			RETURN;
		END


		IF @ass_state_id = 5
		BEGIN

			UPDATE AssignmentConsiderations
			SET [edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,[assignment_result_id] = @result_id
				,[assignment_resolution_id] = @resolution_id
				,short_answer = @short_answer
			WHERE Id = @current_consid;

			UPDATE [Assignments]
			SET AssignmentResultsId = @result_id
				,AssignmentResolutionsId = @resolution_id
				,[edit_date] = GETUTCDATE()
				,[user_edit_id] = @user_edit_id
				,close_date = GETUTCDATE()
				,current_assignment_consideration_id = @current_consid
				,assignment_state_id = @ass_state_id
				,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row965'
			WHERE Id = @Id;

			IF EXISTS (SELECT
						1
					FROM AssignmentRevisions AssignmentRevisions
					WHERE assignment_consideration_іd = @current_consid)
			BEGIN
				UPDATE AssignmentRevisions
				SET [assignment_resolution_id] = @resolution_id
					,organization_id = @transfer_to_organization_id
					,[control_comment] = @control_comment
					,[rework_counter] = @rework_counter_count
					,[edit_date] = GETUTCDATE()
					,[user_edit_id] = @user_edit_id
					,control_result_id = @resolution_id
					,control_date = GETUTCDATE()
				WHERE assignment_consideration_іd = @current_consid;
			END
		-- execute define_status_Question @question_id
		-- exec pr_chech_in_status_assignment @Id, @result_id, @resolution_id

		END

		UPDATE AssignmentConsiderations
		SET [edit_date] = GETUTCDATE()
			,[user_edit_id] = @user_edit_id
			,[assignment_result_id] = @result_id
			,[assignment_resolution_id] = @resolution_id
			,short_answer = @short_answer
		WHERE Id = @current_consid;

		UPDATE [Assignments]
		SET AssignmentResultsId = @result_id
			,AssignmentResolutionsId = @resolution_id
			,[edit_date] = GETUTCDATE()
			,[user_edit_id] = @user_edit_id
			,[LogUpdated_Query] = N'cx_App_Que_Assignments_Update_Row1000'
		--  ,close_date = GETUTCDATE()
		WHERE Id = @Id;

	END --(F11)
END
END
END;

  --declare @Id int=2969235;
  --declare @assignment_resolution_id int = 8;
  --declare @control_result_id int = 5;
  --declare @control_comment nvarchar(300)=N'qweqq';
  --declare @grade int=5;

  
--якщо дане доручення закрите то нічого не робити - return
IF  (SELECT assignment_state_id FROM [dbo].[Assignments] WHERE Id = @Id) = 5
BEGIN
	RETURN;
END

  DECLARE @out TABLE (Id INT);
  DECLARE @result_of_checking INT;

-- проверка через таблицу трансмишн, если "0" то return
EXEC [dbo].[pr_check_right_choice_result_resolution_notStatus] @Id, @control_result_id, @assignment_resolution_id, @result_of_checking OUTPUT;
IF @result_of_checking = 0
BEGIN
	RETURN;
END

		DECLARE @state_id INT=
		(SELECT DISTINCT [new_assignment_state_id] FROM [dbo].[TransitionAssignmentStates] 
		WHERE [new_assignment_result_id] = @control_result_id
		AND ISNULL([new_assignment_resolution_id],0) = ISNULL(@assignment_resolution_id,0));


		--- находим вопрос данного обращения
		DECLARE @question_id INT = (  SELECT TOP 1 question_id FROM [dbo].[Assignments] WHERE [Id] = @Id);
	
		--- переход на таблички, создание 
		DECLARE @assigments_table TABLE (Id INT,rework_counter INT,	curent_consid_id INT, question_id INT, main_executor BIT);
		DECLARE @assigments_consideration_table TABLE (Id INT); -- все Id записи из таблицы AssignmentConsiderations если вопрос- главный

		IF @control_result_id = 5 OR @control_result_id = 12 --На доопрацювання та фактично
			BEGIN
				INSERT INTO @assigments_table (Id, rework_counter,curent_consid_id)
				SELECT
					ass.Id
					, (SELECT TOP 1	rework_counter	FROM [dbo].[AssignmentRevisions] 
							WHERE assignment_consideration_іd = ass.current_assignment_consideration_id
							ORDER BY Id DESC)
					, ass.current_assignment_consideration_id
				FROM [dbo].[Assignments] AS ass
				WHERE ass.Id = @Id AND [main_executor]='true' AND ass.assignment_state_id <> 5;--ограничение на закрытое
			END
		ELSE 
			BEGIN
				INSERT INTO @assigments_table (Id,rework_counter, curent_consid_id, question_id, main_executor)
				SELECT Id, NULL, current_assignment_consideration_id, question_id, main_executor
				FROM [dbo].[Assignments]
				WHERE Id = @Id 
				AND [Assignments].assignment_state_id<>5;--ограничение на закрытое
			END

		IF (SELECT main_executor FROM @assigments_table WHERE Id =@Id)='true'
			BEGIN
				INSERT INTO @assigments_consideration_table (Id)
				SELECT [Assignments].current_assignment_consideration_id
				FROM [dbo].[Assignments]
				INNER JOIN @assigments_table atab ON [Assignments].question_id=atab.question_id
				where atab.Id=@Id and [Assignments].assignment_state_id<>5;--ограничение на закрытое
			END

				--какие-то мутки, начало
						IF @control_result_id <> 4
						BEGIN
							UPDATE [dbo].[AssignmentRevisions]
							SET 
							--  [assignment_resolution_id]= isnull(@assignment_resolution_id, assignment_resolution_id)
							 [assignment_resolution_id]= @assignment_resolution_id
							,[control_result_id]= ( CASE WHEN ast.rework_counter < 2 THEN 5
														WHEN ast.rework_counter >= 2 THEN 12
														-- when ast.rework_counter is null then @control_result_id
														ELSE @control_result_id
														END )
							,control_date = GETUTCDATE()
							,[control_comment]=isnull(@control_comment, control_comment)
							-- ,[grade]=@grade
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
							,[missed_call_counter]=(CASE WHEN @control_result_id=13 AND [missed_call_counter] IS NULL THEN 1 
														WHEN @control_result_id=13 AND [missed_call_counter] IS NOT NULL THEN [missed_call_counter]+1 
														ELSE [missed_call_counter] END )
							FROM @assigments_table AS ast
							WHERE  [assignment_consideration_іd] IN (SELECT curent_consid_id FROM @assigments_table);
						END


					IF @control_result_id <> 13 AND @control_result_id <> 4
						BEGIN
							UPDATE [dbo].[Assignments]
							SET  [assignment_state_id]=@state_id
								,[AssignmentResultsId]=( CASE WHEN ast.rework_counter < 2 THEN 5
																WHEN ast.rework_counter >= 2 THEN 12
																-- when ast.rework_counter is null then @control_result_id
																ELSE @control_result_id
																END )
								,[AssignmentResolutionsId]=@assignment_resolution_id
								,[user_edit_id]=@user_id
								,[edit_date]=GETUTCDATE()
								,[close_date]= CASE WHEN @state_id=5 THEN GETUTCDATE() ELSE [close_date] END
								,LogUpdated_Query = N'Prozvon_Close_v2_ROW105'											
							FROM @assigments_table AS ast
							WHERE [Assignments].Id IN (SELECT Id FROM @assigments_table);

							-- здесь где-то должен создаваться новый [AssignmentConsiderations]!!!!!!!!!!!
							IF @control_result_id = 5 OR @control_result_id = 12
							BEGIN
								DELETE FROM @out;

								INSERT INTO [dbo].AssignmentConsiderations
									(
									 [assignment_id]
									,[consideration_date]
									,[assignment_result_id]
									,[assignment_resolution_id]
									,[user_id]
									,[edit_date]
									,[user_edit_id]
									,turn_organization_id
									,[first_executor_organization_id]
									,create_date
									)
									OUTPUT inserted.Id INTO @out(Id)
									SELECT 
										@Id
										,consideration_date
										,@control_result_id
										,@assignment_resolution_id
										,@user_id
										,GETUTCDATE()
										,@user_id
										,turn_organization_id
										,first_executor_organization_id
										,GETUTCDATE()
									FROM [dbo].[AssignmentConsiderations] 
									WHERE [AssignmentConsiderations].Id IN (SELECT curent_consid_id FROM @assigments_table);

								DECLARE @new_con_id INT = (SELECT TOP 1 Id FROM @out);
								UPDATE [dbo].[Assignments] 
									SET current_assignment_consideration_id = @new_con_id
									    ,[edit_date]=getutcdate() 
										--,LogUpdated_Query =N'Prozvon_Close_ROW141'
									WHERE Id = @Id;

									UPDATE [dbo].[AssignmentRevisions]
									SET
									[rework_counter]=ISNULL([rework_counter],0)+1
									,[edit_date]=GETUTCDATE()
									,[user_edit_id]=@user_id
									WHERE assignment_consideration_іd=(SELECT TOP 1 curent_consid_id FROM @assigments_table ORDER BY Id DESC);
							END
							ELSE
							BEGIN
								UPDATE [dbo].[AssignmentConsiderations]
								SET [assignment_result_id] = ( CASE WHEN ast.rework_counter < 2 THEN 5
																WHEN ast.rework_counter >= 2 THEN 12
																-- when ast.rework_counter is null then @control_result_id
																ELSE  @control_result_id
																END )
									,[assignment_resolution_id]=@assignment_resolution_id
									,[edit_date]=GETUTCDATE()
									,[user_edit_id]=@user_id
									FROM @assigments_table AS ast
									WHERE [AssignmentConsiderations].Id IN (SELECT curent_consid_id FROM @assigments_table);
							END

						END

					-----
					IF @control_result_id IN (4,10,11)-- виконано 11 10
					BEGIN

					--добавление в ревижен записей, которых нет начало
					INSERT INTO [dbo].[AssignmentRevisions]
					  (
					  [assignment_consideration_іd]
						  ,[control_type_id]
						  ,[assignment_resolution_id]
						  ,[control_result_id]
						  ,[organization_id]
						  ,[control_comment]
						  ,[control_date]
						  ,[user_id]
						  ,[grade]
						  ,[grade_comment]
						  ,[rework_counter]
						  ,[missed_call_counter]
						  ,[edit_date]
						  ,[user_edit_id]
					  )

					  SELECT act.Id [assignment_consideration_іd]
						  ,2 [control_type_id]
						  ,@assignment_resolution_id [assignment_resolution_id]
						  ,@control_result_id [control_result_id]
						  ,null [organization_id]
						  ,@control_comment [control_comment]
						  ,GETUTCDATE() [control_date]
						  ,@user_id [user_id]
						  ,case when @control_result_id not in (5/*На доопрацювання*/, 10/*Закрито автоматично*/, 11/*Самостійно*/, 12/*Фактично*/) then @grade else null end [grade]
						  ,null [grade_comment]
						  ,null [rework_counter]
						  ,null [missed_call_counter]
						  ,getutcdate() [edit_date]
						  ,@user_id [user_edit_id]
					 FROM @assigments_consideration_table act
					 LEFT JOIN [AssignmentRevisions] r ON act.Id=r.assignment_consideration_іd
					 WHERE r.assignment_consideration_іd IS NULL

							--добавление в ревижен записей, которых нет конец

						UPDATE   [dbo].[AssignmentRevisions]
						SET  [assignment_resolution_id]= @assignment_resolution_id
							,[control_result_id]=@control_result_id
							,[control_comment]=@control_comment
							,control_date = GETUTCDATE()
							--,[grade]=@grade
							,[grade]=case when @control_result_id not in (5/*На доопрацювання*/, 10/*Закрито автоматично*/, 11/*Самостійно*/, 12/*Фактично*/) then @grade else [grade] end
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
						WHERE [assignment_consideration_іd] IN (SELECT curent_consid_id FROM  @assigments_table);

						-- проставляется комментарий не главным вопросам
						UPDATE   [dbo].[AssignmentRevisions]
						SET [control_comment]=@control_comment
						WHERE [assignment_consideration_іd] IN (SELECT id FROM  @assigments_consideration_table);


						UPDATE   [dbo].[Assignments]
						SET  [assignment_state_id]=@state_id
							,[AssignmentResultsId]=@control_result_id
							,[AssignmentResolutionsId]=@assignment_resolution_id
							,[user_edit_id]=@user_id
							,[state_change_date] = GETUTCDATE()
							,[edit_date]=GETUTCDATE()
							,[close_date]= CASE WHEN @state_id=5 THEN GETUTCDATE() ELSE [close_date] END
							,LogUpdated_Query = N'Prozvon_Close_v2_ROW240'											
						WHERE [Assignments].Id IN (SELECT Id FROM @assigments_table);

						/*
						UPDATE [dbo].[AssignmentConsiderations]
						SET	   [assignment_result_id] = @control_result_id
							,[assignment_resolution_id]=@assignment_resolution_id
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
						WHERE Id IN (SELECT curent_consid_id FROM @assigments_table);
						*/
					END

					IF @control_result_id<>13
						BEGIN
							UPDATE [dbo].[AssignmentRevisions]
							SET [control_comment]= @control_comment
							WHERE [assignment_consideration_іd] IN (SELECT curent_consid_id FROM @assigments_table);
						END					
			

if @control_result_id = 13 
begin 
declare @output table (Id int);
declare @Operation varchar(128);
declare @Missed_call_counter int = isnull((select isnull(max([Missed_call_counter]),0) from [dbo].[AssignmentDetailHistory] with (nolock) where [Assignment_id] = @Id),0)+1	
SET @Operation = 'UPDATE';
Insert into [dbo].[AssignmentDetailHistory] ([Assignment_id]
									  ,[SourceHistory]
									  ,[Operation]
									  ,[Missed_call_counter]	
									  ,[MissedCallComment]
									  ,[User_id]
									  ,[Edit_date]
									  )
output [inserted].[Id] into @output (Id)
values ( @Id, N'Call', @Operation, @Missed_call_counter, @control_comment, @user_id, getutcdate() )

declare @app_id int
set @app_id = (select top 1 Id from @output)

--select @app_id as [Id]
--return;
end;	

SELECT 
	(SELECT registration_number FROM [dbo].[Questions] WHERE Id = @question_id ) AS question_id,
	(SELECT [name] FROM [dbo].[AssignmentResults] WHERE Id = (SELECT AssignmentResultsId FROM [dbo].[Assignments] WHERE Id = @Id  ) ) AS control_result_id;
RETURN;

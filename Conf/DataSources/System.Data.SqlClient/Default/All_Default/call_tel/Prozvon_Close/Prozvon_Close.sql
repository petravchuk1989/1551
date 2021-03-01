
  --declare @Id int=2969235;
  --declare @assignment_resolution_id int = 8;
  --declare @control_result_id int = 5;
  --declare @control_comment nvarchar(300)=N'qweqq';

  
--якщо дане доручення закрите то нічого не робити - return
IF  (SELECT assignment_state_id FROM [Assignments] WHERE Id = @Id) = 5
BEGIN
	RETURN
END

  declare @out table(Id int)
  DECLARE @result_of_checking INT

-- проверка через таблицу трансмишн, если "0" то return
exec [dbo].[pr_check_right_choice_result_resolution_notStatus] @Id, @control_result_id, @assignment_resolution_id, @result_of_checking OUTPUT
IF @result_of_checking = 0
BEGIN
	RETURN;
END

		declare @state_id int=
		(select distinct [new_assignment_state_id] from [TransitionAssignmentStates] 
		where [new_assignment_result_id] = @control_result_id
		and isnull([new_assignment_resolution_id],0) = isnull(@assignment_resolution_id,0))


		--- находим вопрос данного обращения
		declare @question_id int = (  select question_id from [Assignments] where [Id] = @Id);
	
		--- переход на таблички, создание 
		DECLARE @assigments_table TABLE (Id INT,rework_counter INT,	curent_consid_id INT);
		declare @assigments_consideration_table table (Id int); -- Id записи из таблицы AssignmentConsiderations

		if @control_result_id = 5 or @control_result_id = 12 --На доопрацювання та фактично
			begin
				INSERT INTO @assigments_table (Id, rework_counter,curent_consid_id)
				SELECT
					ass.Id
					, (SELECT TOP 1	rework_counter	FROM AssignmentRevisions 
							WHERE assignment_consideration_іd = ass.current_assignment_consideration_id
							ORDER BY Id DESC)
					, ass.current_assignment_consideration_id
				FROM [Assignments] AS ass
				WHERE ass.Id = @Id AND [main_executor]='true' AND ass.assignment_state_id <> 5--ограничение на закрытое
			end
		else 
			begin
				insert into @assigments_table (Id,rework_counter, curent_consid_id)
				select Id, NULL, current_assignment_consideration_id
				from [Assignments]
				where Id = @Id 
				and [Assignments].assignment_state_id<>5--ограничение на закрытое
			end


				--какие-то мутки, начало
						if @control_result_id <> 4
						begin
							update [dbo].[AssignmentRevisions]
							set 
							--  [assignment_resolution_id]= isnull(@assignment_resolution_id, assignment_resolution_id)
							 [assignment_resolution_id]= @assignment_resolution_id
							,[control_result_id]= ( case when ast.rework_counter < 2 then 5
														when ast.rework_counter >= 2 then 12
														-- when ast.rework_counter is null then @control_result_id
														else @control_result_id
														end )
							,control_date = GETUTCDATE()
							,[control_comment]=isnull(@control_comment, control_comment)
							-- ,[grade]=@grade
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
							,[missed_call_counter]=(case when @control_result_id=13 and [missed_call_counter] is null then 1 
														when @control_result_id=13 and [missed_call_counter] is not null then [missed_call_counter]+1 
														else [missed_call_counter] end )
							from @assigments_table as ast
							where  [assignment_consideration_іd] in (select curent_consid_id from @assigments_table)
						end


					if @control_result_id <> 13 and @control_result_id <> 4
						begin
							update [dbo].[Assignments]
							set  [assignment_state_id]=@state_id
								,[AssignmentResultsId]=( case when ast.rework_counter < 2 then 5
																when ast.rework_counter >= 2 then 12
																-- when ast.rework_counter is null then @control_result_id
																else @control_result_id
																end )
								,[AssignmentResolutionsId]=@assignment_resolution_id
								,[user_edit_id]=@user_id
								,[edit_date]=GETUTCDATE()
								,[close_date]= case when @state_id=5 then GETUTCDATE() else [close_date] end
								,LogUpdated_Query = N'Prozvon_Close_ROW156'											
							from @assigments_table as ast
							where [Assignments].Id in (select Id from @assigments_table)

							-- здесь где-то должен создаваться новый [AssignmentConsiderations]!!!!!!!!!!!
							if @control_result_id = 5 or @control_result_id = 12
							begin
								delete from @out

								insert into AssignmentConsiderations
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
									output inserted.Id into @out(Id)
									select 
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
									from [AssignmentConsiderations] 
									where [AssignmentConsiderations].Id in (select curent_consid_id from @assigments_table)

								declare @new_con_id int = (select top 1 Id from @out)
								update Assignments 
									set current_assignment_consideration_id = @new_con_id
									    ,[edit_date]=getutcdate() 
										--,LogUpdated_Query =N'Prozvon_Close_ROW141'
									where Id = @Id
							end
							else
							begin
								update [dbo].[AssignmentConsiderations]
								set [assignment_result_id] = ( case when ast.rework_counter < 2 then 5
																when ast.rework_counter >= 2 then 12
																-- when ast.rework_counter is null then @control_result_id
																else  @control_result_id
																end )
									,[assignment_resolution_id]=@assignment_resolution_id
									,[edit_date]=GETUTCDATE()
									,[user_edit_id]=@user_id
									from @assigments_table as ast
									where [AssignmentConsiderations].Id in (SELECT curent_consid_id FROM @assigments_table)
							end

						end

					-----
					if @control_result_id = 4-- виконано
					begin

						update   [dbo].[AssignmentRevisions]
						set  [assignment_resolution_id]= @assignment_resolution_id
							,[control_result_id]=@control_result_id
							,control_date = GETUTCDATE()
							,[control_comment]=@control_comment
							,[grade]=@grade
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
						where [assignment_consideration_іd] in (select curent_consid_id from @assigments_table)

						update   [dbo].[Assignments]
						set  [assignment_state_id]=@state_id
							,[AssignmentResultsId]=@control_result_id
							,[AssignmentResolutionsId]=@assignment_resolution_id
							,[user_edit_id]=@user_id
							,[edit_date]=GETUTCDATE()
							,[close_date]= case when @state_id=5 then GETUTCDATE() else [close_date] end
							,LogUpdated_Query = N'Prozvon_Close_ROW199'											
						where [Assignments].Id in (select Id from @assigments_table)

						update   [dbo].[AssignmentConsiderations]
						set	   [assignment_result_id] = @control_result_id
							,[assignment_resolution_id]=@assignment_resolution_id
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
						where Id in (SELECT curent_consid_id FROM @assigments_table)
					end

					if @control_result_id<>13
						begin
							update [AssignmentRevisions]
							set [control_comment]= @control_comment
							where [assignment_consideration_іd] in (select curent_consid_id FROM @assigments_table)
						end
			

SELECT 
	(select registration_number from Questions where Id = @question_id ) as question_id,
	(select [name] from AssignmentResults where Id = (select AssignmentResultsId from Assignments where Id = @Id  ) ) as control_result_id
return


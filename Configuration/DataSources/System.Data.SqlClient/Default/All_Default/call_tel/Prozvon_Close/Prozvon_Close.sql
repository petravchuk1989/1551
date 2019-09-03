
  --declare @Id int=2969235;
  --declare @assignment_resolution_id int = 8;
  --declare @control_result_id int = 5;
  --declare @control_comment nvarchar(300)=N'qweqq';

  declare @out table(Id int)
  DECLARE @result_of_checking INT

exec [dbo].[pr_check_right_choice_result_resolution_notStatus] @Id, @control_result_id, @assignment_resolution_id, @result_of_checking OUTPUT
IF @result_of_checking = 0
BEGIN
		-- RAISERROR ('Стан доручення залишився попереднім, оновіть сторінку, та спробуйте ще раз', 16, 1);
	RETURN;
END

		declare @state_id int=
		(select distinct [new_assignment_state_id] from [TransitionAssignmentStates] 
		where [new_assignment_result_id]=@control_result_id
		and isnull([new_assignment_resolution_id],0)=isnull(@assignment_resolution_id,0))

								--select @state_id, @assignment_resolution_id, @control_result_id

		--- находим вопрос данного обращения
		declare @question_id int = (  select question_id from [Assignments] where [Id] = @Id);

		--консидерейшен данного обращения
		declare @current_assignment_consideration_id int =  (select [current_assignment_consideration_id]  from [dbo].[Assignments] where Id=@Id)
							
		--- переход на таблички, создание 
		declare @assigments_table table (Id int, rework_counter int);
		declare @assigments_consideration_table table (Id int); -- Id записи из таблицы AssignmentConsiderations

		if @control_result_id = 5 or @control_result_id = 12 --На доопрацювання та фактично
			begin
				insert into @assigments_table (Id, rework_counter)
				select 
					ass.Id
					,ar.rework_counter
				from [Assignments] as ass
					join AssignmentConsiderations as ac on ac.Id = ass.current_assignment_consideration_id
					join AssignmentRevisions as ar on ar.assignment_consideration_іd = ac.Id 
				where ass.question_id=@question_id and [main_executor]='true'
				and ass.assignment_state_id<>5--ограничение на закрытое

				insert into @assigments_consideration_table (Id)
				select current_assignment_consideration_id
				from [Assignments]
				where question_id=@question_id and [main_executor]='true'
				and [Assignments].assignment_state_id <> 5--ограничение на закрытое
			end
							--select * from @assigments_table
							--select * from @assigments_consideration_table
		else 
			begin
				insert into @assigments_table (Id,rework_counter)
				select Id, NULL
				from [Assignments]
				where question_id=@question_id
				and [Assignments].assignment_state_id<>5--ограничение на закрытое

				insert into @assigments_consideration_table (Id)
				select current_assignment_consideration_id
				from [Assignments]
				where question_id=@question_id
				and [Assignments].assignment_state_id<>5--ограничение на закрытое
			end


		--якщо дане доручення закрите то нічого не робити
		if  (select assignment_state_id from [Assignments] where Id=@Id) <> 5
			begin
				--какие-то мутки, начало
						if @control_result_id <> 4
						begin
							update [CRM_1551_Analitics].[dbo].[AssignmentRevisions]
							set [assignment_resolution_id]=@assignment_resolution_id
							,[control_result_id]= ( case when ast.rework_counter < 2 then 5
														when ast.rework_counter >= 2 then 12
														when ast.rework_counter is null then @control_result_id
														end )
							,[control_comment]=@control_comment
							,[grade]=@grade
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
							,[missed_call_counter]=(case when @control_result_id=13 and [missed_call_counter] is null then 1 
														when @control_result_id=13 and [missed_call_counter] is not null then [missed_call_counter]+1 
														else [missed_call_counter] end )
							from @assigments_table as ast
							where  [assignment_consideration_іd] in (select Id from @assigments_consideration_table)
						end


					if @control_result_id <> 13 and @control_result_id <> 4
						begin
							update [dbo].[Assignments]
							set  [assignment_state_id]=@state_id
								,[AssignmentResultsId]=( case when ast.rework_counter < 2 then 5
																when ast.rework_counter >= 2 then 12
																when ast.rework_counter is null then @control_result_id
																end )
								,[AssignmentResolutionsId]=@assignment_resolution_id
								,[user_edit_id]=@user_id
								,[edit_date]=GETUTCDATE()
								,[close_date]= case when @state_id=5 then GETUTCDATE() else [close_date] end
								,LogUpdated_Query = N'Prozvon_Close_ROW156'											
							from @assigments_table as ast
							where [Assignments].Id in (select Id from @assigments_table) 
							--[question_id]=@question_id

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
									-- ,[short_answer]
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
									where [AssignmentConsiderations].Id in (select Id from @assigments_consideration_table)

								declare @new_con_id int = (select top 1 Id from @out)
								update Assignments 
									set current_assignment_consideration_id = @new_con_id 
										,LogUpdated_Query =N'Prozvon_Close_ROW141'
									where Id = @Id
							end
							else
							begin
								update [dbo].[AssignmentConsiderations]
								set [assignment_result_id] = ( case when ast.rework_counter < 2 then 5
																when ast.rework_counter >= 2 then 12
																when ast.rework_counter is null then @control_result_id
																end )
									,[assignment_resolution_id]=@assignment_resolution_id
									,[edit_date]=GETUTCDATE()
									,[user_edit_id]=@user_id
									from @assigments_table as ast
									where [AssignmentConsiderations].Id in (select Id from @assigments_consideration_table)
							end

					end

					-----
					if @control_result_id=4-- виконано
					begin

						update [CRM_1551_Analitics].[dbo].[AssignmentRevisions]
						set  [assignment_resolution_id]= @assignment_resolution_id
							,[control_result_id]=@control_result_id
							,[control_comment]=@control_comment
							,[grade]=@grade
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
						where [assignment_consideration_іd] in (select Id from @assigments_consideration_table)

						update [CRM_1551_Analitics].[dbo].[Assignments]
						set  [assignment_state_id]=@state_id
							,[AssignmentResultsId]=@control_result_id
							,[AssignmentResolutionsId]=@assignment_resolution_id
							,[user_edit_id]=@user_id
							,[edit_date]=GETUTCDATE()
							,[close_date]= case when @state_id=5 then GETUTCDATE() else [close_date] end
							,LogUpdated_Query = N'Prozvon_Close_ROW199'											
						where [Assignments].Id in (select Id from @assigments_table)

						update [CRM_1551_Analitics].[dbo].[AssignmentConsiderations]
						set	   [assignment_result_id] = @control_result_id
							,[assignment_resolution_id]=@assignment_resolution_id
							,[edit_date]=GETUTCDATE()
							,[user_edit_id]=@user_id
						where Id in (select Id from @assigments_consideration_table)
					end

					if @control_result_id<>13
						begin
							update [AssignmentRevisions]
							set [control_comment]=@control_comment
							where [assignment_consideration_іd] in (select Id from @assigments_consideration_table)
							--(select [current_assignment_consideration_id]
							--from [CRM_1551_Analitics].[dbo].[Assignments]
							--where question_id=@question_id)
						end
			end

		SELECT 
				(select registration_number from Questions where Id = @question_id ) as question_id, 
				-- @Id as Id, 
				(select [name] from AssignmentResults where Id = (select AssignmentResultsId from Assignments where Id = @Id  ) ) as control_result_id
				-- (select [name] from AssignmentResults where Id = @control_result_id ) as control_result_id
		return

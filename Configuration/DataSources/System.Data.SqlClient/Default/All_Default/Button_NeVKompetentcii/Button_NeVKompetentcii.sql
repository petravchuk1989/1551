

--declare @executor_organization_id int, @Id int, @user_edit_id nvarchar(128)

declare @output table (Id int);
declare @output_con table (Id int);
declare @new_con int;
declare @ass_id int;
declare @result_id int;
declare @resolution_id int;
declare @current_consid int;
declare @ass_state_id  int;
declare @question_id int
declare @is_main_exec bit


--при виборі одного й того самого виконався стан проставляти на зареєстровано
if @executor_organization_id=(select [executor_organization_id]
  from [Assignments]
  where Id=@Id)
begin



update Assignments
set [assignment_state_id]=1
			,edit_date = GETUTCDATE()
			,user_edit_id = @user_edit_id
			,[LogUpdated_Query] = N'Button_NeVKompetentcii_Row22'
where Id=@Id
end

--

if @executor_organization_id is not null
begin


	select @ass_state_id  = assignment_state_id
	, @result_id = AssignmentResultsId
	, @resolution_id = AssignmentResolutionsId
	, @current_consid = current_assignment_consideration_id
	,@question_id = question_id 
	from Assignments where Id = @Id

	

     -- 3 Не в компетенції	NotInTheCompetence 
	-- 14 Повернуто в батьківську організацію	ReturnedToParentOrganization

	declare @new_res int
	declare @new_resol int


	IF @result_id = 3 and @resolution_id = 14
	BEGIN
		if (select first_executor_organization_id from AssignmentConsiderations where Id = @current_consid) = @executor_organization_id
		begin



						set @new_res  = 6 -- 6 Повернуто виконавцю	ReturnedToTheArtist
						set @new_resol = 3 -- 3 Перенаправлено за належністю	RedirectedByAffiliation

							set @executor_organization_id = (select first_executor_organization_id from AssignmentConsiderations where Id = @current_consid)

							update Assignments 
									set 
									 AssignmentResultsId = @new_res
									,AssignmentResolutionsId = @new_resol
									,edit_date = GETUTCDATE()
									,user_edit_id = @user_edit_id
									,[LogUpdated_Query] = N'Button_NeVKompetentcii_Row62'
									 where id = @Id

							update dbo.AssignmentConsiderations 
									set	 
									consideration_date = GETUTCDATE()
									,assignment_result_id = @new_res
									,assignment_resolution_id = @new_resol
									,transfer_to_organization_id = @executor_organization_id
									,edit_date = GETUTCDATE()
									,user_edit_id = @user_edit_id
									 where Id = @current_consid 
	
	
							delete from @output_con
							insert into dbo.AssignmentConsiderations
								(	 [assignment_id]
									,[consideration_date]
									,[assignment_result_id]
									,[assignment_resolution_id]
									,[user_id]
									,[edit_date]
									,[user_edit_id]
									,[first_executor_organization_id]
									,create_date
									,transfer_date
								)
								output inserted.Id into @output_con([Id])
								values
								(	@Id
									,GETUTCDATE()
									,@new_res
									,@new_resol
									,@user_edit_id
									,GETUTCDATE()
									,@user_edit_id
									,@executor_organization_id
									,GETUTCDATE()
									,GETUTCDATE()
								)


							set @new_con = (select top (1) Id from @output_con)
							update [Assignments] set current_assignment_consideration_id = @new_con where Id = @Id



			end
			else
				-- 1 Очікує прийому в роботу	WaitingForWork
				-- 3 Перенаправлено за належністю	RedirectedByAffiliation
				-- if @result_id = 1 and @resolution_id = 3
			begin

				set @new_res  = 1 -- 1 Очікує прийому в роботу	WaitingForWork
				set @new_resol  = 3 -- 3 Перенаправлено за належністю	RedirectedByAffiliation


				update Assignments 
						set 
						 AssignmentResultsId = @new_res
						,AssignmentResolutionsId = @new_resol
						,edit_date = GETUTCDATE()
						,user_edit_id = @user_edit_id
						,executor_organization_id = @executor_organization_id
						,[LogUpdated_Query] = N'Button_NeVKompetentcii_Row121'
						 where id = @Id

				update dbo.AssignmentConsiderations 
					set	
						 consideration_date = GETUTCDATE()
						,assignment_result_id = @new_res
						,assignment_resolution_id = @new_resol
						,transfer_to_organization_id = @executor_organization_id
						,edit_date = GETUTCDATE()
						,user_edit_id = @user_edit_id
					 where Id = @current_consid 


				delete from @output_con;

				insert into dbo.AssignmentConsiderations
					(		[assignment_id]
						   ,[consideration_date]
						   ,[assignment_result_id]
						   ,[assignment_resolution_id]
						   ,[user_id]
						   ,[edit_date]
						   ,[user_edit_id]
						   ,turn_organization_id
						   ,[first_executor_organization_id]
						   ,[create_date])
					output inserted.Id into @output_con([Id])
					 select @id
						   ,getutcdate()
						   ,@new_res
						   ,@new_resol
						   ,@user_edit_id
						   ,getutcdate()
						   ,@user_edit_id
						   ,null
						   ,@executor_organization_id
						   ,getutcdate()
						from AssignmentConsiderations where Id = @current_consid

		
				set @new_con = ( select top(1) Id from @output_con)
				update [Assignments] set current_assignment_consideration_id = @new_con where Id = @Id -- @ass_id


			end
	END

	-- 1551
	IF @result_id = 3 and @resolution_id = 1
	BEGIN
		if (select first_executor_organization_id from AssignmentConsiderations where Id = @current_consid) = @executor_organization_id
		begin
			set @new_res  = 6 -- 6 Повернуто виконавцю	ReturnedToTheArtist
			set @new_resol = 3 -- 3 Перенаправлено за належністю	RedirectedByAffiliation
			set @executor_organization_id = (select first_executor_organization_id from AssignmentConsiderations where Id = @current_consid)


			-- закрываем Ревижн, + новый AssignmentConsiderations на того же самого исполнителя.
						update AssignmentRevisions 
								set [assignment_resolution_id] = @new_resol
									,organization_id = @executor_organization_id
								-- 	,[control_comment] = @control_comment
								-- 	,[rework_counter] = @rework_counter_count
									,[edit_date] = getutcdate()
									,[user_edit_id] = @user_edit_id
									,control_result_id = @new_resol
								where assignment_consideration_іd = @current_consid

						update Assignments 
								set
								 AssignmentResultsId = @new_res -- Какие результат и резолучия должны быть????
								,AssignmentResolutionsId = @new_resol
								,edit_date = GETUTCDATE()
								,user_edit_id = @user_edit_id
								,[LogUpdated_Query] = N'Button_NeVKompetentcii_Row189'
								 where id = @Id
		
						delete from @output_con
						insert into dbo.AssignmentConsiderations
							(		[assignment_id]
								   ,[consideration_date]
								   ,[assignment_result_id]
								   ,[assignment_resolution_id]
								   ,[user_id]
								   ,[edit_date]
								   ,[user_edit_id]
								   ,[first_executor_organization_id]
								   ,create_date
								   ,transfer_date
							)
							output inserted.Id into @output_con([Id])
							values( @Id
									,GETUTCDATE()
									,@new_res
									,@new_resol
									,@user_edit_id
									,GETUTCDATE()
									,@user_edit_id
									,@executor_organization_id
									,GETUTCDATE()
									,GETUTCDATE()
								   )

						set @new_con = (select top (1) Id from @output_con)
						update [Assignments] set current_assignment_consideration_id = @new_con where Id = @Id

		end
		else
		begin
			set @new_res  = 3 -- 3 Не в компетенції	NotInTheCompetence
			set @new_resol = 3 -- 3 Перенаправлено за належністю	RedirectedByAffiliation


			--закрываем старое  Assignments и AssignmentConsiderations и AssignmentRevisions
	 					update Assignments 
								set 
								 /*main_executor = 0
								,*/close_date = getutcdate()
								,AssignmentResultsId = @new_res
								,AssignmentResolutionsId = @new_resol
								,edit_date = GETUTCDATE()
								,user_edit_id = @user_edit_id
								,assignment_state_id = 5
								,[LogUpdated_Query] = N'Button_NeVKompetentcii_Row237'
								 where id = @Id

						update dbo.AssignmentConsiderations 
							set	consideration_date = GETUTCDATE()
								,assignment_result_id = @new_res
								,assignment_resolution_id = @new_resol
								,transfer_to_organization_id = @executor_organization_id
								,edit_date = GETUTCDATE()
								,user_edit_id = @user_edit_id
							 where Id=@current_consid -- assignment_id = @Id

						update AssignmentRevisions 
								set [assignment_resolution_id] = @new_resol
									,organization_id = @executor_organization_id
								-- 	,[control_comment] = @control_comment
								-- 	,[rework_counter] = @rework_counter_count
									,[edit_date] = getutcdate()
									,[user_edit_id] = @user_edit_id
									,control_result_id = @new_resol
								where assignment_consideration_іd = @current_consid

						delete from @output;
						delete from @output_con;



						if 	(select count(1) from Assignments with (nolock) where question_id = (select question_id from Assignments with (nolock) where Id = @Id)
								 and executor_organization_id = @executor_organization_id) = 0
						begin -- кк

							declare @oldAss_questionId int = (select ass.question_id from Assignments as ass where ass.id = @Id)

								declare @tested_transfer int
								declare @ass_id_for_main int
								exec [dbo].Check_transfer_organizations @Id, @executor_organization_id, @tested_transfer output, @ass_id_for_main output

								if @tested_transfer = 0
									begin
											-- создаем новое Assignments и AssignmentConsiderations
											INSERT INTO [dbo].[Assignments]
												 ([question_id]
												 ,[assignment_type_id]
												 ,[registration_date]
												 ,[assignment_state_id]
												 ,[state_change_date]
												 ,[organization_id]
												 ,[executor_organization_id]
												 ,[main_executor]
												 ,[execution_date]
												 ,[user_id]
												 ,[edit_date]
												 ,[user_edit_id]
												 ,AssignmentResultsId
												 ,AssignmentResolutionsId
												 ,LogUpdated_Query)
												output inserted.Id into @output([Id])
												select ass.question_id
												  ,ass.assignment_type_id
												  ,GETUTCDATE()
												  ,1	--Зареєстровано
												  ,GETUTCDATE()
												  --,(select first_executor_organization_id from AssignmentConsiderations where Id=@current_consid)
												  ,@executor_organization_id
												  ,@executor_organization_id
												--   ,1 --main
												  ,main_executor
												  ,ass.execution_date
												  ,@user_edit_id
												  ,GETUTCDATE()
												  ,@user_edit_id
												  ,1	--Очікує прийому в роботу
												  ,null
												  ,N'Button_NeVKompetentcii__Row335'
												from Assignments as ass where ass.id = @Id

											set @ass_id = (select top 1 [Id] from @output);

											insert into dbo.AssignmentConsiderations
											(		[assignment_id]
												   ,[consideration_date]
												   ,[assignment_result_id]
												   ,[assignment_resolution_id]
												   ,[user_id]
												   ,[edit_date]
												   ,[user_edit_id]
												   ,turn_organization_id
												   ,[first_executor_organization_id]
												--    ,[short_answer]
												   ,create_date)
											output inserted.Id into @output_con([Id])
											 select @ass_id
												   ,getutcdate()
												   ,1	--Очікує прийому в роботу
												   ,null
												   ,@user_edit_id
												   ,getutcdate()
												   ,@user_edit_id
												   ,null
												--   ,first_executor_organization_id
												   ,@executor_organization_id
												--    ,@short_answer
												   ,getutcdate()
												from AssignmentConsiderations where Id = (select current_assignment_consideration_id from Assignments where Id = @Id)
		
											--  проверка если это главное доручення то меняем в Вопросе last_assignment_for_execution_id
											if (select main_executor from Assignments where Id = @Id) = 1
											begin
												update Questions set 
													last_assignment_for_execution_id = @ass_id,
													edit_date = GETUTCDATE(),
													user_edit_id = @user_edit_id
											where last_assignment_for_execution_id = @Id
											end

											set @new_con = ( select top(1) Id from @output_con)
											update [Assignments] set main_executor = 0,
																	[LogUpdated_Query] = N'Button_NeVKompetentcii__Row379' 
											where Id = @Id
											update [Assignments] set current_assignment_consideration_id = @new_con,
																	[LogUpdated_Query]= N'Button_NeVKompetentcii__Row382' 
											where Id = @ass_id
										end
										else -- if @tested_transfer = 1
										begin
											UPDATE [Assignments] SET 
												main_executor = 1,
												[LogUpdated_Query] = N'Button_NeVKompetentcii__Row389',
												edit_date = getutcdate(),
												user_edit_id = @user_edit_id 
											WHERE Id = @ass_id_for_main

											UPDATE Questions 
												set last_assignment_for_execution_id = @ass_id_for_main,
													edit_date = GETUTCDATE(),
													user_edit_id = @user_edit_id
												where Id = @question_id

											UPDATE Assignments 	SET 
													 main_executor = 0
													,edit_date = GETUTCDATE()
													,user_edit_id = @user_edit_id
													,[LogUpdated_Query] = N'Button_NeVKompetentcii__Row404'
													WHERE id = @Id

										end
						end  -- кк
						else
						begin	
				-- 		update [Assignments] set main_executor = 0,[LogUpdated_Query] = N'Button_NeVKompetentcii__Row356' where Id = @Id
				            select @is_main_exec  = main_executor from Assignments where Id = @Id
						
						declare @New_Ass int = (select top 1 Id from Assignments with (nolock) where question_id = (select question_id from Assignments with (nolock) where Id = @Id) and executor_organization_id = @executor_organization_id)
								
								if 	(select count(1) from Assignments where question_id = (select question_id from Assignments where Id = @Id)
									and executor_organization_id = @executor_organization_id and AssignmentResultsId = 3 and AssignmentResolutionsId = 3) > 0
								begin
										update	[Assignments] 
										  --set   main_executor = 1,
										  set   main_executor = @is_main_exec,
												[AssignmentResultsId] = 1,
												[assignment_state_id] = 1,
												[AssignmentResolutionsId] = null,
												[LogUpdated_Query] = N'Button_NeVKompetentcii__Row365',
												close_date = null,
												edit_date = getutcdate(),
												user_edit_id = @user_edit_id
										where Id = @New_Ass


								insert into dbo.AssignmentConsiderations
										(		[assignment_id]
											   ,[consideration_date]
											   ,[assignment_result_id]
											   ,[assignment_resolution_id]
											   ,[user_id]
											   ,[edit_date]
											   ,[user_edit_id]
											   ,turn_organization_id
											   ,[first_executor_organization_id]
											   ,[short_answer]
						                       ,[create_date])
										output inserted.Id into @output_con([Id])
										 select @New_Ass
											   ,getutcdate()
											   ,1	--Очікує прийому в роботу
											   ,null
											   ,@user_edit_id
											   ,getutcdate()
											   ,@user_edit_id
											   ,null
											--   ,first_executor_organization_id
											   ,@executor_organization_id
											   ,[short_answer]
											   ,getutcdate()
											from AssignmentConsiderations where Id = @current_consid
											
											update [Assignments] set main_executor = 0,[LogUpdated_Query] = N'Button_NeVKompetentcii_Row441' where Id = @Id

											set @new_con = ( select top(1) Id from @output_con)
											update [Assignments] set current_assignment_consideration_id = @new_con where Id = @New_Ass
								end
								else
								begin
										select  @Id as Id
								-- 		update [Assignments] set main_executor = 1,[LogUpdated_Query] = N'Button_NeVKompetentcii__Row397' where Id = @New_Ass
								
								        update [Assignments] set 
												main_executor = 1,
												[LogUpdated_Query] = N'Button_NeVKompetentcii__Row453',
												edit_date = getutcdate(),
												user_edit_id = @user_edit_id 
											where Id = @New_Ass
										update [Assignments] set 
												main_executor = 0, 
												[LogUpdated_Query] = N'Button_NeVKompetentcii__Row459',
												edit_date = getutcdate(),
												user_edit_id = @user_edit_id 
											where question_id = @question_id and Id <> @New_Ass
								
								end	
						end			
		end	
	END	
end
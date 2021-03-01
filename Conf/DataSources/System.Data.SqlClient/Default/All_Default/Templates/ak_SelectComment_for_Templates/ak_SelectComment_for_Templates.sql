-- declare @Id int = 12
-- declare @assignment_id int = 3989122



declare @result_ApplicantPIB nvarchar(max)
declare @result_ApplicantAddress nvarchar(max)
declare @result_DirectorKBU nvarchar(max)
declare @result_QuestionRegistrationNumber nvarchar(20)
declare @result_QuestionRegistrationDate nvarchar(10)
declare @result_QuestionTypeName nvarchar(500)
declare @result_QuestionObjectName nvarchar(max)
declare @result_OrganizationName nvarchar(max)
declare @result_OrganizationDirector nvarchar(max)
declare @result_EventId nvarchar(500)
declare @result_EventClassName nvarchar(250)
declare @result_EventOrganizationName nvarchar(max)
declare @result_EventStartDate nvarchar(10)
declare @result_EventPlanEndDate nvarchar(10)

select @result_ApplicantPIB = [Applicants].full_name ,
       @result_ApplicantAddress = case when isnull(CHARINDEX(N', телефони', [Appeals].ApplicantAddress),0) > 0 then left([Appeals].ApplicantAddress, CHARINDEX(N', телефони', [Appeals].ApplicantAddress)-1) else N'' end,
	   @result_DirectorKBU = (select top 1 isnull([position],N'') + N', ' + isnull([name],N'') from [dbo].[Positions] where [organizations_id] = 1761 and [is_main] = 1),
	   @result_QuestionRegistrationNumber = [Questions].registration_number,
	   @result_QuestionRegistrationDate = format([Questions].[registration_date], 'dd-MM-yyyy'),
	   @result_QuestionTypeName = [QuestionTypes].[name],
	   @result_QuestionObjectName = [Objects].[name],
	   @result_OrganizationName = [Organizations].[name],
	   @result_OrganizationDirector = isnull([Positions].[position],N'') + N', ' + isnull([Positions].[name],N''),
	   @result_EventId = rtrim([Events].Id),
	   @result_EventClassName = [Event_Class].[name],
	   @result_EventOrganizationName = [EventOrganizations].[name],
	   @result_EventStartDate = format([Events].[start_date], 'dd-MM-yyyy'),
	   @result_EventPlanEndDate = format([Events].[plan_end_date], 'dd-MM-yyyy')
from [dbo].[Assignments]
inner join [dbo].[Questions] on [Questions].Id = [Assignments].[question_id]
inner join [dbo].[Appeals] on [Appeals].Id = [Questions].[appeal_id]
left join [dbo].[Applicants] on [Applicants].Id = [Appeals].[applicant_id]
left join [dbo].[Organizations] on [Organizations].Id = [Assignments].[executor_organization_id]
left join [dbo].[QuestionTypes] on [QuestionTypes].Id = [Questions].[question_type_id]
left join [dbo].[Positions] on [Positions].organizations_id = [Assignments].[executor_organization_id] and [Positions].is_main = 1
left join [dbo].[Objects] on [Objects].Id = [Questions].[object_id]
left join [dbo].[Events] on [Events].Id = [Questions].[event_id]
left join [dbo].[Event_Class] on [Event_Class].Id = [Events].[event_class_id]
left join [dbo].[EventOrganizers] on [EventOrganizers].event_id = [Events].[Id]
left join [dbo].[Organizations] as [EventOrganizations] on [EventOrganizations].Id = [EventOrganizers].[organization_id]
where [Assignments].Id = @assignment_id

 

select
replace(
	replace(
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(
										replace(
											replace(
												replace(
													replace([content] 
													,N'<ПІБ заявника>', isnull(@result_ApplicantPIB,N''))
												,N'<Адреса заявника>', isnull(@result_ApplicantAddress,N''))
											,N'<Директор КБУ>', isnull(@result_DirectorKBU,N''))
										,N'<Номер питання>', isnull(@result_QuestionRegistrationNumber,N''))
									,N'<Дата реєстрації>', isnull(@result_QuestionRegistrationDate,N''))
								,N'<Тип питання>', isnull(@result_QuestionTypeName,N''))
							,N'<Місце проблема>', isnull(@result_QuestionObjectName,N''))
						,N'<Організація-виконавець>', isnull(@result_OrganizationName,N''))
					,N'<Директор організації>', isnull(@result_OrganizationDirector,N''))
				,N'<Номер Заходу>', isnull(@result_EventId,N''))
			,N'<Клас Заходу>', isnull(@result_EventClassName,N''))
		,N'<Відповідальний за Захід>', isnull(@result_EventOrganizationName,N''))
	,N'<Дата початку Заходу>', isnull(@result_EventStartDate,N''))
,N'<Планова дата завершення>', isnull(@result_EventPlanEndDate,N'')) as [content]
from [Templates]
where Id=@Id
  -- declare @filter nvarchar(3000)=N'1=1';
  -- declare @ApplicantsId int = 1494216;
 --  declare @sort nvarchar(3000)=N'full_name desc';
  
 declare @sort1 nvarchar(3000)=case when @sort=N'1=1' then N'QuestionType' else @sort end;

 declare @qcode nvarchar(max)=N'

 select Id, registration_number, QuestionType, full_name, phone_number, DistrictName District,
 house, place_problem, vykon, zmist, comment, [history], ApplicantsId, BuildingId, [Organizations_Id],
 cc_nedozvon, entrance, [edit_date], [control_comment], [AssignmentStates], result_id, result, [registration_date]
 ,All_NDZV
 from
 (
 select [Assignments].Id, [Questions].registration_number, ltrim([QuestionTypes].name) QuestionType,
 (select (select  convert(xml, ''  <p> '' + cast(Missed_call_counter as varchar(10)) + N'' (дата та час недозвону: '' + format(CONVERT(datetime, SWITCHOFFSET(Edit_date, DATEPART(TZOFFSET,Edit_date AT TIME ZONE ''E. Europe Standard Time''))), ''dd.MM.yyyy HH:mm'') + N''), коментар: '' + isnull(MissedCallComment, '''') + '' </p> '')
from AssignmentDetailHistory 
where  --Missed_call_counter = 1 and 
AssignmentDetailHistory.Assignment_id = Assignments.Id
For XML PATH('''')
) )as All_NDZV,
  [Applicants].full_name, [ApplicantPhones].phone_number, [Districts].Id District,
  [Districts].Name DistrictName,
  isnull([StreetTypes].shortname+N'' '',N'''')+
  isnull([Streets].name+N'', '',N'''')+
  isnull([Buildings].name, N'''')+
  isnull(N'' кв. ''+[LiveAddress].flat,N'''') house,

  isnull([StreetTypes2].shortname+N'' '',N'''')+
  isnull([Streets2].name+N'', '',N'''')+
  isnull([Buildings2].name, N'''') place_problem
  ,[Organizations].short_name vykon
  ,[Questions].question_content zmist
  ,[AssignmentConsiderations].short_answer comment
  , null [history]
  --,[Assignments].executor_organization_id
  ,[Applicants].Id ApplicantsId, [Buildings].Id BuildingId
  ,[Organizations].Id [Organizations_Id]
  ,isnull([AssignmentRevisions].[missed_call_counter], 0) cc_nedozvon
  ,case when [Assignments].assignment_state_id=3
  then [Assignments].state_change_date end [state_changed_date] -- good
  ,case when [Assignments].assignment_state_id=3 and [AssignmentConsiderations].assignment_result_id=4
  then [Assignments].state_change_date end [state_changed_date_done]
  --,[Questions].entrance
  ,[LiveAddress].entrance
  ,[Questions].flat
  ,[Objects].Id [object]
  ,[Organizations].Id organization
  ,[QuestionTypes].Id question_type
  ,[Rating].Id [question_list_state]
  ,[Questions].registration_date
  ,[AssignmentRevisions].[edit_date]
  ,[AssignmentRevisions].[control_comment]
  ,[AssignmentStates].[name] [AssignmentStates]
  ,[Assignments].AssignmentResultsId result_id
  ,[AssignmentResults].[name] result
  from [Assignments]
  left join [AssignmentStates] on [Assignments].assignment_state_id=[AssignmentStates].Id
  left join [AssignmentResults] on [Assignments].AssignmentResultsId=[AssignmentResults].Id
  left join [AssignmentConsiderations] on [Assignments].current_assignment_consideration_id=[AssignmentConsiderations].Id
  left join [Questions] on [Assignments].question_id=[Questions].Id
  left join [QuestionTypes] on [Questions].question_type_id=[QuestionTypes].Id
  left join [Appeals] on [Questions].appeal_id=[Appeals].Id
  left join [Applicants] on [Appeals].applicant_id=[Applicants].Id
  left join (
			  SELECT Apl.Id, APhone_IsMain.phone_number, APhone_IsMain.Id as PhoneId
			  FROM [dbo].[Applicants] as Apl with (nolock)
			  cross apply 
			  (
				select top 1 APhone.phone_number, APhone.Id
				from [dbo].[ApplicantPhones] APhone with (nolock)
				where APhone.IsMain = 1 and APhone.applicant_id = Apl.Id
			  ) APhone_IsMain 
			where Apl.Id in (
								SELECT [Applicants].Id
								  FROM [dbo].[Applicants]  with (nolock)
								  inner join [dbo].[ApplicantPhones]  with (nolock) on [ApplicantPhones].applicant_id = [Applicants].Id
								  group by [Applicants].Id
							)
	) as PhoneIsMain on PhoneIsMain.Id = [Applicants].Id
	left join (
					SELECT Apl.Id, APhone_IsNOTMain.phone_number, APhone_IsNOTMain.Id as PhoneId
					FROM [dbo].[Applicants] as Apl with (nolock)
					cross apply 
					(
					select top 1 APhone.phone_number, APhone.Id
					from [dbo].[ApplicantPhones] APhone with (nolock)
					where APhone.IsMain = 0 and APhone.applicant_id = Apl.Id
					) APhone_IsNOTMain 
				where Apl.Id in (
									SELECT [Applicants].Id
										FROM [dbo].[Applicants]  with (nolock)
										inner join [dbo].[ApplicantPhones] with (nolock) on [ApplicantPhones].applicant_id = [Applicants].Id
										group by [Applicants].Id
								)
	) as PhoneIsNotMain on PhoneIsNotMain.Id = [Applicants].Id
  left join [ApplicantPhones] with (nolock) on [ApplicantPhones].applicant_id=[Applicants].Id and [ApplicantPhones].Id = isnull(PhoneIsMain.PhoneId, PhoneIsNotMain.PhoneId)
  left join (
				  SELECT Apl.Id, LiveAdr_IsMain.building_id, LiveAdr_IsMain.Id as LiveAdrId
				  FROM [dbo].[Applicants] as Apl
				  cross apply 
				  (
					select top 1 LiveAdr.building_id, LiveAdr.Id
					from [dbo].[LiveAddress] LiveAdr
					where LiveAdr.main = 1 and LiveAdr.applicant_id = Apl.Id
				  ) LiveAdr_IsMain 
				where Apl.Id in (
									SELECT [Applicants].Id
									  FROM [dbo].[Applicants] 
									  inner join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
									  group by [Applicants].Id
								)
	) as LiveAdrIsMain on LiveAdrIsMain.Id = [Applicants].Id
	left join (
				 SELECT Apl.Id, LiveAdr_IsNOTMain.building_id, LiveAdr_IsNOTMain.Id as LiveAdrId
				  FROM [dbo].[Applicants] as Apl
				  cross apply 
				  (
					select top 1 LiveAdr.building_id, LiveAdr.Id
					from [dbo].[LiveAddress] LiveAdr
					where LiveAdr.main = 0 and LiveAdr.applicant_id = Apl.Id
				  ) LiveAdr_IsNOTMain 
				where Apl.Id in (
									SELECT [Applicants].Id
									  FROM [dbo].[Applicants] 
									  inner join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
									  group by [Applicants].Id
								)
	) as LiveAdrIsNotMain on LiveAdrIsNotMain.Id = [Applicants].Id
  left join [LiveAddress] with (nolock) on [LiveAddress].applicant_id=[Applicants].Id and [LiveAddress].Id = isnull(LiveAdrIsMain.LiveAdrId, LiveAdrIsNotMain.LiveAdrId)
  left join [Buildings] on [LiveAddress].building_id=[Buildings].Id
  left join [Districts] on [Buildings].district_id=[Districts].Id
  left join [Streets] on [Buildings].street_id=[Streets].Id
  left join [StreetTypes] on [Streets].street_type_id=[StreetTypes].Id
  left join [Objects] on [Questions].object_id=[Objects].Id
  left join [Buildings] [Buildings2] on [Objects].[builbing_id]=[Buildings2].Id
  left join [Districts] [Districts2] on [Buildings2].district_id=[Districts2].Id
  left join [Streets] [Streets2] on [Buildings2].street_id=[Streets2].Id
  left join [StreetTypes] [StreetTypes2] on [Streets2].street_type_id=[StreetTypes2].Id
  left join [Organizations] on [Assignments].executor_organization_id=[Organizations].Id
  left join [ReceiptSources] on [Appeals].receipt_source_id=[ReceiptSources].Id
  left join [QuestionTypeInRating] on [QuestionTypes].question_type_id=[QuestionTypes].Id
  left join [Rating] on [QuestionTypeInRating].Rating_id=[Rating].Id
  left join [AssignmentRevisions] on [AssignmentConsiderations].Id=[AssignmentRevisions].assignment_consideration_іd


  where [AssignmentStates].code in (N''Registered'', N''InWork'', N''OnCheck'', N''NotFulfilled'') and
  [Assignments].[main_executor]=''true'' 
     --([ReceiptSources].code<>N''UGL'' and [AssignmentStates].code<>N''OnCheck'' and [AssignmentResults].code<>N''Done'')
   and  not ([ReceiptSources].code=N''Website_mob.addition'' and [AssignmentStates].code=N''OnCheck'' and [AssignmentResults].code=N''Done'')
	 and not ([ReceiptSources].code=N''UGL'')
  ) t

  where ApplicantsId='+ltrim(@ApplicantsId)+N' and '+@filter+N'
  order by '+@sort1
--  and  not (([ReceiptSources].code=N''UGL'' or [ReceiptSources].code=N''Website_mob.addition'') and [AssignmentStates].code=N''OnCheck'' and [AssignmentResults].code=N''Done'')

  exec(@qcode)

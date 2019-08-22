 --declare @filter nvarchar(3000)=N'1=1'; --question_type in (50)
 --declare @sort nvarchar(3000)=N'1=1';

 declare @sort1 nvarchar(3000)=case when @sort=N'1=1' then N'QuestionType' else @sort end;

 --select CHARINDEX(N'question_type in (', @filter, 0), -- с какого по номеру символа начинается
 --len(N'question_type in ('), --длинна того что начинается
 --CHARINDEX(N')', @filter, CHARINDEX(N'question_type in (', @filter, 0)),--найти на чем заканчиваетя
 --CHARINDEX(N'(', @filter, CHARINDEX(N'question_type in (', @filter, 0)),-- найти с чего начинается
 --SUBSTRING(@filter, CHARINDEX(N'(', @filter, CHARINDEX(N'question_type in (', @filter, 0))+1, CHARINDEX(N')', @filter, CHARINDEX(N'question_type in (', @filter, 0))-CHARINDEX(N'(', @filter, CHARINDEX(N'question_type in (', @filter, 0))-1)  --то что в середине

 declare @question_type_id_list nvarchar(max);
	if CHARINDEX(N'question_type in (', @filter, 0)>=1
	begin
		 set @question_type_id_list =
		 (select  SUBSTRING(@filter, CHARINDEX(N'(', @filter, CHARINDEX(N'question_type in (', @filter, 0))+1, CHARINDEX(N')', @filter, CHARINDEX(N'question_type in (', @filter, 0))-CHARINDEX(N'(', @filter, CHARINDEX(N'question_type in (', @filter, 0))-1)  --то что в середине
		)
    end
--select @question_type_id_list


declare @input_str_qt nvarchar(100) =@question_type_id_list+N',' --N'13,12,34,56,'
 
-- создаем таблицу в которую будем
-- записывать наши айдишники
declare @table_qt table (id int)
 
-- создаем переменную, хранящую разделитель
declare @delimeter_qt nvarchar(1) = ','
 
-- определяем позицию первого разделителя
declare @pos_qt int = charindex(@delimeter_qt,@input_str_qt)
 
-- создаем переменную для хранения
-- одного айдишника
declare @id_qt nvarchar(10)
    
while (@pos_qt != 0)
begin
    -- получаем айдишник
    set @id_qt = SUBSTRING(@input_str_qt, 1, @pos_qt-1)
    -- записываем в таблицу
    insert into @table_qt (id) values(cast(@id_qt as int))
    -- сокращаем исходную строку на
    -- размер полученного айдишника
    -- и разделителя
    set @input_str_qt = SUBSTRING(@input_str_qt, @pos_qt+1, LEN(@input_str_qt))
    -- определяем позицию след. разделителя
    set @pos_qt = CHARINDEX(@delimeter_qt,@input_str_qt)
end

declare @questions_children nvarchar(max)=(

select STUFF((
select N', '+[QuestionTypesAndParent].QuestionTypes
from @table_qt tqt
inner join [QuestionTypesAndParent] with (nolock) on tqt.id=[QuestionTypesAndParent].ParentId
for xml path('')),1,2,N'')
)

--select @questions_children questions_children


 declare @filter1 nvarchar(max)=
 case when CHARINDEX(N'question_type in (', @filter, 0)>0
 then
 REPLACE(@filter, N'question_type in ('+@question_type_id_list+N')', 
 N'question_type in ('+@questions_children+N')')
else @filter
end

--select @filter1

 -----------------------------
 declare @qcode nvarchar(max)=N'

 select ROW_NUMBER() OVER (Order by (select 1)) as rn,
 Id, registration_number, QuestionType, full_name, phone_number, DistrictName District,
 house, place_problem, vykon, zmist, comment, [history], ApplicantsId, BuildingId, [Organizations_Id],
 cc_nedozvon, entrance, [edit_date], [control_comment]
 
 from
 (
 select [Assignments].Id, [Questions].registration_number, ltrim([QuestionTypes].name) QuestionType,
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
  ,[Assignments].registration_date
  ,[AssignmentRevisions].[edit_date]
  ,[AssignmentRevisions].[control_comment]

,[Streets].Id building_street
  ,[Buildings].[Id] building_number
 , [Appeals].receipt_source_id receipt_source
  from [Assignments]  with (nolock)
  left join [AssignmentStates] with (nolock) on [Assignments].assignment_state_id=[AssignmentStates].Id
  left join [AssignmentResults] with (nolock) on [Assignments].AssignmentResultsId=[AssignmentResults].Id
  left join [AssignmentConsiderations] with (nolock) on [Assignments].current_assignment_consideration_id=[AssignmentConsiderations].Id
  left join [Questions] with (nolock) on [Assignments].question_id=[Questions].Id
  left join [QuestionTypes] with (nolock) on [Questions].question_type_id=[QuestionTypes].Id
  left join [Appeals] with (nolock) on [Questions].appeal_id=[Appeals].Id
  left join [Applicants] with (nolock) on [Appeals].applicant_id=[Applicants].Id
  left join (select [applicant_id], [phone_number]
  from [ApplicantPhones] with (nolock)
  where IsMain=1) ApplicantPhones on [ApplicantPhones].applicant_id=[Applicants].Id

  left join [LiveAddress] with (nolock) on [LiveAddress].applicant_id=[Applicants].Id
  left join [Buildings] with (nolock) on [LiveAddress].building_id=[Buildings].Id
  left join [Districts] with (nolock) on [Buildings].district_id=[Districts].Id
  left join [Streets] with (nolock) on [Buildings].street_id=[Streets].Id
  left join [StreetTypes] with (nolock) on [Streets].street_type_id=[StreetTypes].Id
  left join [Objects] with (nolock) on [Questions].object_id=[Objects].Id
  left join [Buildings] [Buildings2] with (nolock) on [Objects].[builbing_id]=[Buildings2].Id
  left join [Districts] [Districts2] with (nolock) on [Buildings2].district_id=[Districts2].Id
  left join [Streets] [Streets2] with (nolock) on [Buildings2].street_id=[Streets2].Id
  left join [StreetTypes] [StreetTypes2] with (nolock) on [Streets2].street_type_id=[StreetTypes2].Id
  left join [Organizations] with (nolock) on [Assignments].executor_organization_id=[Organizations].Id
  left join [ReceiptSources] with (nolock) on [Appeals].receipt_source_id=[ReceiptSources].Id
  left join [QuestionTypeInRating] with (nolock) on [QuestionTypes].question_type_id=[QuestionTypes].Id
  left join [Rating] with (nolock) on [QuestionTypeInRating].Rating_id=[Rating].Id
  left join [AssignmentRevisions] with (nolock) on [AssignmentConsiderations].Id=[AssignmentRevisions].assignment_consideration_іd 
  where [AssignmentStates].code=N''OnCheck'' and [AssignmentResults].code=N''Done'' and
     [Assignments].[main_executor]=''true''
     and  not (([ReceiptSources].code=N''UGL'' or [ReceiptSources].code=N''Website_mob.addition'') and [AssignmentStates].code=N''OnCheck'' and [AssignmentResults].code=N''Done'')
       --and ([ReceiptSources].code<>N''UGL'' and [AssignmentStates].code<>N''OnCheck'' and [AssignmentResults].code<>N''Done'')
--тут
-- 	   and 
-- 	   left([Questions].registration_number, CHARINDEX(N''/'', [Questions].registration_number, 1)-1) in 
--   (
--  select distinct left([Questions].registration_number, CHARINDEX(N''/'', [Questions].registration_number, 1)-1)
--  from [Questions]
--  where RIGHT([Questions].registration_number,1)*1>1 and CHARINDEX(N''/'', [Questions].registration_number, 1)>0)

	   --тут
  
  ) t

  where '+@filter1+N'
  order by '+@sort1--+@sort1 тут registration_number

  exec(@qcode)

  --select @filter1
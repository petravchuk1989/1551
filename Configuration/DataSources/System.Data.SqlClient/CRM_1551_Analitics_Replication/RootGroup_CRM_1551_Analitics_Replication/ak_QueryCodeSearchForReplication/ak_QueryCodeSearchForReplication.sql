/*

 declare @user_id nvarchar(300)=N'd0da1bfc-438a-45ec-bc75-f1c8d05f0d9a';
 --d0da1bfc-438a-45ec-bc75-f1c8d05f0d9a
 --aa4c1f84-df33-452c-88e7-5a58dfd0b2d3

  declare @param1 nvarchar(max)=N'question_question_type in (2, 3) and assigm_executor_organization in (1)'--N'zayavnyk_full_name like ''%Волосянко Надя Богданівна%'''
 declare @pageOffsetRows int =0;
 declare @pageLimitRows int =10;

  declare @registration_date_from datetime;--='2019-07-05 04:44:34';
 declare @registration_date_to datetime;--='2019-07-05 16:45:43';

   declare @transfer_date_from datetime;--='2019-07-05 11:26:37';
 declare @transfer_date_to datetime;--='2019-07-05 11:26:37';

  declare @state_changed_date_from datetime;--='2019-07-05 11:26:37';
 declare @state_changed_date_to datetime;--='2019-07-05 11:26:37';

 declare @state_changed_date_done_from datetime;--='2019-07-05 11:26:37';
 declare @state_changed_date_done_to datetime;--='2019-07-05 11:26:37';

  declare @execution_term_from datetime;--='2019-07-21 21:00:00.000';
 declare @execution_term_to datetime;--='2019-07-21 21:00:00.000';

 */


 declare @registration_date_fromP nvarchar(200)=
 case when @registration_date_from is not null 
 then N' and registration_date>= '''+format(convert(datetime2, @registration_date_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
 else N'' end;

 declare @registration_date_toP nvarchar(200)=
 case when @registration_date_to is not null 
 then N' and registration_date<= '''+format(convert(datetime2, @registration_date_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
 else N'' end;



  declare @transfer_date_fromP nvarchar(200)=
 case when @transfer_date_from is not null 
 then N' and transfer_date>= '''+format(convert(datetime2, @transfer_date_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
 else N'' end;

 declare @transfer_date_toP nvarchar(200)=
 case when @transfer_date_to is not null 
 then N' and transfer_date<= '''+format(convert(datetime2, @transfer_date_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
 else N'' end;


 declare @state_changed_date_fromP nvarchar(200)=
 case when @state_changed_date_from is not null 
 then N' and state_changed_date>= '''+format(convert(datetime2, @state_changed_date_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
 else N'' end;

 declare @state_changed_date_toP nvarchar(200)=
 case when @state_changed_date_to is not null 
 then N' and state_changed_date<= '''+format(convert(datetime2, @state_changed_date_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
 else N'' end;



  declare @state_changed_date_done_fromP nvarchar(200)=
 case when @state_changed_date_done_from is not null 
 then N' and state_changed_date_done>= '''+format(convert(datetime2, @state_changed_date_done_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
 else N'' end;

 declare @state_changed_date_done_toP nvarchar(200)=
 case when @state_changed_date_done_to is not null 
 then N' and state_changed_date_done<= '''+format(convert(datetime2, @state_changed_date_done_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
 else N'' end;


  declare @execution_term_fromP nvarchar(200)=
 case when @execution_term_from is not null 
 then N' and convert(date, execution_term)>= '''+format(convert(date, dateadd(hh, 5, @execution_term_from)), 'yyyy-MM-dd')+N''''
 else N'' end;

 declare @execution_term_toP nvarchar(200)=
 case when @execution_term_to is not null 
 then N' and convert(date, execution_term)<= '''+format(convert(date, dateadd(hh, 5, @execution_term_to)), 'yyyy-MM-dd')+N''''
 else N'' end;

 --- убрать

 --select @execution_term_fromP, @execution_term_toP 


 declare @param4 nvarchar(max)=@registration_date_fromP+@registration_date_toP+@transfer_date_fromP+@transfer_date_toP
 +@state_changed_date_fromP+@state_changed_date_toP
 +@state_changed_date_done_fromP+@state_changed_date_done_toP
 +@execution_term_fromP+@execution_term_toP;


  declare @organizations nvarchar(max);

declare @param3 nvarchar(max);
if CHARINDEX(N'question_question_type',@param1, 1)>0

begin

declare @q_types nvarchar(max)=
(right(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),
len(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)))-
CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)), 1)+1))


declare @input_str nvarchar(max)=REPLACE(REPLACE(@q_types, N')', N''),N'(',N'')+N','

declare @table table (n int identity(1,1), id int)
 
-- создаем переменную, хранящую разделитель
declare @delimeter nvarchar(1) = ','
 
-- определяем позицию первого разделителя
declare @pos int = charindex(@delimeter,@input_str)
 
-- создаем переменную для хранения
-- одного айдишника
declare @id nvarchar(10)
    
while (@pos != 0)
begin
    -- получаем айдишник
    set @id = SUBSTRING(@input_str, 1, @pos-1)
    -- записываем в таблицу
    insert into @table (id) values(cast(@id as int))
    -- сокращаем исходную строку на
    -- размер полученного айдишника
    -- и разделителя
    set @input_str = SUBSTRING(@input_str, @pos+1, LEN(@input_str))
    -- определяем позицию след. разделителя
    set @pos = CHARINDEX(@delimeter,@input_str)
end

			 declare @question_typ nvarchar(max)=(
			 select stuff((select N', '+[QuestionTypesAndParent].QuestionTypes
  from [QuestionTypesAndParent] with (nolock)
  inner join @table t on [QuestionTypesAndParent].[ParentId]=t.id
  for xml path('')), 1,2,N''))

			 set @param3 =replace(@param1 
			 ,left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1))
			 ,N'question_question_type in ('+@question_typ+N')')

			end

			else
			begin
			set @param3=@param1;
			end;

-------------- next

 declare @assigm_executor_organizations nvarchar(max);
 -----найти подтипы вопросов начало
 /* найти под типы вопросов*/
--declare @param1 nvarchar(500)=N'id=123 and Id=54545';
declare @param_ex nvarchar(max);
if CHARINDEX(N'assigm_executor_organization',@param1, 1)>0

begin

declare @executors nvarchar(max)=
(right(left(SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), 1)),
len(left(SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), 1)))-
CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), 1)), 1)+1))



declare @input_str_ex nvarchar(max)=REPLACE(REPLACE(@executors, N')', N''),N'(',N'')+N','

declare @table_ex table (n int identity(1,1), id int)
 
-- создаем переменную, хранящую разделитель
declare @delimeter_ex nvarchar(1) = ','
 
-- определяем позицию первого разделителя
declare @pos_ex int = charindex(@delimeter_ex,@input_str_ex)
 
-- создаем переменную для хранения
-- одного айдишника
declare @id_ex nvarchar(10)
    
while (@pos_ex != 0)
begin
    -- получаем айдишник
    set @id_ex = SUBSTRING(@input_str_ex, 1, @pos_ex-1)
    -- записываем в таблицу
    insert into @table_ex (id) values(cast(@id_ex as int))
    -- сокращаем исходную строку на
    -- размер полученного айдишника
    -- и разделителя
    set @input_str_ex = SUBSTRING(@input_str_ex, @pos_ex+1, LEN(@input_str_ex))
    -- определяем позицию след. разделителя
    set @pos_ex = CHARINDEX(@delimeter_ex,@input_str_ex)
end

				 set @param_ex =replace(@param3 
				 ,left(SUBSTRING(@param3,CHARINDEX(N'assigm_executor_organization',@param3, 1) ,len(@param3)-CHARINDEX(N'assigm_executor_organization',@param3, 1)+1), CHARINDEX(N')', SUBSTRING(@param3,CHARINDEX(N'assigm_executor_organization',@param3, 1) ,len(@param3)-CHARINDEX(N'assigm_executor_organization',@param3, 1)+1), 1))
				 ,N'assigm_executor_organization in ('+(select stuff((
  select N', '+[OrganizationsAndParent].Organizations
  from [OrganizationsAndParent]
  inner join @table_ex t on [OrganizationsAndParent].ParentId=t.Id
  for xml path('')), 1, 2,N''))+N')')
				-- select N'question_question_type in ('+@question_typ+N')' --question_question_type in (2, 3, 7, 8)

				end

				else
				begin
				set @param_ex=@param3;
				end;

   
declare @OrgTable table (Id int identity(1,1), OrgId int);
declare @Organization table(Id int);
declare @IdT table (Id int);
declare @OrganizationId int;
declare @n int=1;


  -- @execution_term_from

  declare @param2 nvarchar(max)=
   --case when CHARINDEX('cast(execution_term as datetime) >=', @param3, 0)=0 and CHARINDEX('cast(execution_term as datetime) <=', @param3, 0)>0

      case when @execution_term_from is null and @execution_term_to is not null
  then @param_ex+N' and [assigm_assignment_state_name]<>N''Закрито''' --Зареєстровано Закрито
  else @param_ex end+@param4;

  /* здесь нужно поставить условие, что если у данного человека есть организация 1761 то 1=1
  иначе нужн запустить пересчет*/

  --заполение таблицы организацией и ее под
  declare @organization_id1761 int =1761;
  declare @Organization1761 table(Id int);
  declare @OrganizationId1761 int = @organization_id1761;
  declare @IdT1761 table (Id int);
 -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
 insert into @IdT1761(Id)
 select Id from [Organizations] with (nolock)
 where (Id=@OrganizationId1761 or [parent_organization_id]=@OrganizationId1761) and Id not in (select Id from @IdT1761)
 --  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
 while (select count(id) from (select Id from [Organizations] with (nolock)
 where [parent_organization_id] in (select Id from @IdT1761) --or Id in (select Id from @IdT)
 and Id not in (select Id from @IdT1761)) q)!=0
 begin
 insert into @IdT1761
 select Id from [Organizations] with (nolock)
 where [parent_organization_id] in (select Id from @IdT1761) --or Id in (select Id from @IdT)
 and Id not in (select Id from @IdT1761)
 end 
 insert into @Organization1761 (Id)
 select Id from @IdT1761;
 -- вторая часть, там, где данная организация является дочерней и залить в основную таблицу

 declare @organization_id1761L int =1761;
declare @Organization1761L table(Id int, Id_n int);
declare @OrganizationId1761L int =  @organization_id1761L;
declare @IdT1761L table (Id int, Id_n int identity(1,1));
insert into @IdT1761L(Id) select @OrganizationId1761L
while (select [parent_organization_id] from [Organizations] with (nolock) where Id=(select top 1 Id from @IdT1761L order by Id_n desc)) is not null
begin 
-- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
insert into @IdT1761L(Id)
select [parent_organization_id] from [Organizations] with (nolock)
where Id=(select top 1 Id from @IdT1761L order by Id_n desc) --and Id not in (select Id from @IdT)

end

insert into @Organization1761 (Id)
select Id from @IdT1761L where id<>1761

 -- начало оптимизации
			 if exists
			 (select [OrganizationInResponsibilityRights].organization_id
			  from [OrganizationInResponsibilityRights] with (nolock)
			  inner join [Positions] with (nolock) on [OrganizationInResponsibilityRights].position_id=[Positions].Id
			  inner join @Organization1761 o1761 on [OrganizationInResponsibilityRights].organization_id=o1761.Id
			  where [Positions].programuser_id=@user_id )

			  begin
			  set @organizations=N'1=1'
			  end

			  else
			  begin

						set @organizations=N'Organizations2_Id in ('+
					  (select stuff((select N', '+
[OrganizationsAndParent].Organizations
from [OrganizationInResponsibilityRights] with (nolock)
inner join [Positions] with (nolock) on [OrganizationInResponsibilityRights].position_id=[Positions].Id
inner join [OrganizationsAndParent] with (nolock) on [OrganizationInResponsibilityRights].organization_id=[OrganizationsAndParent].ParentId
where [Positions].programuser_id=@user_id
for xml path ('')),1,2,N''))+N')'

					  end
  -- конец оптимизации 
  --select @param2, @organizations
  --SELECT RTRIM(CAST(DATEDIFF(MS, @start_time, GETDATE()) AS CHAR(10))) AS 'TimeTaken'
  
declare @query nvarchar(max)=N'
select --top 5000
   [Id]
  ,[appeals_receipt_source_name] [appeals_receipt_source]
  ,[appeals_user_name] [appeals_user]
  ,[appeals_district_name] [appeals_district] 
  ,[appeals_files_check]
  ,[zayavnyk_full_name]
  ,[zayavnyk_phone_number]
  ,[zayavnyk_building_street_name] [zayavnyk_building_street]

  ,isnull([shortname],N'''')+N'' ''+[zayavnyk_building_street_name]+N'', ''+[zayavnyk_building_number_name] [zayavnyk_building_number]


  --,[zayavnyk_building_number_name] [zayavnyk_building_number]
  ,[zayavnyk_entrance]
  ,[zayavnyk_flat]
  ,[zayavnyk_applicant_privilage_name] [zayavnyk_applicant_privilage]
  ,[zayavnyk_social_state_name] [zayavnyk_social_state]
  ,[zayavnyk_sex_name] [zayavnyk_sex]
  ,[zayavnyk_applicant_type_name] [zayavnyk_applicant_type]
  ,[zayavnyk_age]
  ,[zayavnyk_email]
  ,[question_registration_number]
  ,[question_ObjectTypes_name] [question_ObjectTypes]
  ,[question_object_name] [question_object]
  ,[question_organization_name] [question_organization]
  ,[question_question_type_name] [question_question_type]
  ,[question_question_state_name] [question_question_state]
  ,[question_list_state_name] [question_list_state]
  ,[assigm_executor_organization_name] [assigm_executor_organization]
  ,[assigm_main_executor]
  ,[assigm_question_content]
  ,[assigm_accountable_name] [assigm_accountable] 
  ,[assigm_assignment_state_name] [assigm_assignment_state]  
  ,[assigm_assignment_result_name] [assigm_assignment_result] 
  ,[assigm_assignment_resolution_name] [assigm_assignment_resolution]
  ,[assigm_user_reviewed_name] [assigm_user_reviewed] 
  ,[assigm_user_checked_name] [assigm_user_checked]

  ,convert(datetime, [registration_date]) [registration_date]
  ,convert(datetime, [transfer_date]) [transfer_date]
  ,convert(datetime, [state_changed_date]) [state_changed_date]
  ,convert(datetime, [state_changed_date_done]) [state_changed_date_done]
  
  ,[execution_term] 
  ,[appeals_enter_number]
  ,[control_comment]
 from
 (
  select [Assignments].Id,
  [Appeals].receipt_source_id [appeals_receipt_source]
  ,[ReceiptSources].name [appeals_receipt_source_name]
  ,[Appeals].user_id [appeals_user]
  --,[Workers].Id [appeals_user_Id]
  ,[Workers].name [appeals_user_name]
  ,[Districts].Id [appeals_district] 
  ,[Districts].name [appeals_district_name] 
  ,case when files_check.assignment_сons_id is not null then ''true'' else ''false'' end appeals_files_check

  ,[Applicants].full_name zayavnyk_full_name
  ,stuff((select N'', ''+phone_number
					from [dbo].[ApplicantPhones] t1 with (nolock)
					where [t1].applicant_id=[Applicants].id
					order by t1.id
					for xml path('''')),1,2,N'''') zayavnyk_phone_number
  ,[Streets].Id [zayavnyk_building_street]
  ,[Streets].name [zayavnyk_building_street_name]
  ,[Buildings].Id [zayavnyk_building_number]
  ,[Buildings].name [zayavnyk_building_number_name]
  ,[LiveAddress].entrance [zayavnyk_entrance]
  ,[LiveAddress].flat [zayavnyk_flat]
  ,[ApplicantPrivilege].Id [zayavnyk_applicant_privilage]
  ,[ApplicantPrivilege].Name [zayavnyk_applicant_privilage_name]
  ,[SocialStates].Id [zayavnyk_social_state]
  ,[SocialStates].name [zayavnyk_social_state_name]
  ,[Applicants].sex [zayavnyk_sex]
  ,case when [Applicants].sex=1 then N''жіноча'' when [Applicants].sex=2 then N''чоловіча'' end [zayavnyk_sex_name]
  ,[ApplicantTypes].Id [zayavnyk_applicant_type]
  ,[ApplicantTypes].name [zayavnyk_applicant_type_name]
  ,case 
when [Applicants].[birth_date] is null then year(getdate())-[Applicants].birth_year
  when month([Applicants].[birth_date])<=month(getdate())
  and day([Applicants].[birth_date])<=day(getdate())
  then DATEDIFF(yy, [Applicants].[birth_date], getdate())
  else DATEDIFF(yy, [Applicants].[birth_date], getdate())-1 end zayavnyk_age,
  [Applicants].mail zayavnyk_email
  
  ,[Questions].registration_number [question_registration_number]
  ,[ObjectTypes].Id [question_ObjectTypes]
  ,[ObjectTypes].name [question_ObjectTypes_name]
  ,[Objects].Id [question_object]
  ,[Objects].name [question_object_name]
  ,[Organizations].Id [question_organization]
  ,[Organizations].short_name [question_organization_name]
  ,[QuestionTypes].Id [question_question_type]
  ,[QuestionTypes].name [question_question_type_name]
  ,[QuestionStates].Id [question_question_state]
  ,[QuestionStates].name [question_question_state_name]
  ,[Rating].Id [question_list_state]
  ,[Rating].name [question_list_state_name]

  ,[Assignments].executor_organization_id [assigm_executor_organization] -- good
  ,IIF (len([Organizations2].[head_name]) > 5,  concat([Organizations2].[head_name] , '' ( '' , [Organizations2].[short_name] , '')''),  [Organizations2].[short_name]) [assigm_executor_organization_name]
  ,[Assignments].main_executor [assigm_main_executor] -- good
  ,[Questions].question_content [assigm_question_content] -- good
   ,[Organizations10].[short_name] [assigm_accountable_name] -- good
   ,[Organizations10].Id [assigm_accountable]

  ,[AssignmentStates].Id [assigm_assignment_state] -- good
  ,[AssignmentStates].name [assigm_assignment_state_name] -- good
         
  ,[AssignmentResults].Id [assigm_assignment_result] -- good
  ,[AssignmentResults].name [assigm_assignment_result_name] -- good
        
  ,[AssignmentResolutions].Id [assigm_assignment_resolution] -- good
  ,[AssignmentResolutions].name [assigm_assignment_resolution_name] -- good

  ,[Workers2].Id [assigm_user_reviewed]
  ,[Workers2].name [assigm_user_reviewed_name] -- good


  ,[Workers3].name [assigm_user_checked_name]
  ,[Workers3].Id [assigm_user_checked]

  ,[Appeals].registration_date  as  [registration_date] -- good
  ,[AssignmentConsiderations].transfer_date [transfer_date] -- good
  ,case when [Assignments].assignment_state_id=3
  then [Assignments].state_change_date end [state_changed_date] -- good
  ,case when [Assignments].assignment_state_id=3 and [AssignmentConsiderations].assignment_result_id=4
  then [Assignments].state_change_date end [state_changed_date_done] -- good
  ,[Assignments].[execution_date] [execution_term] --good
 
 , [StreetTypes].[shortname]
 , [Appeals].[enter_number] appeals_enter_number
 , [Organizations2].Id Organizations2_Id
 , [AssignmentConsiderations].short_answer [control_comment]
 --[AssignmentRevisions].[control_comment]
  from 

  [Assignments] with (nolock)
  inner join [Questions] with (nolock) on [Assignments].question_id=[Questions].Id
  inner join [Appeals] with (nolock) on [Questions].[appeal_id]=[Appeals].Id
  left join [Applicants] with (nolock) on [Applicants].Id=[Appeals].applicant_id
  left join [AssignmentConsiderations] with (nolock) on [AssignmentConsiderations].Id = Assignments.current_assignment_consideration_id
  inner join [AssignmentStates] with (nolock) on [Assignments].assignment_state_id=[AssignmentStates].Id
  left join [AssignmentResults] with (nolock) on [AssignmentConsiderations].assignment_result_id=[AssignmentResults].Id
  left join [AssignmentResolutions] with (nolock) on [AssignmentConsiderations].assignment_resolution_id=[AssignmentResolutions].id
  left join [AssignmentRevisions] with (nolock) on [AssignmentConsiderations].Id=[AssignmentRevisions].assignment_consideration_іd
  inner join [Organizations] [Organizations2] with (nolock) on [Assignments].executor_organization_id=[Organizations2].Id
  left join [Workers] [Workers2] with (nolock) on [AssignmentConsiderations].user_id=[Workers2].worker_user_id
  left join [Workers] [Workers3] with (nolock) on [AssignmentRevisions].user_id=[Workers3].worker_user_id
  inner join [ReceiptSources] with (nolock) on [Appeals].receipt_source_id=[ReceiptSources].Id
  left join [Workers] with (nolock) on [Appeals].user_id=[Workers].worker_user_id
  left join [LiveAddress] with (nolock) on [LiveAddress].applicant_id=[Applicants].Id
  left join [Buildings] with (nolock) on [LiveAddress].building_id=[Buildings].Id
  left join [Districts] with (nolock) on [Buildings].district_id=[Districts].Id
  left join [Streets] with (nolock) on [Buildings].street_id=[Streets].Id
  left join [StreetTypes] with (nolock) on [Streets].[street_type_id]=[StreetTypes].Id
  left join [ApplicantPrivilege] with (nolock) on [Applicants].applicant_privilage_id=[ApplicantPrivilege].Id
  left join [SocialStates] with (nolock) on [Applicants].social_state_id=[SocialStates].Id
  left join [ApplicantTypes] with (nolock) on [Applicants].applicant_type_id=[ApplicantTypes].Id
  left join [Objects] with (nolock) on [Questions].object_id=[Objects].Id
  left join [ObjectTypes] with (nolock) on [Objects].object_type_id=[ObjectTypes].Id
  left join [Organizations] with (nolock) on [Questions].organization_id=[Organizations].Id
  left join [QuestionTypes] with (nolock) on [Questions].question_type_id=[QuestionTypes].Id
  left join [QuestionStates] with (nolock) on [Questions].question_state_id=[QuestionStates].Id
  left join [QuestionTypeInRating] with (nolock) on [QuestionTypeInRating].QuestionType_id=[QuestionTypes].Id
  left join [Rating] with (nolock) on [QuestionTypeInRating].Rating_id=[Rating].Id
  inner join [Organizations] [Organizations10] with (nolock) on [Assignments].[executor_organization_id]=[Organizations10].id
  left join (select distinct [AssignmentConsDocuments].assignment_сons_id
  from [AssignmentConsDocuments] with (nolock)
  right join [AssignmentConsDocFiles] with (nolock) on [AssignmentConsDocuments].Id=[AssignmentConsDocFiles].assignment_cons_doc_id
  where [AssignmentConsDocuments].[doc_type_id] in (3,4) or [AssignmentConsDocuments].Id is not null) files_check on [AssignmentConsiderations].Id=files_check.assignment_сons_id
  ) a
  where '+@param2+ N'  and '+@organizations+N' 

'
 -- and #filter_columns#
 -- #sort_columns#
 --offset ' + (select ltrim(@pageOffsetRows))+N' rows fetch next '+ (select ltrim(@pageLimitRows))+N' rows only
 
 --select @query
  exec(@query)

  --SELECT RTRIM(CAST(DATEDIFF(MS, @start_time, GETDATE()) AS CHAR(10))) AS 'TimeTaken_all'


--  declare @registration_date_fromP nvarchar(200)=
--  case when @registration_date_from is not null 
--  then N' and registration_date>= '''+format(convert(datetime2, @registration_date_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
--  else N'' end;

--  declare @registration_date_toP nvarchar(200)=
--  case when @registration_date_to is not null 
--  then N' and registration_date<= '''+format(convert(datetime2, @registration_date_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
--  else N'' end;



--   declare @transfer_date_fromP nvarchar(200)=
--  case when @transfer_date_from is not null 
--  then N' and transfer_date>= '''+format(convert(datetime2, @transfer_date_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
--  else N'' end;

--  declare @transfer_date_toP nvarchar(200)=
--  case when @transfer_date_to is not null 
--  then N' and transfer_date<= '''+format(convert(datetime2, @transfer_date_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
--  else N'' end;


--  declare @state_changed_date_fromP nvarchar(200)=
--  case when @state_changed_date_from is not null 
--  then N' and state_changed_date>= '''+format(convert(datetime2, @state_changed_date_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
--  else N'' end;

--  declare @state_changed_date_toP nvarchar(200)=
--  case when @state_changed_date_to is not null 
--  then N' and state_changed_date<= '''+format(convert(datetime2, @state_changed_date_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
--  else N'' end;



--   declare @state_changed_date_done_fromP nvarchar(200)=
--  case when @state_changed_date_done_from is not null 
--  then N' and state_changed_date_done>= '''+format(convert(datetime2, @state_changed_date_done_from), 'yyyy-MM-dd HH:mm:00')+N'.000'''
--  else N'' end;

--  declare @state_changed_date_done_toP nvarchar(200)=
--  case when @state_changed_date_done_to is not null 
--  then N' and state_changed_date_done<= '''+format(convert(datetime2, @state_changed_date_done_to), 'yyyy-MM-dd HH:mm:59')+N'.999'''
--  else N'' end;


--   declare @execution_term_fromP nvarchar(200)=
--  case when @execution_term_from is not null 
--  then N' and convert(date, execution_term)>= '''+format(convert(date, dateadd(hh, 5, @execution_term_from)), 'yyyy-MM-dd')+N''''
--  else N'' end;

--  declare @execution_term_toP nvarchar(200)=
--  case when @execution_term_to is not null 
--  then N' and convert(date, execution_term)<= '''+format(convert(date, dateadd(hh, 5, @execution_term_to)), 'yyyy-MM-dd')+N''''
--  else N'' end;

--  --- убрать

--  --select @execution_term_fromP, @execution_term_toP 


--  declare @param4 nvarchar(max)=@registration_date_fromP+@registration_date_toP+@transfer_date_fromP+@transfer_date_toP
--  +@state_changed_date_fromP+@state_changed_date_toP
--  +@state_changed_date_done_fromP+@state_changed_date_done_toP
--  +@execution_term_fromP+@execution_term_toP;

--  --select @registration_date_fromP, @registration_date_toP, @param4



--   declare @organizations nvarchar(max);
--  -----найти подтипы вопросов начало
--  /* найти под типы вопросов*/
-- --declare @param1 nvarchar(500)=N'id=123 and Id=54545';
-- declare @param3 nvarchar(max);
-- if CHARINDEX(N'question_question_type',@param1, 1)>0

-- begin

-- declare @q_types nvarchar(max)=
-- (right(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),
-- len(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)))-
-- CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)), 1)+1))

-- /*
-- select @param1, CHARINDEX(N'question_question_type',@param1, 1),
-- len(@param1)-CHARINDEX(N'question_question_type',@param1, 1),

-- SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1),

-- CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1),

-- left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),

-- len(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)))

-- , CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),
-- 1)
-- /*все ид типов вопроса*/
-- , right(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),
-- len(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)))-
-- CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)), 1)+1)
-- */
-- --select @q_types, REPLACE(REPLACE(@q_types, N')', N''),N'(',N'')

-- declare @input_str nvarchar(max)=REPLACE(REPLACE(@q_types, N')', N''),N'(',N'')+N','

-- --select @input_str
-- -- наша входная строка с айдишниками
-- --declare @input_str nvarchar(100) = N'13,12,34,56,'
 
-- -- создаем таблицу в которую будем
-- -- записывать наши айдишники
-- declare @table table (n int identity(1,1), id int)
 
-- -- создаем переменную, хранящую разделитель
-- declare @delimeter nvarchar(1) = ','
 
-- -- определяем позицию первого разделителя
-- declare @pos int = charindex(@delimeter,@input_str)
 
-- -- создаем переменную для хранения
-- -- одного айдишника
-- declare @id nvarchar(10)
    
-- while (@pos != 0)
-- begin
--     -- получаем айдишник
--     set @id = SUBSTRING(@input_str, 1, @pos-1)
--     -- записываем в таблицу
--     insert into @table (id) values(cast(@id as int))
--     -- сокращаем исходную строку на
--     -- размер полученного айдишника
--     -- и разделителя
--     set @input_str = SUBSTRING(@input_str, @pos+1, LEN(@input_str))
--     -- определяем позицию след. разделителя
--     set @pos = CHARINDEX(@delimeter,@input_str)
-- end

-- --select * from @table

-- ------

-- declare @QuestionTypes2 table(Id int);
-- declare @IdT2 table (Id int);
-- declare @QuestionTypesId2 int
-- declare @n2 int=1;

 
--  while exists(select Id from @table where n=@n2)

-- 	 begin

--  set @QuestionTypesId2 = (select Id from @table where n=@n2)


--  -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
--  insert into @IdT2(Id)
--  select Id from [CRM_1551_Analitics].[dbo].[QuestionTypes] 
--  where (Id=@QuestionTypesId2 or [question_type_id]=@QuestionTypesId2) and Id not in (select Id from @IdT2)

--  --  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
--  while (select count(id) from (select Id from [CRM_1551_Analitics].[dbo].[QuestionTypes]
--  where [question_type_id] in (select Id from @IdT2) --or Id in (select Id from @IdT)
--  and Id not in (select Id from @IdT2)) q)!=0
--  begin

--  insert into @IdT2
--  select Id from [CRM_1551_Analitics].[dbo].[QuestionTypes]
--  where [question_type_id] in (select Id from @IdT2) --or Id in (select Id from @IdT)
--  and Id not in (select Id from @IdT2)
--  end 

--  insert into @QuestionTypes2 (Id)
--  select Id from @IdT2;

-- delete from @IdT2
--  set @n2=@n2+1

-- 	end

--  declare @question_typ nvarchar(max)=(
--  select stuff((select distinct N', '+ltrim(Id) 
--  from @QuestionTypes2
--  for xml path('')),1,2,N''))

--  set @param3 =replace(@param1 
--  ,left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1))
--  ,N'question_question_type in ('+@question_typ+N')')
-- -- select N'question_question_type in ('+@question_typ+N')' --question_question_type in (2, 3, 7, 8)

-- end

-- else
-- begin
-- set @param3=@param1;
-- end;

-- --select @param1, @param3

-- -------------- next

--  declare @assigm_executor_organizations nvarchar(max);
--  -----найти подтипы вопросов начало
--  /* найти под типы вопросов*/
-- --declare @param1 nvarchar(500)=N'id=123 and Id=54545';
-- declare @param_ex nvarchar(max);
-- if CHARINDEX(N'assigm_executor_organization',@param1, 1)>0

-- begin

-- declare @executors nvarchar(max)=
-- (right(left(SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), 1)),
-- len(left(SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), 1)))-
-- CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'assigm_executor_organization',@param1, 1) ,len(@param1)-CHARINDEX(N'assigm_executor_organization',@param1, 1)+1), 1)), 1)+1))

-- /*
-- select @param1, CHARINDEX(N'question_question_type',@param1, 1),
-- len(@param1)-CHARINDEX(N'question_question_type',@param1, 1),

-- SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1),

-- CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1),

-- left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),

-- len(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)))

-- , CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),
-- 1)
-- /*все ид типов вопроса*/
-- , right(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)),
-- len(left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)))-
-- CHARINDEX(N'(', left(SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), CHARINDEX(N')', SUBSTRING(@param1,CHARINDEX(N'question_question_type',@param1, 1) ,len(@param1)-CHARINDEX(N'question_question_type',@param1, 1)+1), 1)), 1)+1)
-- */
-- --select @q_types, REPLACE(REPLACE(@q_types, N')', N''),N'(',N'')

-- declare @input_str_ex nvarchar(max)=REPLACE(REPLACE(@executors, N')', N''),N'(',N'')+N','

-- --select @input_str
-- -- наша входная строка с айдишниками
-- --declare @input_str nvarchar(100) = N'13,12,34,56,'
 
-- -- создаем таблицу в которую будем
-- -- записывать наши айдишники
-- declare @table_ex table (n int identity(1,1), id int)
 
-- -- создаем переменную, хранящую разделитель
-- declare @delimeter_ex nvarchar(1) = ','
 
-- -- определяем позицию первого разделителя
-- declare @pos_ex int = charindex(@delimeter_ex,@input_str_ex)
 
-- -- создаем переменную для хранения
-- -- одного айдишника
-- declare @id_ex nvarchar(10)
    
-- while (@pos_ex != 0)
-- begin
--     -- получаем айдишник
--     set @id_ex = SUBSTRING(@input_str_ex, 1, @pos_ex-1)
--     -- записываем в таблицу
--     insert into @table_ex (id) values(cast(@id_ex as int))
--     -- сокращаем исходную строку на
--     -- размер полученного айдишника
--     -- и разделителя
--     set @input_str_ex = SUBSTRING(@input_str_ex, @pos_ex+1, LEN(@input_str_ex))
--     -- определяем позицию след. разделителя
--     set @pos_ex = CHARINDEX(@delimeter_ex,@input_str_ex)
-- end

-- --select * from @table

-- ------

-- declare @QuestionTypes2_ex table(Id int);
-- declare @IdT2_ex table (Id int);
-- declare @QuestionTypesId2_ex int
-- declare @n2_ex int=1;

 
--  while exists(select Id from @table_ex where n=@n2_ex)

-- 	 begin

--  set @QuestionTypesId2_ex = (select Id from @table_ex where n=@n2_ex)


--  -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
--  insert into @IdT2_ex(Id)
--  select Id from [CRM_1551_Analitics].[dbo].[Organizations] 
--  where (Id=@QuestionTypesId2_ex or [parent_organization_id]=@QuestionTypesId2_ex) and Id not in (select Id from @IdT2_ex)

--  --  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
--  while (select count(id) from (select Id from [CRM_1551_Analitics].[dbo].[Organizations]
--  where [parent_organization_id] in (select Id from @IdT2_ex) --or Id in (select Id from @IdT)
--  and Id not in (select Id from @IdT2_ex)) q)!=0
--  begin

--  insert into @IdT2_ex
--  select Id from [CRM_1551_Analitics].[dbo].[Organizations]
--  where [parent_organization_id] in (select Id from @IdT2_ex) --or Id in (select Id from @IdT)
--  and Id not in (select Id from @IdT2_ex)
--  end 

--  insert into @QuestionTypes2_ex (Id)
--  select Id from @IdT2_ex;

-- delete from @IdT2_ex
--  set @n2_ex=@n2_ex+1

-- 	end

--  declare @question_typ_ex nvarchar(max)=(
--  select stuff((select distinct N', '+ltrim(Id) 
--  from @QuestionTypes2_ex
--  for xml path('')),1,2,N''))

--  set @param_ex =replace(@param3 
--  ,left(SUBSTRING(@param3,CHARINDEX(N'assigm_executor_organization',@param3, 1) ,len(@param3)-CHARINDEX(N'assigm_executor_organization',@param3, 1)+1), CHARINDEX(N')', SUBSTRING(@param3,CHARINDEX(N'assigm_executor_organization',@param3, 1) ,len(@param3)-CHARINDEX(N'assigm_executor_organization',@param3, 1)+1), 1))
--  ,N'assigm_executor_organization in ('+@question_typ_ex+N')')
-- -- select N'question_question_type in ('+@question_typ+N')' --question_question_type in (2, 3, 7, 8)

-- end

-- else
-- begin
-- set @param_ex=@param3;
-- end;

-- --select @param1, @param3, @param_ex
-- --select @param1, @param3
--  -----найти подтипы вопросов конец

   
-- declare @OrgTable table (Id int identity(1,1), OrgId int);
-- declare @Organization table(Id int);
-- declare @IdT table (Id int);
-- declare @OrganizationId int;
-- declare @n int=1;


--   -- @execution_term_from

--   declare @param2 nvarchar(max)=
--   --case when CHARINDEX('cast(execution_term as datetime) >=', @param3, 0)=0 and CHARINDEX('cast(execution_term as datetime) <=', @param3, 0)>0

--       case when @execution_term_from is null and @execution_term_to is not null
--   then @param_ex+N' and [assigm_assignment_state_name]<>N''Закрито''' --Зареєстровано Закрито
--   else @param_ex end+@param4;

--   /* здесь нужно поставить условие, что если у данного человека есть организация 1761 то 1=1
--   иначе нужн запустить пересчет*/

--   --заполение таблицы организацией и ее под
--   declare @organization_id1761 int =1761;
--   declare @Organization1761 table(Id int);
--   declare @OrganizationId1761 int = @organization_id1761;
--   declare @IdT1761 table (Id int);
--  -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
--  insert into @IdT1761(Id)
--  select Id from [CRM_1551_Analitics].[dbo].[Organizations] 
--  where (Id=@OrganizationId1761 or [parent_organization_id]=@OrganizationId1761) and Id not in (select Id from @IdT1761)
--  --  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
--  while (select count(id) from (select Id from [CRM_1551_Analitics].[dbo].[Organizations]
--  where [parent_organization_id] in (select Id from @IdT1761) --or Id in (select Id from @IdT)
--  and Id not in (select Id from @IdT1761)) q)!=0
--  begin
--  insert into @IdT1761
--  select Id from [CRM_1551_Analitics].[dbo].[Organizations]
--  where [parent_organization_id] in (select Id from @IdT1761) --or Id in (select Id from @IdT)
--  and Id not in (select Id from @IdT1761)
--  end 
--  insert into @Organization1761 (Id)
--  select Id from @IdT1761;
--  -- вторая часть, там, где данная организация является дочерней и залить в основную таблицу

--  declare @organization_id1761L int =1761;
-- declare @Organization1761L table(Id int, Id_n int);
-- declare @OrganizationId1761L int =  @organization_id1761L;
-- declare @IdT1761L table (Id int, Id_n int identity(1,1));
-- insert into @IdT1761L(Id) select @OrganizationId1761L
-- while (select [parent_organization_id] from [CRM_1551_Analitics].[dbo].[Organizations] where Id=(select top 1 Id from @IdT1761L order by Id_n desc)) is not null
-- begin 
-- -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
-- insert into @IdT1761L(Id)
-- select [parent_organization_id] from [CRM_1551_Analitics].[dbo].[Organizations] 
-- where Id=(select top 1 Id from @IdT1761L order by Id_n desc) --and Id not in (select Id from @IdT)

-- end

-- insert into @Organization1761 (Id)
-- select Id from @IdT1761L where id<>1761



--  --select * from @Organization1761 --список организаций кому видно все

--  -- проверка на существование в данного человека организаций которую видно все
--  if exists
--  (select [OrganizationInResponsibilityRights].organization_id
--   from [OrganizationInResponsibilityRights]
--   inner join [Positions] on [OrganizationInResponsibilityRights].position_id=[Positions].Id
--   inner join @Organization1761 o1761 on [OrganizationInResponsibilityRights].organization_id=o1761.Id
--   where [Positions].programuser_id=@user_id )

--   begin
--   set @organizations=N'1=1'
--   end

--   else

--   begin

-- insert into @OrgTable (OrgId)

--   select [OrganizationInResponsibilityRights].organization_id
--   from [OrganizationInResponsibilityRights]
--   inner join [Positions] on [OrganizationInResponsibilityRights].position_id=[Positions].Id
--   where [Positions].programuser_id=@user_id


--   while (select count(Id) from @OrgTable)>=@n
--   begin

--   --- новое
--   set @OrganizationId=(select OrgId from @OrgTable where Id=@n)

--   ---


--   -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
-- insert into @IdT(Id)
-- select Id from [CRM_1551_Analitics].[dbo].[Organizations] 
-- where Id=@OrganizationId

-- --  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
-- while (select count(id) from (select Id from [CRM_1551_Analitics].[dbo].[Organizations]
-- where [parent_organization_id] in (select Id from @IdT) 
-- and Id not in (select Id from @IdT)) q)!=0
-- begin

-- insert into @IdT
-- select Id from [CRM_1551_Analitics].[dbo].[Organizations]
-- where [parent_organization_id] in (select Id from @IdT) --or Id in (select Id from @IdT)
-- and Id not in (select Id from @IdT)
-- end 

-- insert into @Organization (Id)
-- select Id from @IdT;

--   set @n=@n+1
--   --set @OrganizationId=(select OrgId from @OrgTable where Id=@n)
--   end

--     set @organizations=N'Organizations2_Id in ('+
--   (select stuff((
--   select distinct N', '+ltrim(Id) from @Organization
--   for xml path('')),1, 2, N''))+N')'

--   end

--   --select @organizations
--   --select @param2;

  
-- declare @query nvarchar(max)=N'
-- select --top 5000
--   [Id]
--   ,[appeals_receipt_source_name] [appeals_receipt_source]
--   ,[appeals_user_name] [appeals_user]
--   ,[appeals_district_name] [appeals_district] 
--   ,[appeals_files_check]
--   ,[zayavnyk_full_name]
--   ,[zayavnyk_phone_number]
--   ,[zayavnyk_building_street_name] [zayavnyk_building_street]

--   ,isnull([shortname],N'''')+N'' ''+[zayavnyk_building_street_name]+N'', ''+[zayavnyk_building_number_name] [zayavnyk_building_number]


--   --,[zayavnyk_building_number_name] [zayavnyk_building_number]
--   ,[zayavnyk_entrance]
--   ,[zayavnyk_flat]
--   ,[zayavnyk_applicant_privilage_name] [zayavnyk_applicant_privilage]
--   ,[zayavnyk_social_state_name] [zayavnyk_social_state]
--   ,[zayavnyk_sex_name] [zayavnyk_sex]
--   ,[zayavnyk_applicant_type_name] [zayavnyk_applicant_type]
--   ,[zayavnyk_age]
--   ,[zayavnyk_email]
--   ,[question_registration_number]
--   ,[question_ObjectTypes_name] [question_ObjectTypes]
--   ,[question_object_name] [question_object]
--   ,[question_organization_name] [question_organization]
--   ,[question_question_type_name] [question_question_type]
--   ,[question_question_state_name] [question_question_state]
--   ,[question_list_state_name] [question_list_state]
--   ,[assigm_executor_organization_name] [assigm_executor_organization]
--   ,[assigm_main_executor]
--   ,[assigm_question_content]
--   ,[assigm_accountable_name] [assigm_accountable] 
--   ,[assigm_assignment_state_name] [assigm_assignment_state]  
--   ,[assigm_assignment_result_name] [assigm_assignment_result] 
--   ,[assigm_assignment_resolution_name] [assigm_assignment_resolution]
--   ,[assigm_user_reviewed_name] [assigm_user_reviewed] 
--   ,[assigm_user_checked_name] [assigm_user_checked]
--   --,[assigm_user_checked_Id] [assigm_user_checked]

-- --   ,format(registration_date, ''dd.MM.yyyy HH:mm'') as [registration_date] 
-- --   ,format(transfer_date, ''dd.MM.yyyy HH:mm'') as [transfer_date] 
-- --   ,format(state_changed_date, ''dd.MM.yyyy HH:mm'') as [state_changed_date]
-- --   ,format(state_changed_date_done, ''dd.MM.yyyy HH:mm'') as [state_changed_date_done]
--   ,convert(datetime, [registration_date]) [registration_date]
--   ,convert(datetime, [transfer_date]) [transfer_date]
--   ,convert(datetime, [state_changed_date]) [state_changed_date]
--   ,convert(datetime, [state_changed_date_done]) [state_changed_date_done]
  
--   ,[execution_term] 
--   ,[appeals_enter_number]
--   ,[control_comment]
--  from
--  (
--   select [Assignments].Id,
--   [Appeals].receipt_source_id [appeals_receipt_source]
--   ,[ReceiptSources].name [appeals_receipt_source_name]
--   ,[Appeals].user_id [appeals_user]
--   --,[Workers].Id [appeals_user_Id]
--   ,[Workers].name [appeals_user_name]
--   ,[Districts].Id [appeals_district] 
--   ,[Districts].name [appeals_district_name] 
--   --,case when [AssignmentConsDocFiles].[File] is not null then convert(bit, N''true'') else convert(bit, N''false'') end appeals_files_check
--   --,null appeals_files_check
--   ,case when files_check.assignment_сons_id is not null then ''true'' else ''false'' end appeals_files_check

--   ,[Applicants].full_name zayavnyk_full_name
--   /*,[ApplicantPhones].phone_number zayavnyk_phone_number */
--   ,stuff((select N'', ''+phone_number
-- 					from [dbo].[ApplicantPhones] t1
-- 					where [t1].applicant_id=[Applicants].id
-- 					order by t1.id
-- 					for xml path('''')),1,2,N'''') zayavnyk_phone_number
--   ,[Streets].Id [zayavnyk_building_street]
--   ,[Streets].name [zayavnyk_building_street_name]
--   ,[Buildings].Id [zayavnyk_building_number]
--   ,[Buildings].name [zayavnyk_building_number_name]
--   ,[LiveAddress].entrance [zayavnyk_entrance]
--   ,[LiveAddress].flat [zayavnyk_flat]
--   ,[ApplicantPrivilege].Id [zayavnyk_applicant_privilage]
--   ,[ApplicantPrivilege].Name [zayavnyk_applicant_privilage_name]
--   ,[SocialStates].Id [zayavnyk_social_state]
--   ,[SocialStates].name [zayavnyk_social_state_name]
--   ,[Applicants].sex [zayavnyk_sex]
--   ,case when [Applicants].sex=1 then N''жіноча'' when [Applicants].sex=2 then N''чоловіча'' end [zayavnyk_sex_name]
--   ,[ApplicantTypes].Id [zayavnyk_applicant_type]
--   ,[ApplicantTypes].name [zayavnyk_applicant_type_name]
--   ,case 
-- when [Applicants].[birth_date] is null then year(getdate())-[Applicants].birth_year
--   when month([Applicants].[birth_date])<=month(getdate())
--   and day([Applicants].[birth_date])<=day(getdate())
--   then DATEDIFF(yy, [Applicants].[birth_date], getdate())
--   else DATEDIFF(yy, [Applicants].[birth_date], getdate())-1 end zayavnyk_age,
--   [Applicants].mail zayavnyk_email
  
--   ,[Questions].registration_number [question_registration_number]
--   ,[ObjectTypes].Id [question_ObjectTypes]
--   ,[ObjectTypes].name [question_ObjectTypes_name]
--   ,[Objects].Id [question_object]
--   ,[Objects].name [question_object_name]
--   ,[Organizations].Id [question_organization]
--   ,[Organizations].short_name [question_organization_name]
--   ,[QuestionTypes].Id [question_question_type]
--   ,[QuestionTypes].name [question_question_type_name]
--   ,[QuestionStates].Id [question_question_state]
--   ,[QuestionStates].name [question_question_state_name]
--   ,[Rating].Id [question_list_state]
--   ,[Rating].name [question_list_state_name]

--   ,[Assignments].executor_organization_id [assigm_executor_organization] -- good
--   ,IIF (len([Organizations2].[head_name]) > 5,  concat([Organizations2].[head_name] , '' ( '' , [Organizations2].[short_name] , '')''),  [Organizations2].[short_name]) [assigm_executor_organization_name]
--   --,[Organizations2].short_name [assigm_executor_organization_name] -- good
--   ,[Assignments].main_executor [assigm_main_executor] -- good
--   ,[Questions].question_content [assigm_question_content] -- good
--   ,[Organizations10].[short_name] [assigm_accountable_name] -- good
--   ,[Organizations10].Id [assigm_accountable]

--   ,[AssignmentStates].Id [assigm_assignment_state] -- good
--   ,[AssignmentStates].name [assigm_assignment_state_name] -- good
         
--   ,[AssignmentResults].Id [assigm_assignment_result] -- good
--   ,[AssignmentResults].name [assigm_assignment_result_name] -- good
        
--   ,[AssignmentResolutions].Id [assigm_assignment_resolution] -- good
--   ,[AssignmentResolutions].name [assigm_assignment_resolution_name] -- good

--   --,[AssignmentConsiderations].user_id [assigm_user_reviewed] -- good
--   ,[Workers2].Id [assigm_user_reviewed]
--   ,[Workers2].name [assigm_user_reviewed_name] -- good
   
--   --,[AssignmentRevisions].user_id [assigm_user_checked] 

--   ,[Workers3].name [assigm_user_checked_name]
--   ,[Workers3].Id [assigm_user_checked]

--   ,[Appeals].registration_date  as  [registration_date] -- good
--   ,[AssignmentConsiderations].transfer_date [transfer_date] -- good
--   ,case when [Assignments].assignment_state_id=3
--   then [Assignments].state_change_date end [state_changed_date] -- good
--   ,case when [Assignments].assignment_state_id=3 and [AssignmentConsiderations].assignment_result_id=4
--   then [Assignments].state_change_date end [state_changed_date_done] -- good
--   ,[Assignments].[execution_date] [execution_term] --good
 
--  , [StreetTypes].[shortname]
--  , [Appeals].[enter_number] appeals_enter_number
--  , [Organizations2].Id Organizations2_Id
--  , [AssignmentConsiderations].short_answer [control_comment]
--  --[AssignmentRevisions].[control_comment]
--   from 

--   [CRM_1551_Analitics].[dbo].[Assignments] 
--   left join [CRM_1551_Analitics].[dbo].[Questions] on [Assignments].question_id=[Questions].Id
--   left join [CRM_1551_Analitics].[dbo].[Appeals] on [Questions].[appeal_id]=[Appeals].Id
--   left join [CRM_1551_Analitics].[dbo].[Applicants] on [Applicants].Id=[Appeals].applicant_id

  


-- --   left join [CRM_1551_Analitics].[dbo].[AssignmentConsiderations] on [AssignmentConsiderations].assignment_id=[Assignments].Id
--   left join [CRM_1551_Analitics].[dbo].[AssignmentConsiderations] on [AssignmentConsiderations].Id = Assignments.current_assignment_consideration_id
--   left join [CRM_1551_Analitics].[dbo].[AssignmentStates] on [Assignments].assignment_state_id=[AssignmentStates].Id
--   left join [CRM_1551_Analitics].[dbo].[AssignmentResults] on [AssignmentConsiderations].assignment_result_id=[AssignmentResults].Id
--   left join [CRM_1551_Analitics].[dbo].[AssignmentResolutions] on [AssignmentConsiderations].assignment_resolution_id=[AssignmentResolutions].id
--   left join [CRM_1551_Analitics].[dbo].[AssignmentRevisions] on [AssignmentConsiderations].Id=[AssignmentRevisions].assignment_consideration_іd
--   left join [CRM_1551_Analitics].[dbo].[Organizations] [Organizations2] on [Assignments].executor_organization_id=[Organizations2].Id
--   left join [CRM_1551_Analitics].[dbo].[Workers] [Workers2] on [AssignmentConsiderations].user_id=[Workers2].worker_user_id
--   left join [CRM_1551_Analitics].[dbo].[Workers] [Workers3] on [AssignmentRevisions].user_id=[Workers3].worker_user_id

  

  
--   left join [CRM_1551_Analitics].[dbo].[ReceiptSources] on [Appeals].receipt_source_id=[ReceiptSources].Id
--   left join [CRM_1551_Analitics].[dbo].[Workers] on [Appeals].user_id=[Workers].worker_user_id

  
--   /*left join [CRM_1551_Analitics].[dbo].[ApplicantPhones] 
-- 									on [ApplicantPhones].applicant_id=[Applicants].id*/
--   left join [CRM_1551_Analitics].[dbo].[LiveAddress] on [LiveAddress].applicant_id=[Applicants].Id
--   left join [CRM_1551_Analitics].[dbo].[Buildings] on [LiveAddress].building_id=[Buildings].Id
--   left join [CRM_1551_Analitics].[dbo].[Districts] on [Buildings].district_id=[Districts].Id
--   left join [CRM_1551_Analitics].[dbo].[Streets] on [Buildings].street_id=[Streets].Id

--   left join [CRM_1551_Analitics].[dbo].[StreetTypes] on [Streets].[street_type_id]=[StreetTypes].Id

--   left join [CRM_1551_Analitics].[dbo].[ApplicantPrivilege] on [Applicants].applicant_privilage_id=[ApplicantPrivilege].Id
--   left join [CRM_1551_Analitics].[dbo].[SocialStates] on [Applicants].social_state_id=[SocialStates].Id
--   left join [CRM_1551_Analitics].[dbo].[ApplicantTypes] on [Applicants].applicant_type_id=[ApplicantTypes].Id

  
--   left join [CRM_1551_Analitics].[dbo].[Objects] on [Questions].object_id=[Objects].Id
--   left join [CRM_1551_Analitics].[dbo].[ObjectTypes] on [Objects].object_type_id=[ObjectTypes].Id
--   left join [CRM_1551_Analitics].[dbo].[Organizations] on [Questions].organization_id=[Organizations].Id
--   left join [CRM_1551_Analitics].[dbo].[QuestionTypes] on [Questions].question_type_id=[QuestionTypes].Id
--   left join [CRM_1551_Analitics].[dbo].[QuestionStates] on [Questions].question_state_id=[QuestionStates].Id
--   left join [CRM_1551_Analitics].[dbo].[QuestionTypeInRating] on [QuestionTypeInRating].QuestionType_id=[QuestionTypes].Id
--   left join [CRM_1551_Analitics].[dbo].[Rating] on [QuestionTypeInRating].Rating_id=[Rating].Id
--   left join [CRM_1551_Analitics].[dbo].[Organizations] [Organizations10] on [Assignments].[executor_organization_id]=[Organizations10].id
--   left join (select distinct [AssignmentConsDocuments].assignment_сons_id
--   from [CRM_1551_Analitics].[dbo].[AssignmentConsDocuments]
--   right join [CRM_1551_Analitics].[dbo].[AssignmentConsDocFiles] on [AssignmentConsDocuments].Id=[AssignmentConsDocFiles].assignment_cons_doc_id
--   where [AssignmentConsDocuments].[doc_type_id] in (3,4) or [AssignmentConsDocuments].Id is not null) files_check on [AssignmentConsiderations].Id=files_check.assignment_сons_id
  

--   ) a
--   where '+@param2+ N'  and '+@organizations+N' 
 


-- '
--  -- and #filter_columns#
--  -- #sort_columns#
--  --offset ' + (select ltrim(@pageOffsetRows))+N' rows fetch next '+ (select ltrim(@pageLimitRows))+N' rows only
 
--  --select @query
--   exec(@query)
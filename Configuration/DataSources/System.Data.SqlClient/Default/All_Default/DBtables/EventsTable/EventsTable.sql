/*
 declare @organization_id int =2000;
declare @user_id nvarchar(300)=N'02ece542-2d75-479d-adad-fd333d09604d';
declare @OtKuda nvarchar(20)=N'Усі';
declare @TypeEvent nvarchar(20)=N'Не активні';
*/
declare @TypeEvent_table table (name nvarchar(20));
declare @OtKuda_table table (name nvarchar(20));

 
if @TypeEvent=N'Усі'
begin
	insert into @TypeEvent_table(name)
	select N'В роботі' union all select N'Не активні' union all select N'Прострочені'
end
else
begin
	insert into @TypeEvent_table(name)
	select @TypeEvent
end


if @OtKuda=N'Усі'
begin
	insert into @OtKuda_table(name)
	select N'Городок' union all select N'Система'
end
else
begin
	insert into @OtKuda_table(name)
	select @OtKuda
end



declare @Organization table(Id int);

--select 8 id;


-- ЕСЛИ НУЖНО ВЫБИРАТЬ ЮЗЕРА
--declare @user_id nvarchar(300)=N'02ece542-2d75-479d-adad-fd333d09604d';
-- МОЖНО ПРОСТО ИД ОРГАНИЗАЦИИ ВЛЕПИТЬ

--if @organization_id is null


declare @OrganizationId int = 
case 
when @organization_id is not null
then @organization_id
else (select Id
  from [CRM_1551_Analitics].[dbo].[Organizations]
  where Id in (select organization_id
  from [CRM_1551_Analitics].[dbo].[Workers]
  where worker_user_id=@user_id))
 end


declare @IdT table (Id int);

-- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
insert into @IdT(Id)
select Id from [CRM_1551_Analitics].[dbo].[Organizations] 
where (Id=@OrganizationId or [parent_organization_id]=@OrganizationId) and Id not in (select Id from @IdT)

--  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
while (select count(id) from (select Id from [CRM_1551_Analitics].[dbo].[Organizations]
where [parent_organization_id] in (select Id from @IdT) --or Id in (select Id from @IdT)
and Id not in (select Id from @IdT)) q)!=0
begin

insert into @IdT
select Id from [CRM_1551_Analitics].[dbo].[Organizations]
where [parent_organization_id] in (select Id from @IdT) --or Id in (select Id from @IdT)
and Id not in (select Id from @IdT)
end 

insert into @Organization (Id)
select Id from @IdT;


with
  [Events_1] as 
  (
  select [Events].Id, [Events].active, [Events].[plan_end_date], [Events].gorodok_id, [Events].event_type_id, [Events].start_date,
  [Event_Class].name EventName
  from [CRM_1551_Analitics].[dbo].[Events]
  inner join [CRM_1551_Analitics].[dbo].[EventOrganizers] on [Events].Id=[EventOrganizers].event_id
  left join [Event_Class] on [Events].event_class_id=[Event_Class].id
  where [EventOrganizers].organization_id in (select id from @Organization)
  union
  select [Events].Id, [Events].active, [Events].[plan_end_date], [Events].gorodok_id, [Events].event_type_id, [Events].start_date,
  [Event_Class].name EventName
  from [CRM_1551_Analitics].[dbo].[Events] 
  inner join [CRM_1551_Analitics].[dbo].[EventObjects] on [Events].Id=[EventObjects].event_id
  left join [CRM_1551_Analitics].[dbo].[Objects] on [EventObjects].object_id=[Objects].Id
  left join [CRM_1551_Analitics].[dbo].[Buildings] on [Buildings].Id=[Objects].builbing_id
  left join [CRM_1551_Analitics].[dbo].[ExecutorInRoleForObject] on [ExecutorInRoleForObject].building_id=[Buildings].Id
  left join [Event_Class] on [Events].event_class_id=[Event_Class].id
  where [ExecutorInRoleForObject].[executor_role_id] in (1, 68) /*балансоутримувач, генпідрядник*/
  and [ExecutorInRoleForObject].executor_id in (select id from @Organization)
  
  ),

  [Events_2] as 
  (
  select [Events].Id, [Events].active, [Events].[plan_end_date], [Events].gorodok_id
  , [EventObjects].object_id, /*[Events].question_type_id, */[EventOrganizers].organization_id
  from [CRM_1551_Analitics].[dbo].[Events]
  inner join [CRM_1551_Analitics].[dbo].[EventOrganizers] on [Events].Id=[EventOrganizers].event_id
  left join [CRM_1551_Analitics].[dbo].[EventObjects] on [Events].Id=[EventObjects].event_id
  where [EventOrganizers].organization_id in (select id from @Organization)
  union
  select [Events].Id, [Events].active, [Events].[plan_end_date], [Events].gorodok_id
  , [Objects].Id, /*[Events].question_type_id,*/ [ExecutorInRoleForObject].executor_id
  from [CRM_1551_Analitics].[dbo].[Events] 
  inner join [CRM_1551_Analitics].[dbo].[EventObjects] on [Events].Id=[EventObjects].event_id
  left join [CRM_1551_Analitics].[dbo].[Objects] on [EventObjects].object_id=[Objects].Id
  left join [CRM_1551_Analitics].[dbo].[Buildings] on [Buildings].Id=[Objects].builbing_id
  left join [CRM_1551_Analitics].[dbo].[ExecutorInRoleForObject] on [ExecutorInRoleForObject].building_id=[Buildings].Id
  where [ExecutorInRoleForObject].[executor_role_id] in (1, 68) /*балансоутримувач, генпідрядник*/
  and [ExecutorInRoleForObject].executor_id in (select id from @Organization)
  
  ),

  main as
  (
  select [Events_1].Id event_Id, [Events_1].event_type_id, [EventTypes].name EventType, Questions.Id question_Id, [Events_1].start_date, [Events_1].plan_end_date,
  [Events_1].EventName,
  case when [Events_1].active =1 and [Events_1].[plan_end_date]>getutcdate() then N'В роботі'
  when [Events_1].active =1 and [Events_1].[plan_end_date]<=getutcdate() then N'Прострочені'
  when [Events_1].active =0 then N'Не активні' end TypeEvent,
  case when [Events_1].gorodok_id=1 then N'Городок' else N'Система' end OtKuda
  from [Events_1]
  left join EventQuestionsTypes on EventQuestionsTypes.event_id = [Events_1].Id 
  left join [EventObjects] on [EventObjects].event_id = [Events_1].Id
  left join Questions on Questions.question_type_id = EventQuestionsTypes.question_type_id and [Questions].[object_id] = [EventObjects].[object_id]
  left join [EventTypes] on [Events_1].event_type_id=[EventTypes].Id
  )

  select event_Id EventId, EventType, EventName, start_date, plan_end_date, count(question_Id) CountQuestions
  from main
  where main.TypeEvent in (select name from @TypeEvent_table) and main.OtKuda in (select name from @OtKuda_table)
  group by event_Id, EventType, EventName, start_date, plan_end_date
/*
 declare @organization_id int =2000;
declare @user_id nvarchar(300)=N'02ece542-2d75-479d-adad-fd333d09604d';
*/
declare @Organization table(Id int);


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
  ),

  typ as (select 1 Id, N'Городок' name union all select 2 Id, N'Система')

 /* select typ.Id, typ.name typ, main.TypeEvent, count(main.question_Id) count_questions
  from typ left join main on typ.name=main.OtKuda
  group by typ.Id, typ.name, main.TypeEvent

 */ 
 -- количество вопросов в типе
 , count_questions as
 (
  select Id, typ, isnull([Прострочені], 0) [Прострочені], isnull([Не активні], 0) [Не активні], isnull([В роботі],0) [В роботі]
  from
  (select typ.Id, typ.name typ, main.TypeEvent, count(main.question_Id) count_questions
  from typ left join main on typ.name=main.OtKuda
  group by typ.Id, typ.name, main.TypeEvent) t
  pivot 
  (
  sum(count_questions) for TypeEvent in ([Прострочені], [Не активні], [В роботі])
  ) pvt
  ),

  count_events as
  (
  select Id, typ, isnull([Прострочені], 0) [Прострочені], isnull([Не активні], 0) [Не активні], isnull([В роботі],0) [В роботі]
  from
  (select typ.Id, typ.name typ, main.TypeEvent, count(distinct main.event_Id) count_events
  from typ left join main on typ.name=main.OtKuda
  group by typ.Id, typ.name, main.TypeEvent) t
  pivot 
  (
  sum(count_events) for TypeEvent in ([Прострочені], [Не активні], [В роботі])
  ) pvt
 )

 select count_questions.Id, count_questions.typ [type], 
 ltrim(count_events.Прострочені)+N' ('+ltrim(count_questions.Прострочені)+N')' [Прострочені],
 ltrim(count_events.[Не активні])+N' ('+ltrim(count_questions.[Не активні])+N')' [Не активні],
 ltrim(count_events.[В роботі])+N' ('+ltrim(count_questions.[В роботі])+N')' [В роботі]
 from count_questions inner join count_events on count_questions.Id=count_events.Id

/*
 declare @organization_id int =2349;
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

    [Events] as 
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
  (select [Events].Id,
  case when [Events].active =1 and [Events].[plan_end_date]>getutcdate() then N'Активні'
  when [Events].active =1 and [Events].[plan_end_date]<=getutcdate() then N'Прострочені'
  when [Events].active =0 then N'Закриті' end TypeEvent,
  case when [Events].gorodok_id=1 then N'Городок' else N'Система' end OtKuda
  ,count([Questions].Id) count_questions

  from 
  [Events]
  --left join [CRM_1551_Analitics].[dbo].[Questions] on ([Events].question_type_id=[Questions].question_type_id and [Events].object_id=[Questions].object_id)
  left join EventQuestionsTypes on EventQuestionsTypes.event_id = [Events].Id 
  left join [EventObjects] on [EventObjects].event_id = [Events].Id
  left join Questions on Questions.question_type_id = EventQuestionsTypes.question_type_id and [Questions].[object_id] = [EventObjects].[object_id]
  where [Events].organization_id in (select id from @Organization)
  group by [Events].Id,
  case when [Events].active =1 and [Events].[plan_end_date]>getutcdate() then N'Активні'
  when [Events].active =1 and [Events].[plan_end_date]<=getutcdate() then N'Прострочені'
  when [Events].active =0 then N'Закриті' end,
  case when [Events].gorodok_id=1 then N'Городок' else N'Система' end
  ),

  typ as (select 1 Id, N'Городок' name union all select 2 Id, N'Система'),

  even as
  (select typ.Id, typ.name, 
  sum(case when main.OtKuda=N'Система' then 1 else 0 end) System,
  sum(case when main.OtKuda=N'Городок' then 1 else 0 end) Gorodok
  
  from typ left join main on typ.name=main.TypeEvent
  group by typ.Id, typ.name),

  sumevent as 
  (
  select sum(System) cs, sum(Gorodok) cg from even
  ),

  c_question as
  (select OtKuda, isnull([Активні],0) [Активні], isnull([Прострочені],0) [Прострочені], isnull([Закриті], 0) [Закриті]
  from (select typ.name OtKuda, isnull(count_questions,0) count_questions, main.TypeEvent  from typ left join main on typ.name=main.OtKuda) p
  pivot 
  (
  sum(count_questions) 
  for TypeEvent in ([Активні], [Прострочені], [Закриті])
  ) pvt),

 
  c_events as
  (select OtKuda, [Активні], [Прострочені], [Закриті]
  from (select main.Id, typ.name OtKuda, main.TypeEvent from typ left join main on typ.name=main.OtKuda) p
  pivot 
  (
  count(id) 
  for [TypeEvent] in ([Активні], [Прострочені], [Закриті])
  ) pvt)
 
  select ROW_NUMBER() over(order by c_events.OtKuda) Id, 
  c_events.OtKuda type, 
  ltrim(c_events.[Прострочені])+N' ('+ltrim(c_question.[Прострочені])+N')' [Прострочені]
  ,ltrim(c_events.[Закриті])+N' ('+ltrim(c_question.[Закриті])+N')' [Не активні]
  ,ltrim(c_events.[Активні])+N' ('+ltrim(c_question.[Активні])+N')' [В роботі]
  from c_events inner join c_question on c_events.OtKuda=c_question.OtKuda



-- declare @Organization table(Id int);

-- declare @OrganizationId int = 
-- case 
-- when @organization_id is not null
-- then @organization_id
-- else (select Id
--   from [CRM_1551_Analitics].[dbo].[Organizations]
--   where Id in (select organization_id
--   from [CRM_1551_Analitics].[dbo].[Workers]
--   where worker_user_id=@user_id))
--  end


-- declare @IdT table (Id int);

-- -- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
-- insert into @IdT(Id)
-- select Id from [CRM_1551_Analitics].[dbo].[Organizations] 
-- where (Id=@OrganizationId or [parent_organization_id]=@OrganizationId) and Id not in (select Id from @IdT)

-- --  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
-- while (select count(id) from (select Id from [CRM_1551_Analitics].[dbo].[Organizations]
-- where [parent_organization_id] in (select Id from @IdT) --or Id in (select Id from @IdT)
-- and Id not in (select Id from @IdT)) q)!=0
-- begin

-- insert into @IdT
-- select Id from [CRM_1551_Analitics].[dbo].[Organizations]
-- where [parent_organization_id] in (select Id from @IdT) --or Id in (select Id from @IdT)
-- and Id not in (select Id from @IdT)
-- end 

-- insert into @Organization (Id)
-- select Id from @IdT;

--   with
--   main as
--   (select [Events].Id,
--   case when [Events].active =1 and [Events].[plan_end_date]<getdate() then N'Активні'
--   when [Events].active =1 and [Events].[plan_end_date]>=getdate() then N'Прострочені'
--   when [Events].active =0 then N'Закриті' end TypeEvent,
--   case when [Events].gorodok_id=1 then N'Городок' else N'Система' end OtKuda
--   ,count([Questions].Id) count_questions
--   --[Events].Id, [Events].active, [GorodokClaims].global, [Events].[plan_end_date]
--   from 
--   [CRM_1551_Analitics].[dbo].[Events]
--   left join [CRM_1551_Analitics].[dbo].[EventOrganizers] on [Events].Id=[EventOrganizers].event_id
  
--   left join [CRM_1551_Analitics].[dbo].[EventObjects] on [Events].Id=[EventObjects].[event_id]
--   left join [CRM_1551_Analitics].[dbo].[Objects] on [EventObjects].[object_id]=[Objects].Id
--   left join [CRM_1551_Analitics].[dbo].[Questions] on ([Events].question_type_id=[Questions].question_type_id and [Objects].Id=[Questions].object_id)
--   where [EventOrganizers].organization_id in (select id from @Organization)
--   group by [Events].Id,
--   case when [Events].active =1 and [Events].[plan_end_date]<getdate() then N'Активні'
--   when [Events].active =1 and [Events].[plan_end_date]>=getdate() then N'Прострочені'
--   when [Events].active =0 then N'Закриті' end,
--   case when [Events].gorodok_id=1 then N'Городок' else N'Система' end
--   ),

--   typ as (select 1 Id, N'Городок' name union all select 2 Id, N'Система'),

--   even as
--   (select typ.Id, typ.name, 
--   sum(case when main.OtKuda=N'Система' then 1 else 0 end) System,
--   sum(case when main.OtKuda=N'Городок' then 1 else 0 end) Gorodok
  
--   from typ left join main on typ.name=main.TypeEvent
--   group by typ.Id, typ.name),

--   sumevent as 
--   (
--   select sum(System) cs, sum(Gorodok) cg from even
--   ),

--   c_question as
--   (select OtKuda, isnull([Активні],0) [Активні], isnull([Прострочені],0) [Прострочені], isnull([Закриті], 0) [Закриті]
--   from (select typ.name OtKuda, isnull(count_questions,0) count_questions, main.TypeEvent  from typ left join main on typ.name=main.OtKuda) p
--   pivot 
--   (
--   sum(count_questions) 
--   for TypeEvent in ([Активні], [Прострочені], [Закриті])
--   ) pvt),

 
--   c_events as
--   (select OtKuda, [Активні], [Прострочені], [Закриті]
--   from (select main.Id, typ.name OtKuda, main.TypeEvent from typ left join main on typ.name=main.OtKuda) p
--   pivot 
--   (
--   count(id) 
--   for [TypeEvent] in ([Активні], [Прострочені], [Закриті])
--   ) pvt)
 
--   select ROW_NUMBER() over(order by c_events.OtKuda) Id, 
--   c_events.OtKuda type, 
--   ltrim(c_events.[Прострочені])+N' ('+ltrim(c_question.[Прострочені])+N')' [Прострочені]
--   ,ltrim(c_events.[Закриті])+N' ('+ltrim(c_question.[Закриті])+N')' [Не активні]
--   ,ltrim(c_events.[Активні])+N' ('+ltrim(c_question.[Активні])+N')' [В роботі]
--   from c_events inner join c_question on c_events.OtKuda=c_question.OtKuda

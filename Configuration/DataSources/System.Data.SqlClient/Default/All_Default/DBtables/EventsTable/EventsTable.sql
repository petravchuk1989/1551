/*
 declare @organization_id int =2349;
declare @user_id nvarchar(300)=N'02ece542-2d75-479d-adad-fd333d09604d';
declare @OtKuda nvarchar(20)=N'Усі';
declare @TypeEvent nvarchar(20)=N'Усі';
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
  [Events] as 
  (
  select [Events].Id, [Events].active, [Events].[plan_end_date], [Events].gorodok_id
  from [CRM_1551_Analitics].[dbo].[Events]
  inner join [CRM_1551_Analitics].[dbo].[EventOrganizers] on [Events].Id=[EventOrganizers].event_id
  where [EventOrganizers].organization_id in (select id from @Organization)
  union
  select [Events].Id, [Events].active, [Events].[plan_end_date], [Events].gorodok_id
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
  case when [Events].active =1 and [Events].[plan_end_date]>getutcdate() then N'В роботі'
  when [Events].active =1 and [Events].[plan_end_date]<=getutcdate() then N'Прострочені'
  when [Events].active =0 then N'Не активні' end TypeEvent,
  case when [Events].gorodok_id=1 then N'Городок' else N'Система' end OtKuda
  from [Events]
  )

  
  select [Events].Id EventId, [EventTypes].name EventType, [Event_Class].name EventName, [Events].start_date, [Events].plan_end_date,
  COUNT([Questions].Id) CountQuestions
  from [CRM_1551_Analitics].[dbo].[Events]
  inner join main on [Events].Id=main.Id
  left join [Event_Class] on [Events].event_class_id=[Event_Class].id

  left join [CRM_1551_Analitics].[dbo].[EventTypes] on [Events].event_type_id=[EventTypes].Id
  left join [CRM_1551_Analitics].[dbo].[EventObjects] on [Events].Id=[EventObjects].[event_id]
  left join [CRM_1551_Analitics].[dbo].[Objects] on [EventObjects].[object_id]=[Objects].Id

  left join EventQuestionsTypes on EventQuestionsTypes.event_id = [Events].Id 
  --left join [EventObjects] on [EventObjects].event_id = [Events].Id
  left join Questions on (Questions.question_type_id = EventQuestionsTypes.question_type_id and [Questions].[object_id] = [EventObjects].[object_id])
  --left join [CRM_1551_Analitics].[dbo].[Questions] on ([Events].question_type_id=[Questions].question_type_id and [Objects].Id=[Questions].object_id)
  where main.TypeEvent in (select name from @TypeEvent_table) and main.OtKuda in (select name from @OtKuda_table)
  group by [Events].Id, [EventTypes].name, [Event_Class].name, [Events].start_date, [Events].plan_end_date
  order by [Events].Id


-- declare @TypeEvent_table table (name nvarchar(20));

 
-- if @TypeEvent=N'Усі'
-- begin
-- 	insert into @TypeEvent_table(name)
-- 	select N'В роботі' union all select N'Не активні' union all select N'Прострочені'
-- end
-- else
-- begin
-- 	insert into @TypeEvent_table(name)
-- 	select @TypeEvent
-- end

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
--   case when [Events].active =1 and [Events].[plan_end_date]<getdate() then N'В роботі'
--   when [Events].active =1 and [Events].[plan_end_date]>=getdate() then N'Прострочені'
--   when [Events].active =0 then N'Не активні' end TypeEvent,
--   case when [Events].gorodok_id=1 then N'Городок' else N'Система' end OtKuda
--   --,count([Questions].Id) count_questions
--   --[Events].Id, [Events].active, [GorodokClaims].global, [Events].[plan_end_date]
--   from 
--   [CRM_1551_Analitics].[dbo].[Events]
--   inner join [CRM_1551_Analitics].[dbo].[EventOrganizers] on [Events].Id=[EventOrganizers].event_id
--   where [EventOrganizers].organization_id in (select id from @Organization)

  
--   )

  
--   select [Events].Id EventId, [EventTypes].name EventType, [Events].name EventName, [Events].start_date, [Events].plan_end_date,
--   COUNT([Questions].Id) CountQuestions
--   from [CRM_1551_Analitics].[dbo].[Events]
--   inner join main on [Events].Id=main.Id
--   left join [CRM_1551_Analitics].[dbo].[EventTypes] on [Events].event_type_id=[EventTypes].Id
--   left join [CRM_1551_Analitics].[dbo].[EventObjects] on [Events].Id=[EventObjects].[event_id]
--   left join [CRM_1551_Analitics].[dbo].[Objects] on [EventObjects].[object_id]=[Objects].Id
--   left join [CRM_1551_Analitics].[dbo].[Questions] on ([Events].question_type_id=[Questions].question_type_id and [Objects].Id=[Questions].object_id)
--   where main.TypeEvent in (select name from @TypeEvent_table)
--   group by [Events].Id, [EventTypes].name, [Events].name, [Events].start_date, [Events].plan_end_date
--   order by [Events].Id
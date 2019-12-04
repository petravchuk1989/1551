/*
declare @phone nvarchar(50)=N'11111111111';
declare @true_applicant_id int = 1490252;
declare @user_Id nvarchar(128)=N'Вася Тестовый';
declare @Id_table int=1;
*/
 
 update [ApplicantDublicate]
  set [IsDone]='true'
  ,[User_done_id]=@user_Id
  ,[Done_date]=GETUTCDATE()
  where Id=@Id_table


-- все номера у данного апликанта
  declare @phones_with_applicant table (Id int, applicant_Id int, phone_number nvarchar(50));

  insert into @phones_with_applicant (Id, applicant_Id, phone_number)

  select Id, applicant_Id, phone_number
  from [ApplicantPhones]
  where applicant_id=@true_applicant_id

  -- все applicant за данными номерами
  declare @applicant_with_phones table (Id int, applicant_Id int, phone_number nvarchar(50));

  insert into @applicant_with_phones (Id, applicant_Id, phone_number)
  select [ApplicantPhones].Id, [ApplicantPhones].applicant_id, [ApplicantPhones].phone_number
  from [ApplicantPhones]
  where [ApplicantPhones].phone_number in (select distinct phone_number from @phones_with_applicant a)
  --select * from @applicant_with_phones

  -- выбрать главного id с [ApplicantPhones]
  declare @main_appl_phone_id int=
  (select top 1 Id from [ApplicantPhones] where applicant_id=@true_applicant_id and phone_number=@phone order by Id)


  ----добавляется запись в [ApplicantDublicateHistory], то что обновляется+ те, что отображаются
  
  insert into [ApplicantDublicateHistory]
  (
  [phone_number]
      ,[applicant_id]
      ,[full_name]
      ,[live_address]
      ,[birth_date]
      ,[birth_year]
      ,[social_state_id]
      ,[category_type_id]
      ,[true_applicant_id]
      ,[user_done_id]
      ,[done_date]
  )

  select ap.phone_number, ap.applicant_Id, a.full_name, a.ApplicantAdress, a.birth_date, a.birth_year, 
  a.social_state_id, a.category_type_id, @true_applicant_id, @user_Id, GETUTCDATE()
  from @applicant_with_phones ap
  inner join [Applicants] a on ap.applicant_Id=a.Id
  union all
  select null, ap.applicant_Id, null, 
  isnull([Districts].name+N' р-н, ', N'')+isnull([StreetTypes].shortname, N'')+isnull(Streets.name+N' ', N'')+isnull(Buildings.name, N''),
  null, null, null, null, @true_applicant_id, @user_Id, GETUTCDATE()

  from (select distinct applicant_Id from @applicant_with_phones) ap
  inner join [LiveAddress] on ap.applicant_Id=[LiveAddress].applicant_id
  left join [Buildings] on [LiveAddress].building_id=[Buildings].Id
  left join [Districts] on [Buildings].district_id=[Districts].Id
  left join [Streets] on [Buildings].street_id=[Streets].Id
  left join [StreetTypes] on [Streets].street_type_id=[StreetTypes].Id


  -- обновить Appeals на главного. нужно ли здесь обновлять номер телефона?
  /**/
  update [Appeals]
  set applicant_id=@true_applicant_id
  where applicant_id in (select distinct applicant_id from @applicant_with_phones a)
  

  -- обновить [ApplicantPhones] на главного заявителя и признак главного/не главного
  /**/
  update [ApplicantPhones]
  set applicant_id=@main_appl_phone_id
  ,IsMain=case when Id=@main_appl_phone_id then 'true' else 'false' end
  where Id in (select Id from @applicant_with_phones a )
  

  --табличка данных, которые нужно удалить и записать в хистори ЗАКОМЕНТИЛ, НИЧЕГО НЕ УДАЛЯЮ
  /**/
  declare @delete_phone table (Id int, applicant_id int, phone nvarchar(50));

insert into @delete_phone (Id, applicant_id, phone)
select ap.Id, ap.applicant_id, ap.phone_number
from [ApplicantPhones] ap
where ap.applicant_id=@true_applicant_id
and ap.Id not in
(select min(Id) --min_Id
from [ApplicantPhones]
where applicant_id=@true_applicant_id
group by applicant_id, phone_number)


-----/*LiveAdress*/

--основная Id LiveAdress

declare @live_address_main_Id int=
  (
  select top 1 Id
  from [LiveAddress]
  where applicant_id=@true_applicant_id and main='true') 


-- обновить applicant_id на главного и проставить им не главные

/**/
update [LiveAddress]
set applicant_id=@true_applicant_id
,main='false'
where applicant_id in (select distinct applicant_id from @applicant_with_phones a)


-- то что нужно удалить с LiveAddress ЗАКОМЕНТИЛ, НИЧЕГО НЕ УДАЛЯЮ
/**/
declare @delete_LiveAddress table (Id int, applicant_id int, building_id int, house_block nvarchar(50), entrance int, flat nvarchar(50))
  
  insert into @delete_LiveAddress (Id, applicant_id, building_id, house_block, entrance, flat)
  select Id, applicant_id, building_id, house_block, entrance, flat
  from [LiveAddress]
  where applicant_id=@true_applicant_id
  and id not in
  (select min(Id) min_Id
  from [LiveAddress]
  where applicant_id=@true_applicant_id
  group by applicant_id)

--удалить с телефонов не нужные
/**/
delete 
from [ApplicantPhones]
where Id in (select Id from @delete_phone)

-- удаление с LiveAddress
/**/
delete 
from LiveAddress
where Id=(select Id from @delete_LiveAddress)
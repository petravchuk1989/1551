-- declare @applicant_id int = 3677
-- declare @appeal_id int = 5389980
-- declare @phone_number nvarchar(25) = N'0993896537'


declare @LoadServerState int 

set @LoadServerState = (
                         SELECT TOP (1) [LoadServer].[StateId]
                         FROM [dbo].[LoadServer]
                         order by [LoadServer].[Id] desc
                        )




if(OBJECT_ID('tempdb..#tempTypeQuestion') is not null) begin drop table #tempTypeQuestion end
create table #tempTypeQuestion (
Id int identity(1,1),
[Тип] nvarchar(100),
[Зареєстровано] int,
[В роботі] int,
[Просрочено] int,
[Виконано] int,
[Доопрацювання] int
)



if @LoadServerState = 1
begin

insert into #tempTypeQuestion ([Тип], [Зареєстровано], [В роботі], [Просрочено], [Виконано], [Доопрацювання])
    select N'питання заявника' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'питання заявника (old)' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'консультації заявника' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'питання за помешканням заявника' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'питання з номеру телефону заявника' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'питання по будинку' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'заявки за Городком' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]




update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'Зареєстровано')
												),
							 [В роботі] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'В роботі', N'На перевірці')
												),
							 [Просрочено] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [Questions].[control_date] <= getutcdate()
												and [QuestionStates].[name] not in (N'Закрито')
												),
							 [Виконано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'Закрито')
												),
							 [Доопрацювання] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'Не виконано')
												)
where [Тип] = N'питання заявника'



update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [Consultations] 
												left join [dbo].[Questions] on [Consultations].question_id  = [Questions].Id
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Consultations].appeal_id = @appeal_id and [Consultations].phone_number = @phone_number
												)
where [Тип] = N'консультації заявника'


update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].phone_number in (select [ApplicantPhones].phone_number from [dbo].[ApplicantPhones] where [ApplicantPhones].phone_number = @phone_number)
												and [QuestionStates].[name] in (N'Зареєстровано')
												),
							 [В роботі] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].phone_number in (select [ApplicantPhones].phone_number from [dbo].[ApplicantPhones] where [ApplicantPhones].phone_number = @phone_number)
												and [QuestionStates].[name] in (N'В роботі', N'На перевірці')
												),
							 [Просрочено] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].phone_number in (select [ApplicantPhones].phone_number from [dbo].[ApplicantPhones] where [ApplicantPhones].phone_number = @phone_number)
												and [Questions].[control_date] <= getutcdate()
												and [QuestionStates].[name] not in (N'Закрито')
												),
							 [Виконано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].phone_number in (select [ApplicantPhones].phone_number from [dbo].[ApplicantPhones] where [ApplicantPhones].phone_number = @phone_number)
												and [QuestionStates].[name] in (N'Закрито')
												),
							 [Доопрацювання] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[ApplicantPhones] on [ApplicantPhones].applicant_id = [Applicants].id
												where [Appeals].phone_number in (select [ApplicantPhones].phone_number from [dbo].[ApplicantPhones] where [ApplicantPhones].phone_number = @phone_number)
												and [QuestionStates].[name] in (N'Не виконано')
												)
where [Тип] = N'питання з номеру телефону заявника'


update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where [Questions].[object_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'Зареєстровано')
												),
							 [В роботі] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where [Questions].[object_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'В роботі', N'На перевірці')
												),
							 [Просрочено] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where [Questions].[object_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [Questions].[control_date] <= getutcdate()
												and [QuestionStates].[name] not in (N'Закрито')
												),
							 [Виконано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where [Questions].[object_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'Закрито')
												),
							 [Доопрацювання] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where [Questions].[object_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'Не виконано')
												)
where [Тип] = N'питання по будинку'


update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) in (select rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'Зареєстровано')
												),
							 [В роботі] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) in (select rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'В роботі', N'На перевірці')
												),
							 [Просрочено] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) in (select rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [Questions].[control_date] <= getutcdate()
												and [QuestionStates].[name] not in (N'Закрито')
												),
							 [Виконано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) in (select rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'Закрито')
												),
							 [Доопрацювання] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												left join [dbo].[LiveAddress] on [LiveAddress].applicant_id = [Applicants].Id
												where rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) in (select rtrim([LiveAddress].building_id)+N'/'+rtrim([LiveAddress].flat) from [dbo].[LiveAddress] where [LiveAddress].applicant_id = @applicant_id)
												and [QuestionStates].[name] in (N'Не виконано')
												)
where [Тип] = N'питання за помешканням заявника'


update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] in (N'Зареєстровано'))
												),
							 [В роботі] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] in (N'В роботі', N'На перевірці'))
												),
							 [Просрочено] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] not in (N'Закрито'))
												and [Lokal_copy_gorodok_claims].[plan_finish_date] <= getutcdate()
												),
							 [Виконано] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] in (N'Закрито'))
												)
where [Тип] = N'заявки за Городком'

end




if @LoadServerState = 2
begin

insert into #tempTypeQuestion ([Тип], [Зареєстровано], [В роботі], [Просрочено], [Виконано], [Доопрацювання])
    select N'питання заявника' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'питання заявника (old)' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]
    union all
    select N'заявки за Городком' as [Тип], 0 as [З], 0 as [Р], 0 as [П], 0 as [В], 0 as [Д]




update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'Зареєстровано')
												),
							 [В роботі] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'В роботі', N'На перевірці')
												),
							 [Просрочено] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [Questions].[control_date] <= getutcdate()
												and [QuestionStates].[name] not in (N'Закрито')
												),
							 [Виконано] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'Закрито')
												),
							 [Доопрацювання] = (select count(1)
												FROM [dbo].[Questions]
												left join [dbo].[Appeals] on [Appeals].Id = [Questions].appeal_id
												left join [dbo].[Applicants] on [Applicants].Id = [Appeals].applicant_id
												left join [dbo].[QuestionStates] on [QuestionStates].Id = [Questions].question_state_id
												where [Appeals].applicant_id = @applicant_id
												and [QuestionStates].[name] in (N'Не виконано')
												)
where [Тип] = N'питання заявника'



update #tempTypeQuestion set [Зареєстровано] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] in (N'Зареєстровано'))
												),
							 [В роботі] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] in (N'В роботі', N'На перевірці'))
												),
							 [Просрочено] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] not in (N'Закрито'))
												and [Lokal_copy_gorodok_claims].[plan_finish_date] <= getutcdate()
												),
							 [Виконано] = (select count(1)
												FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses]
												  left join[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_claims] on [Lokal_copy_gorodok_claims].[object_id] =  [Gorodok_1551_houses].gorodok_houses_id
												  left join [CRM_1551_GORODOK_Integrartion].[dbo].Claims_states on Claims_states.[name] = [Lokal_copy_gorodok_claims].[status]
												where [Gorodok_1551_houses].[1551_houses_id] in (select [LiveAddress].building_id from [dbo].[LiveAddress] where building_id is not null and [LiveAddress].applicant_id = @applicant_id)
												and Claims_states.[1551_state] in (select [QuestionStates].Id from [QuestionStates] where [QuestionStates].[name] in (N'Закрито'))
												)
where [Тип] = N'заявки за Городком'

end

/*
Id	name
1	Зареєстровано
2	В роботі
3	На перевірці
4	Не виконано
5	Закрито
*/

select * 
from #tempTypeQuestion
where
	#filter_columns#
--     #sort_columns#
--offset @pageOffsetRows rows fetch next @pageLimitRows rows only

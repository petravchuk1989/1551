if OBJECT_ID('tempdb..#temp_district_person') is not null drop table #temp_district_person


  select case when len([Districts].Id)=2 then N'00' else N'0' end+ltrim([Districts].Id)+ltrim([PersonExecutorChoose].Id) Id, [Districts].Id district_id, [PersonExecutorChoose].Id [person_executor_choose_id]
  into #temp_district_person 
  from [dbo].[Districts],
  [dbo].[PersonExecutorChoose]
  
 
select temp_d_person.Id, 
 [PersonExecutorChoose].Id person_executor_choose_id, [PersonExecutorChoose].name person_executor_choose_name,
  [PersonExecutorChooseObjects].district_id, 
  [PersonExecutorChooseObjects].district_name
from [dbo].[PersonExecutorChoose]
  inner join (select distinct person_executor_choose_id, 
  [Districts].Id district_id, [Districts].name district_name
  from [dbo].[PersonExecutorChooseObjects] 
  inner join [dbo].[Objects] on [PersonExecutorChooseObjects].object_id=[Objects].Id
  inner join [dbo].[Districts] on [Objects].district_id=[Districts].Id) [PersonExecutorChooseObjects] on [PersonExecutorChoose].Id=[PersonExecutorChooseObjects].person_executor_choose_id
  inner join #temp_district_person temp_d_person on [PersonExecutorChooseObjects].person_executor_choose_id=temp_d_person.person_executor_choose_id and [PersonExecutorChooseObjects].district_id=temp_d_person.district_id

where temp_d_person.Id=@Id
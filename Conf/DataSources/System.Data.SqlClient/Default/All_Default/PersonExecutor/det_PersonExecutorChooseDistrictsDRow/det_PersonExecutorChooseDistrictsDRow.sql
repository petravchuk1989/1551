if OBJECT_ID('tempdb..#temp_district_person') is not null drop table #temp_district_person


  select case when len([Districts].Id)=2 then N'00' else N'0' end+ltrim([Districts].Id)+ltrim([PersonExecutorChoose].Id) Id, [Districts].Id district_id, [PersonExecutorChoose].Id [person_executor_choose_id]
  into #temp_district_person 
  from [dbo].[Districts],
  [dbo].[PersonExecutorChoose]


delete
from [PersonExecutorChooseObjects]
where id in (
 select [PersonExecutorChooseObjects].Id
 from #temp_district_person temp_d_person
 inner join [dbo].[PersonExecutorChooseObjects] on temp_d_person.person_executor_choose_id=[PersonExecutorChooseObjects].person_executor_choose_id
 inner join [dbo].[Objects] on [PersonExecutorChooseObjects].object_id=[Objects].Id and temp_d_person.district_id=[Objects].district_id
 where temp_d_person.Id=@Id)
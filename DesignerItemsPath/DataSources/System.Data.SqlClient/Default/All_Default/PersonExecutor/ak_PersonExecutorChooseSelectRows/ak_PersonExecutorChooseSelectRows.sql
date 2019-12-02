
select Id, Organization_name, Positions_name, PersonExecutorChoose_name, questions_types, [objects]

from(
select p.Id, [Organizations].short_name Organization_name, p.name PersonExecutorChoose_name, [Positions].name Positions_name,
  --count([PersonExecutorChooseQT].Id) count_qt, 
  --count([PersonExecutorChooseObjects].Id) count_object
/*
  ,stuff((select N', '+isnull([Objects].name,N'')
  from [PersonExecutorChooseObjects]
  inner join [Objects] on [PersonExecutorChooseObjects].object_id=[Objects].Id
  where [PersonExecutorChooseObjects].Id=p.Id
  for xml path ('')), 1,2, N'') all_objcts

  ,stuff((select N', '+[QuestionTypes].name
  from [PersonExecutorChooseQT]
  inner join [QuestionTypes] on [PersonExecutorChooseQT].question_type_id=[QuestionTypes].Id
  where [PersonExecutorChooseQT].person_executor_choose_id=p.Id
*/
  N'Типів '+ltrim(count([PersonExecutorChooseQT].Id))+N':'+stuff((select N', '+[QuestionTypes].name
  from [PersonExecutorChooseQT]
  inner join [QuestionTypes] on [PersonExecutorChooseQT].question_type_id=[QuestionTypes].Id
  where [PersonExecutorChooseQT].person_executor_choose_id=p.Id
  for xml path('')),1,2,N'') questions_types

  ,N'Об`єктів '+ltrim(count([PersonExecutorChooseObjects].Id))+N':'+stuff((select N', '+isnull([Objects].name,N'')
  from [PersonExecutorChooseObjects]
  inner join [Objects] on [PersonExecutorChooseObjects].object_id=[Objects].Id
  where [PersonExecutorChooseObjects].Id=p.Id
  for xml path ('')), 1,2, N'') [objects]

  from [PersonExecutorChoose] p
  left join [Organizations] on p.organization_id=[Organizations].Id
  left join [Positions] on p.position_id=[Positions].Id
  left join [PersonExecutorChooseQT] on p.Id=[PersonExecutorChooseQT].person_executor_choose_id
  left join [PersonExecutorChooseObjects] on p.Id=[PersonExecutorChooseObjects].person_executor_choose_id
  group by p.Id, [Organizations].short_name , p.name , [Positions].name
) t
where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only

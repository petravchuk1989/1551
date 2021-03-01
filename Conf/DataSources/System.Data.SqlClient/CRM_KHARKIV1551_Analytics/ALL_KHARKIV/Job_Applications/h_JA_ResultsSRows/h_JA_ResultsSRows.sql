select Id, Name
  from [CRM_1551_Analitics].[dbo].[AssignmentResults]
  where id in (4 /*Виконано*/, 9 /*Прийнято в роботу*/)
and #filter_columns#
  --#sort_columns#
order by 1
offset @pageOffsetRows rows fetch next @pageLimitRows rows only

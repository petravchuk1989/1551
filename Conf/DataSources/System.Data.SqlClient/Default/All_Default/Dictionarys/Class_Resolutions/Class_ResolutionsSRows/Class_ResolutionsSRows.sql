select cr.Id, ac.[name] assignment_class_name, cr.[name]
  from [dbo].[Class_Resolutions] cr
  left join [dbo].[Assignment_Classes] ac on cr.assignment_class_id=ac.Id --[class_id]
  where 
  #filter_columns#
  --#sort_columns#
  order by 1
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
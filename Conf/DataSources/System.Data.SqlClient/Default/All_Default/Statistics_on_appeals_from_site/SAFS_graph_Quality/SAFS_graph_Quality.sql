select row_number() over(order by [indicator_name]) Id, [indicator_name], sum([indicator_value]) [indicator_value]
  from [CRM_1551_Site_Integration].[dbo].[Statistic]
  where diagram=8 and date between convert(date, @date_from) and convert(date, @date_to)
  group by [indicator_name]
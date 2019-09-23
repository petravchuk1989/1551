SELECT [gg].claim_number as [Id] -- № заходу +
	  ,gg.claims_type as event_type_name -- Тип заходу
	--   ,gg.claims_type as event_class_name -- Клас заходу +
	  ,gg.object_name -- Об'єкт
	  ,gg.executor as executor_name -- Виконавець
	  ,gg.registration_date  as start_date -- Дата початку
	  ,gg.fact_finish_date as real_end_date -- Факт.завершення
  FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_global] as gg

	where #filter_columns#
     #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
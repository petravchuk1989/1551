SELECT [gg].claim_number AS [Id] -- № заходу +
	  , gg.claims_type AS event_type_name -- Тип заходу
	--   ,gg.claims_type as event_class_name -- Клас заходу +
	  , gg.object_name -- Об'єкт
	  , gg.executor AS executor_name -- Виконавець
	  , gg.registration_date -- Дата початку
	  , gg.fact_finish_date AS real_end_date-- Факт.завершення
      ,gg.[executor_comment]
      ,gg.plan_finish_date
FROM [CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_global] AS gg

WHERE claim_number = @Id
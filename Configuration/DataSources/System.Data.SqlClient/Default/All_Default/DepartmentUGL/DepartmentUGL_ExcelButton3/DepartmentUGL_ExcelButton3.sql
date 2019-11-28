  insert into [Звернення УГЛ]
  (
  [Джерело]
      ,[Пріоритет]
      ,[№ звернення]
      ,[Статус]
      ,[Підстатус]
      ,[Створено]
      ,[Виконавці]
      ,[Питання]
      ,[Зміст]
      ,[Файли]
      ,[Територіальна одиниця]
      ,[Змінено]
      ,[Відправлено]
      ,[За особливою умовою]
      ,[За суб’єктом]
      ,[Заявник]
      ,[Тип заявника]
      ,[Стать]
      ,[Адреса]
      ,[Телефон]
      ,[E-mail]
      ,[Соціальний стан]
      ,[Категорія]
      ,[Дата народження]
      ,[Код ЄДРПОУ/ІНН]
      ,[Форма власності]
      ,[Контактна особа]
      ,[Автор]
      ,[Закрито]
      ,[Вирішити до]
      ,[Дата відповіді]
      ,[Відповідь надано]
      ,[Вихідний номер]
      ,[Потребує дзвінка]
      ,[Результат зворотного зв’язку]
      ,[Планова дата зворотнього зв’язку]
      ,[Виконавець зворотнього зв’язку]
      ,[Прийнято]
      ,[Коментарі]
      ,[Завантажив]
      ,[Дата завантаження]
      ,[Опрацьовано]
      ,[Опрацював]
      ,[Дата опрацювання]
  )


  select [УГЛ].[Джерело]
      ,[УГЛ].[Пріоритет]
      ,[УГЛ].[№ звернення]
      ,[УГЛ].[Статус]
      ,[УГЛ].[Підстатус]
      ,[УГЛ].[Створено]
      ,[УГЛ].[Виконавці]
      ,[УГЛ].[Питання]
      ,[УГЛ].[Зміст]
      ,[УГЛ].[Файли]
      ,[УГЛ].[Територіальна одиниця]
      ,[УГЛ].[Змінено]
      ,[УГЛ].[Відправлено]
      ,[УГЛ].[За особливою умовою]
      ,[УГЛ].[За суб’єктом]
      ,[УГЛ].[Заявник]
      ,[УГЛ].[Тип заявника]
      ,[УГЛ].[Стать]
      ,[УГЛ].[Адреса]
      ,[УГЛ].[Телефон]
      ,[УГЛ].[E-mail]
      ,[УГЛ].[Соціальний стан]
      ,[УГЛ].[Категорія]
      ,[УГЛ].[Дата народження]
      ,[УГЛ].[Код ЄДРПОУ/ІНН]
      ,[УГЛ].[Форма власності]
      ,[УГЛ].[Контактна особа]
      ,[УГЛ].[Автор]
      ,[УГЛ].[Закрито]
      ,[УГЛ].[Вирішити до]
      ,[УГЛ].[Дата відповіді]
      ,[УГЛ].[Відповідь надано]
      ,[УГЛ].[Вихідний номер]
      ,[УГЛ].[Потребує дзвінка]
      ,[УГЛ].[Результат зворотного зв’язку]
      ,[УГЛ].[Планова дата зворотнього зв’язку]
      ,[УГЛ].[Виконавець зворотнього зв’язку]
      ,[УГЛ].[Прийнято]
      ,[УГЛ].[Коментарі]
	  ,@user_id
      ,GETUTCDATE()
      ,0--[Опрацьовано]
      ,null--[Опрацював]
      ,null--[Дата опрацювання]
  FROM [УГЛ]
  left join [Звернення УГЛ] on [УГЛ].[№ звернення]=[Звернення УГЛ].[№ звернення]
  where [Звернення УГЛ].[№ звернення] is null



  delete 
  from  [УГЛ]


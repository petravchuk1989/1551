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


  select [Джерело]
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
	  
	  ,@user_id
      ,GETDATE()
      ,null--[Опрацьовано]
      ,null--[Опрацював]
      ,null--[Дата опрацювання]
  FROM [CRM_1551_Analitics].[dbo].[УГЛ]
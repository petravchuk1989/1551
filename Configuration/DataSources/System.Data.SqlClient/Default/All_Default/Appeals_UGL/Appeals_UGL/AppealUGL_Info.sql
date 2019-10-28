-- declare @Id int = 15379
select top 1
[№ звернення] as incomNum, 

IIF(
charindex(',', a.Телефон) > 0, 
(substring(a.Телефон, 1, 10)),
a.Телефон 
)  as phone,
a.Телефон as full_phone,
convert(varchar, a.[Дата завантаження],(120)) as incomDate,
a.Заявник as Applicant_PIB,
a.Зміст as Question_Content, 
a.Заявник +
  + CHAR(13) +
 case when a.Адреса is not null then 
 'Адреса: ' + a.Адреса else '' end
  + CHAR(13) + 
  case when a.[E-mail] is not null then 
  a.[E-mail] else '' end 
  + case when a.[Соціальний стан] is not null and a.[E-mail] is not null then 
   ', Соц. стан: ' + a.[Соціальний стан] 
         when a.[Соціальний стан] is not null and a.[E-mail] is null then 
		 'Соц. стан: ' +a.[Соціальний стан] else '' end +
   case when a.Категорія is not null and a.[Соціальний стан] is not null then 
   ( ', ' + 'Категорія: ' + a.Категорія) 
   when a.Категорія is not null and a.[Соціальний стан] is null then
   ('Категорія: ' + a.Категорія) else '' end + 
   case when a.[Дата народження] is not null and a.Категорія is not null then 
  ', ' + cast(a.[Дата народження] as varchar) 
  when a.[Дата народження] is not null and a.Категорія is null then
  cast(a.[Дата народження] as varchar)  else '' end
 as ApplicantUGL

from dbo.[Звернення УГЛ] a
where a.Id = @Id 
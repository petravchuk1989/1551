/*declare @dateFrom date;
declare @dateTo date;
declare @user_id nvarchar(128);
declare @is_worked bit;
*/
select [№ звернення] [Вихідний номер УГЛ], [Створено] [Дата реєстрації], [Заявник], [Адреса], [Зміст]
from [Звернення УГЛ]
where convert(date, [Створено]) between convert(date, @dateFrom) and convert(date, @dateTo)
and [Опрацював]=@user_id
and [Опрацьовано]=@is_worked
/*declare @dateFrom date;
declare @dateTo date;
declare @user_id nvarchar(128);
declare @is_worked bit;
*/
select [№ звернення] [EnterNumber], [Створено] [RegistrationDate], [Заявник] [Applicant], [Адреса] [Address], [Зміст] [Content], [Питання] QuestionNumber
from [Звернення УГЛ]
where convert(date, [Створено]) between @dateFrom and @dateTo
and #filter_columns# /*[Опрацював]=@user_id*/
and ([Опрацьовано]= case when @is_worked is null then 'true' else @is_worked end or 
[Опрацьовано]= case when @is_worked is null then 'false' else @is_worked end)
-- declare @dateFrom DATETIME = '2019-05-31T21:00:00.000Z';
-- declare @dateTo DATE = '2020-02-20T12:03:00.000Z';
-- declare @user_id NVARCHAR(128) = N'Вася';
-- declare @is_worked BIT = 'true';
-- declare @uploaded NVARCHAR(MAX) = N 'N''Вася'',N''Степа''';
-- declare @processed NVARCHAR(MAX) = N 'N''Вася'',N''Степа''';

DECLARE @zoneVal SMALLINT = DATEPART(TZOffset, SYSDATETIMEOFFSET());
SET @dateTo = DATEADD(MINUTE,@zoneVal,@dateTo);
SELECT
	Z.[Id],
	Z.[№ звернення] [EnterNumber],
	Z.[Створено] [RegistrationDate],
	Z.[Заявник] [Applicant],
	Z.[Адреса] [Address],
	Z.[Зміст] [Content],
	--,Z.[Питання] QuestionNumber,
	q.[registration_number] QuestionNumber,
	Z.[Завантажив] [Uploaded],
	Z.[Опрацював] [Processed],
	q.[control_date] [ControlDate],
	qstate.[name] [QuestionState]
FROM
	[dbo].[Звернення УГЛ] z
	LEFT JOIN [dbo].[Questions] q ON Z.Appeals_id = q.appeal_id
	LEFT JOIN [dbo].[QuestionStates] qstate ON q.question_state_id = qstate.Id
WHERE
	Z.[Створено] BETWEEN @dateFrom
	AND @dateTo
	AND CASE
		WHEN @is_worked IS NULL THEN 'true'
		ELSE Z.[Опрацьовано]
	END = ISNULL(@is_worked, 'true')
	AND #filter_columns#
		#sort_columns#
	OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
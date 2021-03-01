-- DECLARE @userId NVARCHAR(128) = N'eb6d56d2-e217-45e4-800b-c851666ce795';
-- DECLARE @orgId INT = NULL;

DECLARE @user_position TABLE (Id INT);
INSERT INTO @user_position
SELECT 
	[Id]
FROM dbo.Positions 
WHERE [programuser_id] = @userId;

DECLARE @InUserResponseRights TABLE (Id INT);
INSERT INTO @InUserResponseRights
SELECT 
DISTINCT 
	[organization_id]
FROM [dbo].[OrganizationInResponsibilityRights]
WHERE [position_id] IN (SELECT [Id] FROM @user_position);

DECLARE @user_orgs TABLE (Id INT, short_name NVARCHAR(500));
DECLARE @now DATETIME = GETUTCDATE();

IF (@orgId IS NULL)
BEGIN
	INSERT INTO @user_orgs
	SELECT 
	DISTINCT 
		o.[Id],
		o.[short_name]
	FROM [dbo].[OrganizationInResponsibilityRights] org_r
	INNER JOIN [dbo].[Organizations] o ON o.Id = org_r.organization_id
	WHERE [position_id] IN (SELECT Id FROM @user_position);
END
ELSE 
BEGIN
	IF(@orgId NOT IN (SELECT [Id] FROM @InUserResponseRights))
	BEGIN
		RAISERROR(N'Користувач не має доступу до даної організації', 16, 1);
		RETURN;
	END
	INSERT INTO @user_orgs
	SELECT 
		@orgId,
		short_name
	FROM dbo.[Organizations] 
	WHERE [Id] = @orgId;
END

-- Надійшло
DECLARE @new_assignment TABLE (org_id INT, val INT);
INSERT INTO @new_assignment
SELECT 
	org.[Id],
	COUNT(ass.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[Assignments] ass ON ass.[executor_organization_id] = org.[Id]
	AND ass.[assignment_state_id] = 1 
	AND ass.[executor_organization_id] IN (SELECT [Id] FROM @user_orgs)
	GROUP BY org.[Id];

-- В роботі Доручень 
DECLARE @in_work_assignment TABLE (org_id INT, val INT);
INSERT INTO @in_work_assignment
SELECT 
	org.[Id],
	COUNT(ass.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[Assignments] ass ON ass.[executor_organization_id] = org.[Id]
	AND ass.[assignment_state_id] = 2 
	AND ass.[executor_organization_id] IN (SELECT [Id] FROM @user_orgs)
	GROUP BY org.[Id];

-- В роботі Заходів  
DECLARE @in_work_event TABLE (org_id INT, val INT);
INSERT INTO @in_work_event
SELECT 
	org.[Id],
	COUNT(e.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[EventOrganizers] eo ON eo.[organization_id] = org.[Id]
	AND eo.[organization_id] IN (SELECT [Id] FROM @user_orgs)
INNER JOIN dbo.[Events] e ON e.[Id] = eo.[event_id]
	AND e.[active] = 1 
	AND e.[start_date] < @now 
	AND e.[plan_end_date] > @now 
	GROUP BY org.[Id];

-- Прострочено Доручень 
DECLARE @overdue_assignment TABLE (org_id INT, val INT);
INSERT INTO @overdue_assignment
SELECT 
	org.[Id],
	COUNT(ass.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[Assignments] ass ON ass.[executor_organization_id] = org.[Id]
	AND ass.[assignment_state_id] IN (1,2) 
	AND ass.[executor_organization_id] IN (SELECT [Id] FROM @user_orgs)
INNER JOIN dbo.[Questions] q ON q.[Id] = ass.[question_id]
	AND q.[control_date] < @now 
	GROUP BY org.[Id];

-- Прострочено Заходів   
DECLARE @overdue_event TABLE (org_id INT, val INT);
INSERT INTO @overdue_event
SELECT 
	org.[Id],
	COUNT(e.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[EventOrganizers] eo ON eo.[organization_id] = org.[Id]
	AND eo.[organization_id] IN (SELECT [Id] FROM @user_orgs)
INNER JOIN dbo.[Events] e ON e.[Id] = eo.[event_id]
	AND e.[active] = 1 
	AND e.[plan_end_date] < @now 
	GROUP BY org.[Id];

-- Увага Доручень 
DECLARE @attention_assignment TABLE (org_id INT, val INT);
INSERT INTO @attention_assignment
SELECT 
	org.[Id],
	COUNT(ass.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[Assignments] ass ON ass.[executor_organization_id] = org.[Id]
	AND ass.[assignment_state_id] IN (1,2) 
	AND ass.[executor_organization_id] IN (SELECT [Id] FROM @user_orgs)
INNER JOIN dbo.[Questions] q ON q.[Id] = ass.[question_id]
	AND q.[control_date] < @now 
	--> до дати контролю залишився 1 день
	AND (CAST(DATEADD(DAY, 1, q.[control_date]) AS DATE) = CAST(q.[control_date] AS DATE) 
	--> залишилося 1/5 часу від дати реєстрації до дати контролю
	OR DATEDIFF(HOUR, q.[registration_date], q.[control_date]) / 5 
	<=  DATEDIFF(HOUR, @now, q.[control_date]) )
	GROUP BY org.[Id];

-- Увага Заходів  
DECLARE @attention_event TABLE (org_id INT, val INT);
INSERT INTO @attention_event
SELECT 
	org.[Id],
	COUNT(e.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[EventOrganizers] eo ON eo.[organization_id] = org.[Id]
	AND eo.[organization_id] IN (SELECT [Id] FROM @user_orgs)
INNER JOIN dbo.[Events] e ON e.[Id] = eo.[event_id]
	AND e.[active] = 1 
	AND e.[start_date] < @now 
	--> до планового завершення залишився 1 день
	AND (CAST(DATEADD(DAY, 1, e.[plan_end_date]) AS DATE) = CAST(e.[plan_end_date] AS DATE) 
	--> залишилося 1/5 часу від дати реєстрації до планового завершення
	OR DATEDIFF(HOUR, e.[plan_end_date], e.[plan_end_date]) / 5 
	<=  DATEDIFF(HOUR, @now, e.[plan_end_date]) )
	GROUP BY org.[Id];

-- Повернені куратором 
DECLARE @curatorreturn_assignment TABLE (org_id INT, val INT);
INSERT INTO @curatorreturn_assignment
SELECT 
	org.[Id],
	COUNT(ass.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[Assignments] ass ON ass.[executor_organization_id] = org.[Id]
	AND ass.[assignment_state_id] = 4
	AND ass.[AssignmentResultsId] = 5
	AND ass.[AssignmentResolutionsId] = 7
	AND ass.[executor_organization_id] IN (SELECT [Id] FROM @user_orgs)
	GROUP BY org.[Id];

-- Повернені куратором 
DECLARE @applicantreturn_assignment TABLE (org_id INT, val INT);
INSERT INTO @applicantreturn_assignment
SELECT 
	org.[Id],
	COUNT(ass.[Id])
FROM dbo.[Organizations] org
INNER JOIN dbo.[Assignments] ass ON ass.[executor_organization_id] = org.[Id]
	AND ass.[assignment_state_id] = 4
	AND ass.[AssignmentResultsId] = 5
	AND ass.[AssignmentResolutionsId] = 8
	AND ass.[executor_organization_id] IN (SELECT [Id] FROM @user_orgs)
	GROUP BY org.[Id];


DECLARE @RootVal TABLE (Id INT,
						short_name NVARCHAR(500),
						new_assignemnt INT,
						in_work_assignment INT,
						in_work_event INT,
						overdue_assignment INT,
						overdue_event INT,
						attention_assignment INT,
						attention_event INT,
						curatorreturn_assignment INT,
						applicantreturn_assignment INT);

IF OBJECT_ID('tempdb..#ResultVal') IS NOT NULL
BEGIN
	DROP TABLE #ResultVal;
END
CREATE TABLE #ResultVal (Id INT,
						short_name NVARCHAR(500),
						new_assignment INT,
						in_work_assignment INT,
						in_work_event INT,
						overdue_assignment INT,
						overdue_event INT,
						attention_assignment INT,
						attention_event INT,
						curatorreturn_assignment INT,
						applicantreturn_assignment INT);

IF (@orgId IS NULL)
BEGIN
INSERT INTO @RootVal
SELECT 
DISTINCT
	NULL AS organization_id,
	NULL AS short_name,
	SUM(ISNULL(na.[val],0)) AS new_assignment,
	SUM(ISNULL(iwa.[val],0)) AS in_work_assignment,
	SUM(ISNULL(iwe.[val],0)) AS in_work_event,
	SUM(ISNULL(oa.[val],0)) AS overdue_assignment,
	SUM(ISNULL(oe.[val],0)) AS overdue_event,
	SUM(ISNULL(aa.[val],0)) AS attention_assignment,
	SUM(ISNULL(ae.[val],0)) AS attention_event,
	SUM(ISNULL(cra.[val],0)) AS curatorreturn_assignment,
	SUM(ISNULL(ara.[val],0)) AS applicantreturn_assignment
FROM @user_orgs uo 
LEFT JOIN @new_assignment na ON na.[org_id] = uo.[Id]
LEFT JOIN @in_work_assignment iwa ON iwa.[org_id] = uo.[Id]
LEFT JOIN @in_work_event iwe ON iwe.[org_id] = uo.[Id]
LEFT JOIN @overdue_assignment oa ON oa.[org_id] = uo.[Id]
LEFT JOIN @overdue_event oe ON oe.[org_id] = uo.[Id]
LEFT JOIN @attention_assignment aa ON aa.[org_id] = uo.[Id]
LEFT JOIN @attention_event ae ON ae.[org_id] = uo.[Id]
LEFT JOIN @curatorreturn_assignment cra ON cra.[org_id] = uo.[Id]
LEFT JOIN @applicantreturn_assignment ara ON ara.[org_id] = uo.[Id];

INSERT INTO #ResultVal
SELECT 
DISTINCT
	uo.Id AS organization_id,
	uo.short_name,
	ISNULL(na.[val],0) AS new_assignment,
	ISNULL(iwa.[val],0) AS in_work_assignment,
	ISNULL(iwe.[val],0) AS in_work_event,
	ISNULL(oa.[val],0) AS overdue_assignment,
	ISNULL(oe.[val],0) AS overdue_event,
	ISNULL(aa.[val],0) AS attention_assignment,
	ISNULL(ae.[val],0) AS attention_event,
	ISNULL(cra.[val],0) AS curatorreturn_assignment,
	ISNULL(ara.[val],0) AS applicantreturn_assignment
FROM @user_orgs uo 
LEFT JOIN @new_assignment na ON na.[org_id] = uo.[Id]
LEFT JOIN @in_work_assignment iwa ON iwa.[org_id] = uo.[Id]
LEFT JOIN @in_work_event iwe ON iwe.[org_id] = uo.[Id]
LEFT JOIN @overdue_assignment oa ON oa.[org_id] = uo.[Id]
LEFT JOIN @overdue_event oe ON oe.[org_id] = uo.[Id]
LEFT JOIN @attention_assignment aa ON aa.[org_id] = uo.[Id]
LEFT JOIN @attention_event ae ON ae.[org_id] = uo.[Id]
LEFT JOIN @curatorreturn_assignment cra ON cra.[org_id] = uo.[Id]
LEFT JOIN @applicantreturn_assignment ara ON ara.[org_id] = uo.[Id]

UNION 

SELECT 
	Id,
	short_name,
	new_assignemnt,
	in_work_assignment,
	in_work_event,
	overdue_assignment,
	overdue_event,
	attention_assignment,
	attention_event,
	curatorreturn_assignment,
	applicantreturn_assignment
FROM @RootVal;

SELECT 
	Id AS organization_id,
	short_name,
	new_assignment,
	in_work_assignment,
	in_work_event,
	overdue_assignment,
	overdue_event,
	attention_assignment,
	attention_event,
	curatorreturn_assignment,
	applicantreturn_assignment
FROM #ResultVal
WHERE #filter_columns#
	  #sort_columns#
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
END 
ELSE 
BEGIN

INSERT INTO #ResultVal
SELECT 
DISTINCT
	uo.Id,
	uo.short_name,
	ISNULL(na.[val],0) AS new_assignemnt,
	ISNULL(iwa.[val],0) AS in_work_assignment,
	ISNULL(iwe.[val],0) AS in_work_event,
	ISNULL(oa.[val],0) AS overdue_assignment,
	ISNULL(oe.[val],0) AS overdue_event,
	ISNULL(aa.[val],0) AS attention_assignment,
	ISNULL(ae.[val],0) AS attention_event,
	ISNULL(cra.[val],0) AS curatorreturn_assignment,
	ISNULL(ara.[val],0) AS applicantreturn_assignment
FROM @user_orgs uo 
LEFT JOIN @new_assignment na ON na.[org_id] = uo.[Id]
LEFT JOIN @in_work_assignment iwa ON iwa.[org_id] = uo.[Id]
LEFT JOIN @in_work_event iwe ON iwe.[org_id] = uo.[Id]
LEFT JOIN @overdue_assignment oa ON oa.[org_id] = uo.[Id]
LEFT JOIN @overdue_event oe ON oe.[org_id] = uo.[Id]
LEFT JOIN @attention_assignment aa ON aa.[org_id] = uo.[Id]
LEFT JOIN @attention_event ae ON ae.[org_id] = uo.[Id]
LEFT JOIN @curatorreturn_assignment cra ON cra.[org_id] = uo.[Id]
LEFT JOIN @applicantreturn_assignment ara ON ara.[org_id] = uo.[Id];

SELECT 
	Id AS organization_id,
	short_name,
	new_assignment,
	in_work_assignment,
	in_work_event,
	overdue_assignment,
	overdue_event,
	attention_assignment,
	attention_event,
	curatorreturn_assignment,
	applicantreturn_assignment
FROM #ResultVal
WHERE #filter_columns#
	  #sort_columns#
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
END
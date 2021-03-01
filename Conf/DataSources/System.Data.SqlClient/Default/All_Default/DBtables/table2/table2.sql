--DECLARE @organization_Id INT =1762;
--DECLARE @user_id NVARCHAR(300)=N'29796543-b903-48a6-9399-4840f6eac396';

  IF EXISTS
  (SELECT orr.*
  FROM [dbo].[OrganizationInResponsibilityRights] orr
  INNER JOIN dbo.Positions p ON orr.position_id=P.Id
  WHERE orr.organization_id=@organization_Id 
  AND P.programuser_id=@user_id)

	BEGIN
		DECLARE @role NVARCHAR(500) = (SELECT
		[Roles].name
	FROM [dbo].[Positions] WITH (NOLOCK)
	LEFT JOIN [dbo].[Roles]
		ON [Positions].role_id = [Roles].Id
	WHERE [Positions].programuser_id = @user_id);

DECLARE @Organization TABLE (
	Id INT
);

DECLARE @OrganizationId INT =
CASE
	WHEN @organization_id IS NOT NULL THEN @organization_id
	ELSE (SELECT
				Id
			FROM [dbo].[Organizations] WITH (NOLOCK)
			WHERE Id IN (SELECT
					organization_id
				FROM [dbo].[Workers] WITH (NOLOCK)
				WHERE worker_user_id = @user_id))
END;


DECLARE @IdT TABLE (
	Id INT
);

-- НАХОДИМ ИД ОРГАНИЗАЦИЙ ГДЕ ИД И ПАРЕНТЫ ВЫБРАНОЙ И СРАЗУ ЗАЛИВАЕМ
INSERT INTO @IdT (Id)
	SELECT
		Id
	FROM [dbo].[Organizations] WITH (NOLOCK)
	WHERE (Id = @OrganizationId
	OR [parent_organization_id] = @OrganizationId)
	AND Id NOT IN (SELECT
			Id
		FROM @IdT);

--  НАХОДИМ ПАРЕНТЫ ОРГ, КОТОРЫХ ЗАЛИЛИ, <-- нужен цыкл
WHILE (SELECT
		COUNT(Id)
	FROM (SELECT
			Id
		FROM [dbo].[Organizations] WITH (NOLOCK)
		WHERE [parent_organization_id] IN (SELECT
				Id
			FROM @IdT) --or Id in (select Id from @IdT)
		AND Id NOT IN (SELECT
				Id
			FROM @IdT)) q)
!= 0
BEGIN

INSERT INTO @IdT
	SELECT
		Id
	FROM [dbo].[Organizations] WITH (NOLOCK)
	WHERE [parent_organization_id] IN (SELECT
			Id
		FROM @IdT) --or Id in (select Id from @IdT)
	AND Id NOT IN (SELECT
			Id
		FROM @IdT);
END

INSERT INTO @Organization (Id)
	SELECT
		Id
	FROM @IdT;



------------для плана/програми---
IF OBJECT_ID('tempdb..#temp_main_end') IS NOT NULL
			BEGIN
				DROP TABLE #temp_main_end;
			END;
			SELECT
				Id INTO #temp_main_end
			FROM [dbo].[Assignments] WITH (NOLOCK)
			WHERE assignment_state_id = 5
			AND AssignmentResultsId = 7
			AND executor_organization_id = @organization_id;


			IF OBJECT_ID('tempdb..#temp_TempAssHistory') IS NOT NULL
			BEGIN
				DROP TABLE #temp_TempAssHistory;
			END;
			SELECT
				[Assignment_History].Id id,
				[Assignment_History].assignment_id,
				[Assignment_History].AssignmentResultsId,
				[Assignment_History].assignment_state_id
			into #temp_TempAssHistory
			FROM [dbo].[Assignment_History] WITH (NOLOCK)
			WHERE [Assignment_History].assignment_id in (select Id FROM #temp_main_end);


			IF OBJECT_ID('tempdb..#temp_end_state') IS NOT NULL
			BEGIN
				DROP TABLE #temp_end_state;
			END;
			SELECT
				[Assignment_History].Id
			   ,[Assignment_History].assignment_id
			   ,[Assignment_History].assignment_state_id INTO #temp_end_state
			FROM [dbo].[Assignment_History] WITH (NOLOCK)
			INNER JOIN [dbo].[AssignmentStates]
				ON [Assignment_History].assignment_state_id = [AssignmentStates].Id
			WHERE [AssignmentStates].code = N'OnCheck'
			AND [AssignmentStates].code <> N'Closed'
			AND [Assignment_History].Id IN (SELECT MAX(id) FROM #temp_TempAssHistory WHERE assignment_state_id <> 5 GROUP BY assignment_id);

		

			IF OBJECT_ID('tempdb..#temp_end_result') IS NOT NULL
			BEGIN
				DROP TABLE #temp_end_result;
			END;
			SELECT
				[Assignment_History].Id
			   ,[Assignment_History].assignment_id
			   ,[Assignment_History].AssignmentResultsId INTO #temp_end_result
			FROM [dbo].[Assignment_History] WITH (NOLOCK)
			INNER JOIN [dbo].[AssignmentResults]
				ON [Assignment_History].AssignmentResultsId = [AssignmentResults].Id
			WHERE [AssignmentResults].code = N'ItIsNotPossibleToPerformThisPeriod'
			AND [AssignmentResults].code <> N'WasExplained '
			AND [Assignment_History].Id IN (SELECT max(id) FROM #temp_TempAssHistory WHERE AssignmentResultsId <> 7 GROUP BY assignment_id);


-----------------основное-----

IF OBJECT_ID('tempdb..#temp_navig') IS NOT NULL
BEGIN
	DROP TABLE #temp_navig;
END;

SELECT * INTO #temp_navig
FROM (SELECT
		1 Id
	   ,N'УГЛ' name
	UNION ALL
	SELECT
		2 Id
	   ,N'Електронні джерела'
	UNION ALL
	SELECT
		3 Id
	   ,N'Пріоритетне'
	UNION ALL
	SELECT
		4 Id
	   ,N'Інші доручення'
	UNION ALL
	SELECT
		5 Id
	   ,N'Зауваження') AS t;

IF OBJECT_ID('tempdb..#temp_nadiishlo') IS NOT NULL
BEGIN
	DROP TABLE #temp_nadiishlo
END;

SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_nadiishlo
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id

WHERE (([AssignmentTypes].code <> N'ToAttention'
AND [AssignmentStates].code = N'Registered'
AND [AssignmentResults].[name] = N'Очікує прийому в роботу')
OR ([AssignmentResults].code = N'ReturnedToTheArtist'
AND [AssignmentStates].code = N'Registered'))
AND [Assignments].[executor_organization_id] = @organization_id;


IF OBJECT_ID('tempdb..#temp_nevkomp') IS NOT NULL
BEGIN
	DROP TABLE #temp_nevkomp;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_nevkomp
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentConsiderations] WITH (NOLOCK)
	ON [Assignments].current_assignment_consideration_id = [AssignmentConsiderations].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id
WHERE [AssignmentTypes].code <> N'ToAttention'
AND [AssignmentStates].code <> N'Closed'
AND [AssignmentResults].code = N'NotInTheCompetence'
AND [AssignmentResolutions].name IN (N'Повернуто в 1551', N'Повернуто в батьківську організацію')
AND (CASE
	WHEN @role = N'Конролер' AND
		[AssignmentResolutions].name = N'Повернуто в 1551' THEN 1
	WHEN @role <> N'Конролер' AND
		[AssignmentResolutions].name = N'Повернуто в батьківську організацію' THEN 1
END) = 1
AND [AssignmentConsiderations].turn_organization_id = @organization_id;


IF OBJECT_ID('tempdb..#temp_prostr') IS NOT NULL
BEGIN
	DROP TABLE #temp_prostr;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_prostr
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id
WHERE
--[AssignmentTypes].code<>N'ToAttention' and [AssignmentStates].code=N'InWork' and 
--[Questions].control_date<=getutcdate()
([Questions].control_date <= GETUTCDATE()
AND [AssignmentTypes].code <> N'ToAttention'
AND [AssignmentStates].code = N'InWork')
AND [Assignments].[executor_organization_id] = @organization_id;


IF OBJECT_ID('tempdb..#temp_uvaga') IS NOT NULL
BEGIN
	DROP TABLE #temp_uvaga;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_uvaga
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id
WHERE
--[AssignmentTypes].code<>N'ToAttention' and [AssignmentStates].code=N'InWork' and 
--datediff(HH, [Assignments].registration_date, getdate())>[Attention_term_hours]
--and datediff(HH, [Assignments].registration_date, getdate())<=[execution_term]
-- DATEADD(MI, DATEDIFF(MI, [Questions].registration_date, [Questions].control_date)*0.25*-1, [Questions].control_date)<getutcdate()
-- [Questions].control_date>=getutcdate()
(DATEADD(MI, DATEDIFF(MI, [Questions].registration_date, [Questions].control_date) * 0.25 * -1, [Questions].control_date) < GETUTCDATE()
AND [Questions].control_date >= GETUTCDATE()
AND [AssignmentTypes].code <> N'ToAttention'
AND [AssignmentStates].code = N'InWork')
AND [Assignments].[executor_organization_id] = @organization_id


IF OBJECT_ID('tempdb..#temp_vroboti') IS NOT NULL
BEGIN
	DROP TABLE #temp_vroboti;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_vroboti
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id
WHERE
--[AssignmentTypes].code<>N'ToAttention' and [AssignmentStates].code=N'InWork' and
--datediff(HH, [Assignments].registration_date, getdate())<=[Attention_term_hours]
-- DATEADD(MI, DATEDIFF(MI, [Questions].registration_date, [Questions].control_date)*0.75, [Questions].registration_date)>=getutcdate()
-- and [Questions].control_date>=getutcdate()
[Assignments].[executor_organization_id] = @organization_id
AND (DATEADD(MI, DATEDIFF(MI, [Questions].registration_date, [Questions].control_date) * 0.75, [Questions].registration_date) >= GETUTCDATE()
AND [Questions].control_date >= GETUTCDATE()
AND [AssignmentTypes].code <> N'ToAttention'
AND [AssignmentStates].code = N'InWork');



IF OBJECT_ID('tempdb..#temp_dovidoma') IS NOT NULL
BEGIN
	DROP TABLE #temp_dovidoma;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_dovidoma
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id

WHERE [AssignmentTypes].code = N'ToAttention'
AND [AssignmentStates].code = N'Registered'
AND [Assignments].[executor_organization_id] = @organization_id



IF OBJECT_ID('tempdb..#temp_nadoopr') IS NOT NULL
BEGIN
	DROP TABLE #temp_nadoopr;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_nadoopr
FROM [dbo].[Assignments] WITH (NOLOCK)
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id

WHERE [AssignmentStates].code = N'NotFulfilled'
AND ([AssignmentResults].code = N'ForWork'
OR [AssignmentResults].code = N'Actually')
AND [Assignments].[executor_organization_id] = @organization_id



IF OBJECT_ID('tempdb..#temp_plan_p') IS NOT NULL
BEGIN
	DROP TABLE #temp_plan_p;
END;
SELECT
	[Assignments].Id
   ,CASE
		WHEN [ReceiptSources].code = N'UGL' THEN 1
		WHEN [ReceiptSources].code = N'Website_mob.addition' THEN 2
		WHEN [QuestionTypes].emergency = 1 THEN 3
		WHEN [QuestionTypes].parent_organization_is = N'true' THEN 5
		ELSE 4
	END navigation INTO #temp_plan_p
FROM [dbo].[Assignments] WITH (NOLOCK)
INNER JOIN #temp_end_result
	ON [Assignments].Id = #temp_end_result.assignment_id
INNER JOIN #temp_end_state
	ON [Assignments].Id = #temp_end_state.assignment_id
LEFT JOIN [dbo].[Questions] WITH (NOLOCK)
	ON [Assignments].question_id = [Questions].Id
LEFT JOIN [dbo].[Appeals] WITH (NOLOCK)
	ON [Questions].appeal_id = [Appeals].Id
LEFT JOIN [dbo].[ReceiptSources] WITH (NOLOCK)
	ON [Appeals].receipt_source_id = [ReceiptSources].Id
LEFT JOIN [dbo].[QuestionTypes] WITH (NOLOCK)
	ON [Questions].question_type_id = [QuestionTypes].Id
LEFT JOIN [dbo].[AssignmentTypes] WITH (NOLOCK)
	ON [Assignments].assignment_type_id = [AssignmentTypes].Id
LEFT JOIN [dbo].[AssignmentStates] WITH (NOLOCK)
	ON [Assignments].assignment_state_id = [AssignmentStates].Id
LEFT JOIN [dbo].[AssignmentResults] WITH (NOLOCK)
	ON [Assignments].[AssignmentResultsId] = [AssignmentResults].Id -- +
LEFT JOIN [dbo].[AssignmentResolutions] WITH (NOLOCK)
	ON [Assignments].[AssignmentResolutionsId] = [AssignmentResolutions].Id
WHERE [Questions].event_id IS NULL
--where 
--[AssignmentStates].code=N'NotFulfilled' and [AssignmentResults].code=N'ItIsNotPossibleToPerformThisPeriod'

--and [Assignments].[executor_organization_id]=@organization_id


IF OBJECT_ID('tempdb..#temp_main') IS NOT NULL
BEGIN
	DROP TABLE #temp_main;
END;

SELECT
	Id
   ,navigation
   ,N'nadiishlo' name INTO #temp_main
FROM #temp_nadiishlo
UNION ALL
SELECT
	Id
   ,navigation
   ,N'nevkomp' name
FROM #temp_nevkomp
UNION ALL
SELECT
	Id
   ,navigation
   ,N'prostr' name
FROM #temp_prostr
UNION ALL
SELECT
	Id
   ,navigation
   ,N'uvaga' name
FROM #temp_uvaga
UNION ALL
SELECT
	Id
   ,navigation
   ,N'vroboti' name
FROM #temp_vroboti
UNION ALL
SELECT
	Id
   ,navigation
   ,N'dovidoma' name
FROM #temp_dovidoma
UNION ALL
SELECT
	Id
   ,navigation
   ,N'nadoopr' name
FROM #temp_nadoopr
UNION ALL
SELECT
	Id
   ,navigation
   ,N'neVykonNeMozhl' name
FROM #temp_plan_p;



SELECT
	Id
   ,name [navigation]
   ,ISNULL([nadiishlo], 0) [nadiyshlo]
   ,ISNULL([nevkomp], 0) [neVKompetentsii]
   ,ISNULL([prostr], 0) [prostrocheni]
   ,ISNULL([uvaga], 0) [uvaga]
   ,ISNULL([vroboti], 0) [vroboti]
   ,ISNULL([dovidoma], 0) [dovidoma]
   ,ISNULL([nadoopr], 0) [naDoopratsiyvanni]
   ,ISNULL([neVykonNeMozhl], 0) [neVykonNeMozhl]
FROM (SELECT
		#temp_navig.Id
	   ,#temp_navig.name
	   ,main.name main_name
	   ,cc
	FROM #temp_navig
	LEFT JOIN (SELECT
			navigation
		   ,name
		   ,COUNT(Id) cc
		FROM #temp_main
		GROUP BY navigation
				,name) main
		ON #temp_navig.Id = main.navigation) t
PIVOT
(SUM(cc) FOR main_name IN ([nadiishlo], [nevkomp], [prostr], [uvaga], [vroboti], [dovidoma], [nadoopr], [neVykonNeMozhl])
) pvt;
	END
   
   ELSE 

	BEGIN
		SELECT 1 Id, 2 [nadiyshlo], 2 [neVKompetentsii], 2 [prostrocheni], 2 [uvaga], 2 [vroboti], 2 [dovidoma], 2 [naDoopratsiyvanni], 2 [neVykonNeMozhl]
		WHERE 1=2;
	END;

   

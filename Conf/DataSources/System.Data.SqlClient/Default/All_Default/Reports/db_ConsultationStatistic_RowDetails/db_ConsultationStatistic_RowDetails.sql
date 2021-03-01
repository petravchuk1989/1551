-- DECLARE @dateFrom DATE = DATEADD(DAY, -30, GETDATE());
-- DECLARE @dateTo DATE = GETDATE(); 
-- DECLARE @knowledge_id INT = 3510647;

IF OBJECT_ID ('tempdb..#Knowledge') IS NOT NULL
BEGIN
	DROP TABLE #Knowledge;
END

CREATE TABLE #Knowledge ([Id] INT, 
						 [parent_id] INT,
						 [Name] NVARCHAR(300),
						 [article_qty] INT,
						 [article_percent] NUMERIC(5,2),
						 [talk_all] INT,
						 [talk_consultations_only] INT,
						 [talk_consultation_average] INT,
						 [sort_index] TINYINT
						 ) WITH (DATA_COMPRESSION = PAGE);
--> Общее значение консультаций
DECLARE @Knowledge_AllVal INT; 
SELECT 
	@Knowledge_AllVal = SUM(number_by_day)
FROM dbo.ConsultationStatistic cs
INNER JOIN CRM_1551_System.dbo.[User] u ON u.[UserId] = cs.[user_id]
WHERE 
#filter_columns# AND
CAST(main_datetime AS DATE) 
BETWEEN @dateFrom AND @dateTo
	AND (article_id = @knowledge_id
	OR article_id IN (SELECT 
						Id 
				   FROM dbo.KnowledgeBaseStates
				   WHERE parent_id = @knowledge_id)
	);
--> Сбор данных по статистике типов 
INSERT INTO #Knowledge
SELECT 
	[Id],
	[parent_id],
	[name],
	SUM(ISNULL(cs.number_by_day,0)) AS [article_qty], 
    CASE WHEN SUM(cs.number_by_day) > 0 
		 THEN 
		 CAST(CAST(SUM(cs.number_by_day) AS NUMERIC(10,2))
		 / CAST(@Knowledge_AllVal AS NUMERIC(10,2)) AS NUMERIC(10,2)) * 100
		 ELSE 0 END 
  		AS [article_percent], 
    SUM(ISNULL(cs.duration,0)) AS [talk_all], 
    SUM(ISNULL(cs.duration_only_cons,0)) AS [talk_consultations_only], 
    CASE WHEN SUM(cs.number_only_cons) > 0 
		 THEN 
		 SUM(ISNULL(cs.duration_only_cons,0)) / SUM(ISNULL(cs.number_only_cons,0))
		 ELSE 0 END
  		AS [talk_consultation_average],
	IIF(kn_base.Id = @knowledge_id, 1, 2) 
		AS [sort_index]
FROM dbo.KnowledgeBaseStates kn_base
LEFT JOIN dbo.ConsultationStatistic cs ON cs.article_id = kn_base.id
LEFT JOIN CRM_1551_System.dbo.[User] u ON u.[UserId] = cs.[user_id]
WHERE 
	#filter_columns# AND
	CAST(cs.main_datetime AS DATE)
	BETWEEN @dateFrom AND @dateTo
	AND (kn_base.id = @knowledge_id 
	OR kn_base.parent_id = @knowledge_id)
GROUP BY [parent_id], 
		 [Id], 
		 [name],
		 number_by_day,
		 number_only_cons
ORDER BY 2,1;

IF NOT EXISTS (SELECT Id FROM #Knowledge WHERE Id = @knowledge_id)
BEGIN
	INSERT INTO #Knowledge
	SELECT 
	[Id],
	[parent_id],
	[name],
	0 AS [article_qty], 
    0 [article_percent], 
    0 AS [talk_all], 
    0 AS [talk_consultations_only], 
    0 AS [talk_consultation_average],
	1 AS [sort_index]
FROM dbo.KnowledgeBaseStates kn_base
WHERE Id = @knowledge_id;
END

INSERT INTO #Knowledge
SELECT 
	[Id], 
	[parent_id],
	[Name],
	0 AS [article_qty],
	0 AS [article_percent],
	0 AS [talk_all],
	0 AS [talk_consultations_only],
	0 AS [talk_consultation_average],
	IIF(Id = @knowledge_id, 1, 2) 
	AS [sort_index]
FROM dbo.KnowledgeBaseStates
WHERE parent_id = @knowledge_id
AND [Id] NOT IN (SELECT Id FROM #Knowledge);

 --select * from #Knowledge;

IF OBJECT_ID('tempdb..#RootVals') IS NOT NULL
BEGIN
	DROP TABLE #RootVals;
END
SELECT 
	[Id],
	[parent_id],
	[Name],
	[article_qty],
	[article_percent],
	[talk_all],
	[talk_consultations_only],
	[talk_consultation_average],
	[sort_index]
INTO #RootVals
FROM #Knowledge;

DECLARE @RootCircle TABLE (Id INT);
INSERT INTO @RootCircle
SELECT 
	[Id]
FROM #RootVals;

--SELECT * FROM @RootCircle; 

DECLARE @Count SMALLINT = (SELECT COUNT(1) FROM @RootCircle);
DECLARE @Step SMALLINT = 1;
DECLARE @Current INT;
DECLARE @StepValues TABLE (Id INT);

WHILE (@Step <= @Count)
BEGIN
	DELETE FROM @StepValues;
	SET @Current = (SELECT TOP 1 [Id] FROM @RootCircle);

	IF (@Current = @knowledge_id)
	BEGIN
	UPDATE #RootVals
		SET [article_qty] = (SELECT SUM([article_qty]) FROM #Knowledge WHERE [Id] = @knowledge_id),
			[article_percent] = (SELECT SUM([article_percent]) FROM #Knowledge WHERE [Id] = @knowledge_id),
			[talk_all] = (SELECT SUM([talk_all]) FROM #Knowledge WHERE [Id] = @knowledge_id),
			[talk_consultations_only] = (SELECT SUM([talk_consultations_only]) FROM #Knowledge WHERE [Id] = @knowledge_id),
			[talk_consultation_average] = (SELECT AVG([talk_consultation_average]) FROM #Knowledge WHERE [Id] = @knowledge_id)
	WHERE [Id] = @Current;

	DELETE FROM @RootCircle
	WHERE Id = @Current;
	
	SET @Step +=1;
	END
	
	ELSE 
	BEGIN 
	WITH Knowledge_Rec ([Id], [parent_id], [Name])
	AS
	(
		SELECT [Id], 
			   [parent_id], 
			   [Name]
		FROM #Knowledge e
		WHERE e.Id = @Current 
		UNION ALL
		SELECT e.[Id], 
			   e.[parent_id], 
			   e.[Name]
		FROM #Knowledge e
		INNER JOIN Knowledge_Rec r ON e.parent_id = r.Id
	)
	
	INSERT INTO @StepValues
	SELECT 
		[Id]
	FROM Knowledge_Rec;

	UPDATE #RootVals
		SET [article_qty] = (SELECT SUM([article_qty]) FROM #Knowledge WHERE [Id] IN (SELECT [Id] FROM @StepValues)),
			[article_percent] = (SELECT SUM([article_percent]) FROM #Knowledge WHERE [Id] IN (SELECT [Id] FROM @StepValues)),
			[talk_all] = (SELECT SUM(ISNULL([talk_all], 0)) FROM #Knowledge WHERE [Id] IN (SELECT [Id] FROM @StepValues)),
			[talk_consultations_only] = (SELECT SUM(ISNULL([talk_consultations_only], 0)) FROM #Knowledge WHERE [Id] IN (SELECT [Id] FROM @StepValues)),
			[talk_consultation_average] = (SELECT AVG(ISNULL([talk_consultation_average], 0)) FROM #Knowledge WHERE [Id] IN (SELECT [Id] FROM @StepValues))
	WHERE [Id] = @Current;

	DELETE FROM @RootCircle
	WHERE Id = @Current;
	
	SET @Step +=1;
	END
END
SELECT 
[Id],
	[Name],
	[article_qty],
	[article_percent],
	-- получить значение часов:минут:секунд, обработка до 4 символов hh
	CASE WHEN 
	SUBSTRING(RIGHT('0' + CAST([talk_all] / 3600 AS VARCHAR(10)),4),1,1) = '0'
		THEN CASE WHEN 
			SUBSTRING(RIGHT('0' + CAST([talk_all] / 3600 AS VARCHAR(10)),3),1,1) = '0'
			THEN RIGHT('0' + CAST([talk_all] / 3600 AS VARCHAR(10)),2)
			ELSE RIGHT('0' + CAST([talk_all] / 3600 AS VARCHAR(10)),3)
			END
		ELSE RIGHT(CAST([talk_all] / 3600 AS VARCHAR(10)),4)
		END + ':' +
	RIGHT('0' + CAST(([talk_all] / 60) % 60 AS VARCHAR(10)),2) + ':' +
	RIGHT('0' + CAST([talk_all] % 60 AS VARCHAR(10)),2)
		AS [talk_all],
	CASE WHEN 
	SUBSTRING(RIGHT('0' + CAST([talk_consultations_only] / 3600 AS VARCHAR(10)),4),1,1) = '0'
		THEN CASE WHEN 
			SUBSTRING(RIGHT('0' + CAST([talk_consultations_only] / 3600 AS VARCHAR(10)),3),1,1) = '0'
			THEN RIGHT('0' + CAST([talk_consultations_only] / 3600 AS VARCHAR(10)),2)
			ELSE RIGHT('0' + CAST([talk_consultations_only] / 3600 AS VARCHAR(10)),3)
			END
		ELSE RIGHT(CAST([talk_consultations_only] / 3600 AS VARCHAR(10)),4)
		END + ':' +
	RIGHT('0' + CAST(([talk_consultations_only] / 60) % 60 AS VARCHAR(10)),2) + ':' +
	RIGHT('0' + CAST([talk_consultations_only] % 60 AS VARCHAR(10)),2) 
		AS [talk_consultations_only],
	CASE WHEN 
	SUBSTRING(RIGHT('0' + CAST([talk_consultation_average] / 3600 AS VARCHAR(10)),4),1,1) = '0'
		THEN CASE WHEN 
			SUBSTRING(RIGHT('0' + CAST([talk_consultation_average] / 3600 AS VARCHAR(10)),3),1,1) = '0'
			THEN RIGHT('0' + CAST([talk_consultation_average] / 3600 AS VARCHAR(10)),2)
			ELSE RIGHT('0' + CAST([talk_consultation_average] / 3600 AS VARCHAR(10)),3)
			END
		ELSE RIGHT(CAST([talk_consultation_average] / 3600 AS VARCHAR(10)),4)
		END + ':' +
	RIGHT('0' + CAST(([talk_consultation_average] / 60) % 60 AS VARCHAR(10)),2) + ':' +
	RIGHT('0' + CAST([talk_consultation_average] % 60 AS VARCHAR(10)),2)
		 AS [talk_consultation_average],
	NULL AS UserId
FROM #RootVals
ORDER BY [sort_index], [Name];
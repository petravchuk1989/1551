-- DECLARE @dateFrom DATETIME = '2020-08-31T21:00:00.000Z';
-- DECLARE @dateTo DATETIME = GETDATE();

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
						 [talk_consultation_average] INT
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
BETWEEN @dateFrom AND @dateTo;
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
  		AS [talk_consultation_average]
FROM dbo.KnowledgeBaseStates kn_base
LEFT JOIN dbo.ConsultationStatistic cs ON cs.article_id = kn_base.id
LEFT JOIN CRM_1551_System.dbo.[User] u ON u.[UserId] = cs.[user_id]
WHERE 
	#filter_columns# AND
	CAST(cs.main_datetime AS DATE)
	BETWEEN @dateFrom AND @dateTo
GROUP BY  
		 [Id], 
		 [parent_id],
		 [name]
ORDER BY 2,1;

INSERT INTO #Knowledge
SELECT 
	[Id], 
	[parent_id],
	[Name],
	0 AS [article_qty],
	0 AS [article_percent],
	0 AS [talk_all],
	0 AS [talk_consultations_only],
	0 AS [talk_consultation_average]
FROM dbo.KnowledgeBaseStates
WHERE parent_id = 1 
AND Id NOT IN (SELECT Id FROM #Knowledge);

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
	[talk_consultation_average] 
INTO #RootVals
FROM #Knowledge 
WHERE parent_id = 1;

--SELECT * FROM #RootVals;

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

SELECT 
DISTINCT
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
	NULL AS [UserId]
FROM #RootVals
ORDER BY [Name];
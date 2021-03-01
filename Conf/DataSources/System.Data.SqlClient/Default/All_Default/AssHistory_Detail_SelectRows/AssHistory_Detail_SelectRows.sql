-- DECLARE @SourceHistory nvarchar(50) = N'Document'
-- --DECLARE @SourceHistory nvarchar(50) = N'Assignment'
-- DECLARE @history_id INT = 8; /*5933063*/
-- DECLARE @pageOffsetRows int = 0
-- DECLARE @pageLimitRows int = 10



DECLARE @Archive NVARCHAR(MAX) = '['+(SELECT TOP 1 [IP]+'].['+[DatabaseName]+'].' FROM [dbo].[SetingConnetDatabase] WHERE Code = N'Archive');

DECLARE @IsHere BIT 



DECLARE @Query NVARCHAR(MAX)

if @SourceHistory = N'Assignment'
begin

	SET @IsHere = IIF(
	   (
		  SELECT
			 COUNT(1)
		  FROM
			 dbo.Assignment_History
		  WHERE
			Id = @history_id
	   ) = 0,
	   0,
	   1
	);

	IF(@IsHere = 1)
	BEGIN
		SET @Archive = SPACE(1);
	END

	SET @Query = 
	N'DECLARE @history_id_old INT = (
		SELECT
			TOP 1 Id
		FROM
			'+@Archive+N'[dbo].[Assignment_History]
		WHERE
			[Log_Date] < (
				SELECT
					Log_Date
				FROM
					'+@Archive+N'[dbo].[Assignment_History]
				WHERE
					Id = @history_id
			)
			AND [assignment_id] = (
				SELECT
					[assignment_id]
				FROM
					'+@Archive+N'[dbo].[Assignment_History]
				WHERE
					Id = @history_id
			)
		ORDER BY
			[Log_Date] DESC
	) ;
	--select @history_id, @history_id_old

	IF object_id(''tempdb..#temp_OUT'') IS NOT NULL 
	BEGIN
	DROP TABLE #temp_OUT;
	END

	CREATE TABLE #temp_OUT(
	[history_id] INT,
	[history_type_name] NVARCHAR(100),
	[history_value_old] NVARCHAR(500),
	[history_value_new] NVARCHAR(500),
	) WITH (DATA_COMPRESSION = PAGE);
	INSERT INTO
		#temp_OUT([history_id], [history_type_name], [history_value_old],[history_value_new])
	SELECT
		t1.Id,
		N''Стан доручення'' AS [history_type_name],
		qt2.[name] AS [history_value_old],
		qt1.[name] AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
		LEFT JOIN [dbo].[AssignmentStates] AS qt1 ON qt1.Id = t1.assignment_state_id
		LEFT JOIN [dbo].[AssignmentStates] AS qt2 ON qt2.Id = t2.assignment_state_id
	WHERE
		t1.Id = @history_id
	UNION
	ALL
	SELECT
		t1.Id,
		N''Взято в роботу'' AS [history_type_name],
		CONVERT(VARCHAR(10), t2.[transfer_date], 104) + '' '' + CONVERT(VARCHAR(10), t2.[transfer_date], 108) AS [history_value_old],
		CONVERT(VARCHAR(10), t1.[transfer_date], 104) + '' '' + CONVERT(VARCHAR(10), t1.[transfer_date], 108) AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
	WHERE
		t1.Id = @history_id
	UNION
	ALL
	SELECT
		t1.Id,
		N''Виконавець'' AS [history_type_name],
		IIF(
			len([Organizations2].[head_name]) > 5,
			isnull([Organizations2].[head_name], N''''),
			isnull([Organizations2].[short_name], N'''')
		) AS [history_value_old],
		IIF(
			len([Organizations1].[head_name]) > 5,
			isnull([Organizations1].[head_name], N''''),
			isnull([Organizations1].[short_name], N'''')
		) AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
		LEFT JOIN [dbo].[Organizations] AS [Organizations1] ON [Organizations1].Id = [t1].[executor_organization_id]
		LEFT JOIN [dbo].[Organizations] AS [Organizations2] ON [Organizations2].Id = [t2].[executor_organization_id]
	WHERE
		t1.Id = @history_id
	UNION
	ALL
	SELECT
		t1.Id,
		N''Головний'' AS [history_type_name],
		CASE
			WHEN t2.main_executor = 1 THEN N''Так''
			ELSE N''Ні''
		END AS [history_value_old],
		CASE
			WHEN t1.main_executor = 1 THEN N''Так''
			ELSE N''Ні''
		END AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
	WHERE
		t1.Id = @history_id
	UNION
	ALL
	SELECT
		t1.Id,
		N''Результат'' AS [history_type_name],
		qt2.[name] AS [history_value_old],
		qt1.[name] AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
		LEFT JOIN [dbo].[AssignmentResults] AS qt1 ON qt1.Id = t1.AssignmentResultsId
		LEFT JOIN [dbo].[AssignmentResults] AS qt2 ON qt2.Id = t2.AssignmentResultsId
	WHERE
		t1.Id = @history_id
	UNION
	ALL
	SELECT
		t1.Id,
		N''Резолюція'' AS [history_type_name],
		qt2.[name] AS [history_value_old],
		qt1.[name] AS [history_value_new] 
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
		LEFT JOIN [dbo].[AssignmentResolutions] AS qt1 ON qt1.Id = t1.AssignmentResolutionsId
		LEFT JOIN [dbo].[AssignmentResolutions] AS qt2 ON qt2.Id = t2.AssignmentResolutionsId
	WHERE
		t1.Id = @history_id 
	UNION
	  ALL 
	SELECT
		t1.Id,
		N''Коментар'' AS [history_type_name],
		t2.short_answer AS [history_value_old],
		t1.short_answer AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[Assignment_History] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = @history_id_old
	WHERE
		t1.Id = @history_id ;

	SELECT
		*
	FROM
		#temp_OUT
	WHERE
		isnull([history_value_old], N'''') != isnull([history_value_new], N'''')
		AND #filter_columns#
	ORDER BY
		1 
	OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY ; ' ;
end
else
begin
	SET @IsHere = IIF(
	   (
		  SELECT
			 COUNT(1)
		  FROM
			 dbo.[AssignmentDetailHistory]
		  WHERE
			Id = @history_id
	   ) = 0,
	   0,
	   1
	);

	IF(@IsHere = 1)
	BEGIN
		SET @Archive = SPACE(1);
	END

	SET @Query = 
	N'
		DECLARE @history_id_old2 INT = (
		SELECT TOP 1 Id
		FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
		WHERE  [SourceHistory] = N'''+@SourceHistory+'''
		AND [Edit_date] < (
				SELECT
					Edit_date
				FROM
					'+@Archive+N'[dbo].[AssignmentDetailHistory]
				WHERE
					Id = @history_id
			)
		AND [Assignment_id] = (
				SELECT
					[Assignment_id]
				FROM
					'+@Archive+N'[dbo].[AssignmentDetailHistory]
				WHERE
					Id = @history_id
			)
		ORDER BY
			[Edit_date] DESC
	) ;
	--select @history_id, @history_id_old2

	IF object_id(''tempdb..#temp_OUT'') IS NOT NULL 
	BEGIN
	DROP TABLE #temp_OUT;
	END

	CREATE TABLE #temp_OUT(
	[history_id] INT,
	[history_type_name] NVARCHAR(100),
	[history_value_old] NVARCHAR(3000),
	[history_value_new] NVARCHAR(3000),
	) WITH (DATA_COMPRESSION = PAGE);
	INSERT INTO
		#temp_OUT([history_id], [history_type_name], [history_value_old],[history_value_new])
	SELECT
		t1.Id,
		N''Назва документу доручення'' AS [history_type_name],
		isnull(t2.[Documentsname], N'''') AS [history_value_old],
		isnull(t1.[Documentsname], N'''') AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t2 ON t2.Id = @history_id_old2
	WHERE t1.Id = @history_id
	UNION ALL
	SELECT
		t1.Id,
		N''Зміст документу доручення'' AS [history_type_name],
		isnull(t2.[Documentscontent], N'''') AS [history_value_old],
		isnull(t1.[Documentscontent], N'''') AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t2 ON t2.Id = @history_id_old2
	WHERE t1.Id = @history_id
	UNION ALL
	SELECT
		t1.Id,
		N''Назва файлу'' AS [history_type_name],
		case when t1.[Operation] = N''INSERT'' then N'''' else  isnull(t2.[Filename], N'''') end AS [history_value_old],
		case when t1.[Operation] = N''DELETE'' then N'''' else isnull(t1.[Filename], N'''') end AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t2 ON t2.Id = @history_id_old2
	WHERE t1.Id = @history_id
	UNION ALL
	SELECT
		t1.Id,
		N''Недозвон'' AS [history_type_name],
		rtrim(isnull(t2.[Missed_call_counter], 0)) AS [history_value_old],
		rtrim(isnull(t1.[Missed_call_counter], 0)) AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t2 ON t2.Id = @history_id_old2
	WHERE t1.Id = @history_id
	UNION ALL
	SELECT
		t1.Id,
		N''Коментар по недозвону'' AS [history_type_name],
		isnull(t2.[MissedCallComment], N'''') AS [history_value_old],
		isnull(t1.[MissedCallComment], N'''') AS [history_value_new]
	FROM
		'+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
		LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t2 ON t2.Id = @history_id_old2
	WHERE t1.Id = @history_id
	;




	SELECT
		*
	FROM
		#temp_OUT
	WHERE
		isnull([history_value_old], N'''') != isnull([history_value_new], N'''')
		AND #filter_columns#
	ORDER BY
		1 
	OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY ; ' ;
end

 EXEC sp_executesql @Query, N'@history_id INT, @pageOffsetRows BIGINT, @pageLimitRows BIGINT', 
							@history_id = @history_id,
							@pageOffsetRows = @pageOffsetRows,
							@pageLimitRows = @pageLimitRows;
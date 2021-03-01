-- DECLARE @Id INT = 3988959;
-- DECLARE @pageOffsetRows int = 0
-- DECLARE @pageLimitRows int = 10
--DECLARE @SourceHistory nvarchar(50) = N''
--replace #system_database_name# to CRM_1551_System




DECLARE @Archive NVARCHAR(max) = '['+(SELECT TOP 1 [IP]+'].['+[DatabaseName]+'].' FROM [dbo].[SetingConnetDatabase] WHERE Code = N'Archive');

DECLARE @IsHere BIT = IIF(
   (
      SELECT
         COUNT(1)
      FROM
         dbo.Assignments
      WHERE
        Id = @Id
   ) = 0,
   0,
   1
);

IF(@IsHere = 1)
BEGIN
	SET @Archive = SPACE(1);
END
DECLARE @Query NVARCHAR(MAX) = 
N'
IF object_id(''tempdb..#temp_OUT'') IS NOT NULL 
BEGIN
DROP TABLE #temp_OUT;
END

CREATE TABLE #temp_OUT(
[history_id_old] INT,
[history_id_new] INT
) WITH (DATA_COMPRESSION = PAGE);



IF object_id(''tempdb..#temp_OUT_History'') IS NOT NULL 
BEGIN
DROP TABLE #temp_OUT_History;
END
CREATE TABLE #temp_OUT_History(
[Id] int,
[operation_date] datetime,
[user_id] nvarchar(500),
[operation_name] nvarchar(500),
[SourceHistory] nvarchar(50)
) WITH (DATA_COMPRESSION = PAGE);

INSERT INTO
 #temp_OUT ([history_id_new])
SELECT
  t1.Id
FROM
  '+@Archive+N'[dbo].[Assignment_History] AS t1
WHERE
  t1.assignment_id = @Id
ORDER BY
  t1.Id ;

UPDATE 
  #temp_OUT SET history_id_old = (SELECT TOP 1 Id FROM '+@Archive+N'[dbo].[Assignment_History] 
WHERE
  [Log_Date] < (
    SELECT
      Log_Date
    FROM
      '+@Archive+N'[dbo].[Assignment_History]
    WHERE
      Id = #temp_OUT.history_id_new) 
      AND [assignment_id] = (
        SELECT
          [assignment_id]
        FROM
          '+@Archive+N'[dbo].[Assignment_History]
        WHERE
          Id = #temp_OUT.history_id_new)
        ORDER BY
          [Log_Date] DESC
      ) ;


	insert into #temp_OUT_History([Id], [operation_date], [user_id], [operation_name], [SourceHistory])
    SELECT
      [Assignment_History].[Id],
      [Assignment_History].[Log_Date] AS [operation_date],
      isnull([User].LastName, N'''') + isnull(N'' ''+[User].FirstName, N'''') + isnull(N'' ''+[User].[Patronymic], N'''') + isnull(N'' (''+ AplOrg.short_name + N'')'', N'''') AS [user_id],
	CASE
        WHEN [Assignment_History].[Log_Activity] = N''UPDATE'' THEN N''Зміни в дорученні''
        WHEN [Assignment_History].[Log_Activity] = N''INSERT'' THEN N''Створення доручення''
        ELSE N''Зміни в дорученні''
      END AS [operation_name],
	  N''Assignment'' as [SourceHistory]
    FROM
      '+@Archive+N'[dbo].[Assignment_History]
      LEFT JOIN '+@Archive+N'[dbo].Assignments ON Assignments.Id = [Assignment_History].assignment_id
      LEFT JOIN [#system_database_name#].[dbo].[User] AS [User] ON [User].UserId = [Assignment_History].[Log_User]
      LEFT JOIN (
        SELECT Apl.[worker_user_id], APLn.short_name
              FROM [dbo].[Workers] as Apl
              cross apply 
              (
              SELECT top 1 AplTop.[worker_user_id], [Organizations].short_name
                FROM [dbo].[Workers] as AplTop
                left join [dbo].[Organizations] on [Organizations].[Id] = AplTop.[organization_id]
              where AplTop.[worker_user_id] = Apl.[worker_user_id]
              ) APLn 
              where len(isnull(Apl.[worker_user_id],N'''')) > 0
        group by Apl.[worker_user_id], APLn.short_name
      ) AS AplOrg on AplOrg.[worker_user_id] = [Assignment_History].[Log_User]
    WHERE
      [Assignment_History].[assignment_id] = @Id
      AND [Assignment_History].Id IN (
        SELECT
          t0.history_id_new
        FROM
          #temp_OUT AS t0
          LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t1 ON t1.Id = t0.history_id_new
          LEFT JOIN '+@Archive+N'[dbo].[Assignment_History] AS t2 ON t2.Id = t0.history_id_old
          LEFT JOIN [dbo].[Organizations] AS [Organizations1] ON [Organizations1].Id = t1.[executor_organization_id]
          LEFT JOIN [dbo].[Organizations] AS [Organizations2] ON [Organizations2].Id = t2.[executor_organization_id]
        WHERE
          t1.assignment_state_id != t2.assignment_state_id
          OR t1.transfer_date != t2.transfer_date
          OR IIF(
            len([Organizations2].[head_name]) > 5,
            isnull([Organizations2].[head_name], N''''),
            isnull([Organizations2].[short_name], N'''')
          ) ! = IIF(
            len([Organizations1].[head_name]) > 5,
            isnull([Organizations1].[head_name], N''''),
            isnull([Organizations1].[short_name], N'''')
          )
          OR t1.main_executor != t2.main_executor
          OR t1.AssignmentResultsId != t2.AssignmentResultsId
          OR t1.short_answer != t2.short_answer
          OR t1.AssignmentResolutionsId != t2.AssignmentResolutionsId
      )


	  DELETE FROM #temp_OUT

  -----------AssignmentDetailHistory - Document
	  INSERT INTO #temp_OUT ([history_id_new])
	  SELECT t1.Id
	  FROM '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
	  WHERE t1.Assignment_id = @Id and [SourceHistory] = N''Document''
	  ORDER BY t1.Id ;

		UPDATE #temp_OUT SET history_id_old = (
			SELECT TOP 1 Id FROM '+@Archive+N'[dbo].[AssignmentDetailHistory] 
			WHERE [Edit_date] < (
				SELECT Edit_date
				FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
				WHERE Id = #temp_OUT.history_id_new
				and [SourceHistory] = N''Document'') 
			AND [Assignment_id] = (
					SELECT [Assignment_id]
					FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
					WHERE Id = #temp_OUT.history_id_new
					and [SourceHistory] = N''Document'')
			AND [SourceHistory] = N''Document''
			ORDER BY [Edit_date] DESC
		) ;
 -----------
 -----------AssignmentDetailHistory - File
	  INSERT INTO #temp_OUT ([history_id_new])
	  SELECT t1.Id
	  FROM '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
	  WHERE t1.Assignment_id = @Id and [SourceHistory] = N''File''
	  ORDER BY t1.Id ;

		UPDATE #temp_OUT SET history_id_old = (
			SELECT TOP 1 Id FROM '+@Archive+N'[dbo].[AssignmentDetailHistory] 
			WHERE [Edit_date] < (
				SELECT Edit_date
				FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
				WHERE Id = #temp_OUT.history_id_new
				and [SourceHistory] = N''File'') 
			AND [Assignment_id] = (
					SELECT [Assignment_id]
					FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
					WHERE Id = #temp_OUT.history_id_new
					and [SourceHistory] = N''File'')
			AND [SourceHistory] = N''File''
			ORDER BY [Edit_date] DESC
		) ;
 -----------
 -----------AssignmentDetailHistory - Call
	  INSERT INTO #temp_OUT ([history_id_new])
	  SELECT t1.Id
	  FROM '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1
	  WHERE t1.Assignment_id = @Id and [SourceHistory] = N''Call''
	  ORDER BY t1.Id ;

		UPDATE #temp_OUT SET history_id_old = (
			SELECT TOP 1 Id FROM '+@Archive+N'[dbo].[AssignmentDetailHistory] 
			WHERE [Edit_date] < (
				SELECT Edit_date
				FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
				WHERE Id = #temp_OUT.history_id_new
				and [SourceHistory] = N''Call'') 
			AND [Assignment_id] = (
					SELECT [Assignment_id]
					FROM '+@Archive+N'[dbo].[AssignmentDetailHistory]
					WHERE Id = #temp_OUT.history_id_new
					and [SourceHistory] = N''Call'')
			AND [SourceHistory] = N''Call''
			ORDER BY [Edit_date] DESC
		) ;
 -----------
	insert into #temp_OUT_History([Id], [operation_date], [user_id], [operation_name], [SourceHistory])
	SELECT
      [AssignmentDetailHistory].[Id],
      [AssignmentDetailHistory].[Edit_date] AS [operation_date],
      isnull([User].LastName, N'''') + isnull(N'' ''+[User].FirstName, N'''') + isnull(N'' ''+[User].[Patronymic], N'''') + isnull(N'' (''+ AplOrg.short_name + N'')'', N'''') AS [user_id],
	CASE
        WHEN [AssignmentDetailHistory].[Operation] = N''UPDATE'' AND [AssignmentDetailHistory].[SourceHistory] = N''Document'' THEN N''Зміни в документі доручення''
        WHEN [AssignmentDetailHistory].[Operation] = N''INSERT'' AND [AssignmentDetailHistory].[SourceHistory] = N''Document'' THEN N''Створення документу доручення''
		WHEN [AssignmentDetailHistory].[Operation] = N''DELETE'' AND [AssignmentDetailHistory].[SourceHistory] = N''Document'' THEN N''Видалення документу доручення''

		WHEN [AssignmentDetailHistory].[Operation] = N''UPDATE'' AND [AssignmentDetailHistory].[SourceHistory] = N''File'' THEN N''Зміни в файлу доручення''
        WHEN [AssignmentDetailHistory].[Operation] = N''INSERT'' AND [AssignmentDetailHistory].[SourceHistory] = N''File'' THEN N''Створення файлу доручення''
		WHEN [AssignmentDetailHistory].[Operation] = N''DELETE'' AND [AssignmentDetailHistory].[SourceHistory] = N''File'' THEN N''Видалення файлу доручення''
		
		WHEN [AssignmentDetailHistory].[Operation] = N''UPDATE'' AND [AssignmentDetailHistory].[SourceHistory] = N''Call'' THEN N''Зміни в недозвоні''
        WHEN [AssignmentDetailHistory].[Operation] = N''INSERT'' AND [AssignmentDetailHistory].[SourceHistory] = N''Call'' THEN N''Створення недозвону по дорученню''
		WHEN [AssignmentDetailHistory].[Operation] = N''DELETE'' AND [AssignmentDetailHistory].[SourceHistory] = N''Call'' THEN N''Видалення недозвону''
        ELSE N''Зміни в документі доручення''
      END AS [operation_name],
	  [AssignmentDetailHistory].[SourceHistory] as [SourceHistory]
    FROM
      '+@Archive+N'[dbo].[AssignmentDetailHistory]
      LEFT JOIN [#system_database_name#].[dbo].[User] AS [User] ON [User].UserId = [AssignmentDetailHistory].[User_id]
      LEFT JOIN (
        SELECT Apl.[worker_user_id], APLn.short_name
              FROM [dbo].[Workers] as Apl
              cross apply 
              (
              SELECT top 1 AplTop.[worker_user_id], [Organizations].short_name
                FROM [dbo].[Workers] as AplTop
                left join [dbo].[Organizations] on [Organizations].[Id] = AplTop.[organization_id]
              where AplTop.[worker_user_id] = Apl.[worker_user_id]
              ) APLn 
              where len(isnull(Apl.[worker_user_id],N'''')) > 0
        group by Apl.[worker_user_id], APLn.short_name
      ) AS AplOrg on AplOrg.[worker_user_id] = [AssignmentDetailHistory].[User_id]
    WHERE
      [AssignmentDetailHistory].[Assignment_id] = @Id
      AND [AssignmentDetailHistory].Id IN (
        SELECT
          t0.history_id_new
        FROM
          #temp_OUT AS t0
          LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t1 ON t1.Id = t0.history_id_new
          LEFT JOIN '+@Archive+N'[dbo].[AssignmentDetailHistory] AS t2 ON t2.Id = t0.history_id_old
        WHERE
		     isnull(t1.[Documentsname], N'''') != isnull(t2.[Documentsname], N'''')
		  OR isnull(t1.[Documentscontent], N'''') != isnull(t2.[Documentscontent], N'''')
		  OR isnull(t1.[Filename], N'''') != isnull(t2.[Filename], N'''')
		  OR isnull(t1.[Missed_call_counter],0) != isnull(t2.[Missed_call_counter],0)
		  OR isnull(t1.[MissedCallComment], N'''') != isnull(t2.[MissedCallComment], N'''')
      )

 -----------



	  select [Id], [operation_date], [user_id], [operation_name], [SourceHistory]
	  from #temp_OUT_History
	  where 1=1
      AND #filter_columns#
	  ORDER BY [operation_date] DESC 
	  OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY
  ; ';

  EXEC sp_executesql @Query, N'@Id INT, @pageOffsetRows BIGINT, @pageLimitRows BIGINT', 
                              @Id = @Id,
                              @pageOffsetRows = @pageOffsetRows,
                              @pageLimitRows = @pageLimitRows;
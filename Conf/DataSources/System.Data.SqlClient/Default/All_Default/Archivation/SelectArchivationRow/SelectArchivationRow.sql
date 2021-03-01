DECLARE @ArchiveDB NVARCHAR(MAX) = (SELECT TOP 1 [IP] FROM dbo.[SetingConnetDatabase] WHERE [Code] = N'Archive');

DECLARE @Query NVARCHAR(MAX) = N'
SELECT 
TOP 1
    [Name] AS current_db,
	CONVERT(VARCHAR, [MoveDate], 111) AS last_loadDate,
	CASE WHEN l.Id IS NOT NULL THEN 
	IIF(l.ErrorMessage IS NULL, 
	N''Успішно перенесено в архів '' + CAST(l.AppealsVal AS VARCHAR(5)) + N'' заявок та '' + CAST(l.FilesVal AS VARCHAR(5)) + N'' файлів'', 
	l.ErrorMessage)
	ELSE N''По даній БД ще не було загрузки в архів'' END
	 AS last_loadResult
FROM [' + @ArchiveDB + N'].CRM_1551_Analitics.dbo.FileDatabaseNaming fn
LEFT JOIN [' + @ArchiveDB + N'].CRM_1551_Analitics.dbo.MoveToArchive_Log l ON l.DatabaseId = fn.Id 
ORDER BY fn.Id DESC;
';

EXEC sp_executesql @Query;
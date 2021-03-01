-- DECLARE @Disk NVARCHAR(MAX) = N'G';
DECLARE @ArchiveDB NVARCHAR(MAX) = (SELECT TOP 1 [IP] FROM dbo.[SetingConnetDatabase] WHERE [Code] = N'Archive');


DECLARE @SQL NVARCHAR(MAX) = 
N' 
DECLARE @Disk NVARCHAR(MAX) = ''' + @Disk + N''';
EXEC [' + @ArchiveDB + N'].CRM_1551_Analitics.dbo.Generate_FileDatabase @Disk = @Disk; ';

EXEC sp_executesql @SQL ;
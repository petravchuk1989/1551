DECLARE @ArchiveDB NVARCHAR(MAX) = (SELECT TOP 1 [IP] FROM dbo.[SetingConnetDatabase] WHERE [Code] = N'Archive');

DECLARE @Query NVARCHAR(MAX) = N'
DECLARE @InfoTab TABLE ([Name] NVARCHAR(1), [Space] INT);

INSERT INTO
    @InfoTab EXEC [' + @ArchiveDB + N'].MASTER..xp_fixeddrives;

SELECT
    [Name],
    [Space]
FROM
    @InfoTab;
';

EXEC sp_executesql @Query;
--  DECLARE @userId NVARCHAR(128) = '5b37daab-e5bd-46c4-bb26-e04d160ec966',
-- 		 @Id INT = 2011; 

IF OBJECT_ID ('tempdb..#OrgsData') IS NOT NULL 
BEGIN
	DROP TABLE #OrgsData;
END

CREATE TABLE #OrgsData (Id INT, 
						shortName NVARCHAR(300), 
						sortIndex TINYINT)
						WITH (DATA_COMPRESSION = PAGE);


DECLARE @user_position TABLE (Id INT);
INSERT INTO @user_position
SELECT 
	[Id]
FROM dbo.Positions 
WHERE [programuser_id] = @userId;

INSERT INTO #OrgsData
SELECT 
	org.[Id],
	org.[short_name],
	1
FROM dbo.[Positions] pos
INNER JOIN dbo.[Organizations] org ON org.Id = pos.organizations_id
WHERE pos.[Id] IN (SELECT [Id] FROM @user_position);

INSERT INTO #OrgsData
SELECT 
	org.[Id],
	org.[short_name],
	2
FROM dbo.[Positions] pos
INNER JOIN dbo.[Organizations] org ON org.Id = pos.organizations_id
INNER JOIN dbo.[PositionsHelpers] help ON help.main_position_id = pos.Id
WHERE help.helper_position_id IN (SELECT [Id] FROM @user_position)
AND org.[Id] NOT IN (SELECT [Id] FROM #OrgsData);


INSERT INTO #OrgsData
SELECT 
DISTINCT 
	organization_id,
	trim(short_name) AS shortName,
	3
FROM dbo.[OrganizationInResponsibilityRights] org_r
INNER JOIN dbo.Organizations o ON o.Id = org_r.organization_id
WHERE position_id IN (SELECT [Id] FROM @user_position)
AND o.Id NOT IN (SELECT [Id] FROM #OrgsData);

IF (@Id IS NOT NULL)
	AND EXISTS (SELECT Id FROM dbo.Organizations WHERE Id = @Id)
	AND NOT EXISTS (SELECT Id FROM #OrgsData WHERE Id = @Id)
BEGIN
	RAISERROR(N'Дана організація недоступна поточному користувачу', 16, 1);
	RETURN;
END
ELSE IF (@Id IS NOT NULL)
		AND NOT EXISTS (SELECT Id FROM dbo.Organizations WHERE Id = @Id)
BEGIN
	RAISERROR(N'Організації по заданому ідентифікатору не існує', 16, 1);
	RETURN;
END

SELECT 
DISTINCT
	[Id],
	trim([shortName]) AS [shortName],
	[sortIndex]
FROM #OrgsData
WHERE 
Id = IIF(@Id IS NOT NULL, @Id, Id)
AND	#filter_columns#
ORDER BY [sortIndex],
		 trim([shortName])
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
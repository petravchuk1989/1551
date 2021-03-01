--  DECLARE @user_id NVARCHAR(128) = 'da9b6464-b7eb-4c1c-94b6-639aa874bd2e';

DECLARE @user_org_str TABLE (Id INT); 
INSERT INTO @user_org_str
SELECT 
	[OrganisationStructureId]
FROM 
[#system_database_name#].dbo.[UserInOrganisation]
  -- CRM_1551_System.dbo.[UserInOrganisation]  
  -- [#system_database_name#]
WHERE [UserId] = @user_id;

IF OBJECT_ID('tempdb..#Complains') IS NOT NULL
BEGIN
	DROP TABLE #Complains;
END

CREATE TABLE #Complains ([Id] INT,
						 [registration_date] DATETIME,
						 [complain_type_name] NVARCHAR(100),
						 [culpritname] NVARCHAR(200),
						 [guilty] NVARCHAR(128),
						 [text] NVARCHAR(2000),
						 [user_name] NVARCHAR(200)) 
             WITH (DATA_COMPRESSION = PAGE); 

---> Выборка всех для админов и главарей КБУ
IF EXISTS (SELECT Id FROM @user_org_str WHERE Id IN (2))
OR EXISTS (SELECT Id FROM dbo.[Positions] WHERE [programuser_id] = @user_id
	AND [organizations_id] = 1762
	AND [active] = 1)
BEGIN
INSERT INTO #Complains
SELECT
  [Complain].[Id],
  [Complain].[registration_date],
  [ComplainTypes].[name] AS [complain_type_name],
  [Complain].[culpritname],
  [Complain].[guilty],
  [Complain].[text],
  [Workers].[name] AS [user_name]
FROM
  [dbo].[Complain] [Complain] 
  LEFT JOIN [dbo].[ComplainTypes] [ComplainTypes] ON ComplainTypes.Id = Complain.complain_type_id
  LEFT JOIN [dbo].[Workers] [Workers] ON Workers.worker_user_id = Complain.[user_id] 
;
END

---> Выборка по подчиненным организациям пользователя, который смотрит (если он не админ или главарь КБУ)
ELSE 
BEGIN
DECLARE @UserPosition TABLE (pos_id INT);
INSERT INTO @UserPosition 
SELECT 
	Id
FROM [dbo].[Positions]
WHERE programuser_id = @user_id 
AND	active = 1;

DECLARE @UserOrgs TABLE (org_id INT);
INSERT INTO @UserOrgs
SELECT
 [organizations_id]
FROM dbo.[Positions]
WHERE [programuser_id] = @user_id 
AND [is_main] = 1
AND [active] = 1;

INSERT INTO @UserOrgs
SELECT 
	p.organizations_id
FROM dbo.[Positions] p
INNER JOIN dbo.[PositionsHelpers] ph ON p.Id = ph.helper_position_id
	AND ph.[helper_position_id] IN (SELECT [pos_id] FROM @UserPosition)
	AND p.[active] = 1
	AND p.[organizations_id] NOT IN (SELECT [org_id] FROM @UserOrgs);

DECLARE @AvailableOrgList TABLE (org_id INT);
DECLARE @currentOrg INT; 

WHILE (SELECT COUNT(1) FROM @UserOrgs) > 0
BEGIN 
SET @currentOrg = (SELECT TOP 1 [org_id] FROM @UserOrgs);

WITH RecursiveOrg (Id, parentID) AS (
    SELECT
        o.Id,
        parent_organization_id
    FROM
        [dbo].[Organizations] o
    WHERE
        o.Id = @currentOrg
    UNION
    ALL
    SELECT
        o.Id,
        o.parent_organization_id
    FROM
        [dbo].[Organizations] o
        INNER JOIN RecursiveOrg r ON o.parent_organization_id = r.Id
)

INSERT INTO @AvailableOrgList
SELECT 
DISTINCT 
	[Id]
FROM RecursiveOrg
WHERE Id NOT IN (SELECT [org_id] FROM @AvailableOrgList);

  DELETE FROM @UserOrgs 
  WHERE [org_id] = @currentOrg;
END

INSERT INTO #Complains
SELECT
  [Complain].[Id],
  [Complain].[registration_date],
  [ComplainTypes].[name] AS [complain_type_name],
  [Complain].[culpritname],
  [Complain].[guilty],
  [Complain].[text],
  [Workers].[name] AS [user_name]
FROM
  [dbo].[Complain] [Complain] 
  INNER JOIN [dbo].[Positions] [Positions] ON [Complain].guilty = [Positions].programuser_id
	AND [Positions].organizations_id IN (SELECT [org_id] FROM @AvailableOrgList)
  LEFT JOIN [dbo].[ComplainTypes] [ComplainTypes] ON [ComplainTypes].Id = [Complain].complain_type_id
  LEFT JOIN [dbo].[Workers] [Workers] ON [Workers].worker_user_id = [Complain].[user_id];

END

SELECT 
	[Id],
	[registration_date],
	[complain_type_name],
	[culpritname],
	CASE WHEN u.UserId IS NOT NULL 
		 THEN ltrim(u.LastName) + SPACE(1) + u.FirstName
	ELSE [guilty]
	END AS [guilty],
	[text],
	[user_name] 
FROM #Complains c
LEFT JOIN [#system_database_name#].dbo.[User] u ON u.UserId = c.guilty
WHERE
#filter_columns#
#sort_columns#
OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY 
 ;
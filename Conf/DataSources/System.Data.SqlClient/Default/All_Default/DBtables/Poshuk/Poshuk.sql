/*
DECLARE @user_id NVARCHAR(128) = N'29796543-b903-48a6-9399-4840f6eac396';
DECLARE @organization_id INT = 1;
DECLARE @appealNum NVARCHAR(400) = N'9-2';
*/
DECLARE @NumVals NVARCHAR(max) = REPLACE(@appealNum, N', ', N',');
DECLARE @NumsTab TABLE (Num NVARCHAR(50));
INSERT INTO @NumsTab(Num)
SELECT 
	[value] 
FROM STRING_SPLIT(@NumVals, ',');

DECLARE @Archive NVARCHAR(400) = '['+(SELECT TOP 1 [IP]+'].['+[DatabaseName]+'].' FROM [dbo].[SetingConnetDatabase] WHERE Code = N'Archive');

DECLARE @IsHere BIT = IIF(
   (
      SELECT
         COUNT(1)
      FROM
         dbo.Appeals
      WHERE
         registration_number IN (SELECT Num FROM @NumsTab)
   ) = 0,
   0,
   1
);

IF(@IsHere = 1)
BEGIN
	SET @Archive = SPACE(1);
END
DECLARE @Query NVARCHAR(MAX) =
N'DECLARE @NumVals NVARCHAR(max) = REPLACE(@appealNum, N'', '', N'','');
DECLARE @NumsTab TABLE (Num NVARCHAR(50));
INSERT INTO @NumsTab(Num)
SELECT 
	[value] 
FROM STRING_SPLIT(@NumVals, '','');

IF(@organization_id IS NULL)
BEGIN
SELECT 
@organization_id = [organizations_id]
FROM dbo.[Positions]
WHERE programuser_id = @user_id;
END

DECLARE @user_orgs TABLE (Id INT);
IF(@organization_id = 1)
BEGIN
INSERT INTO @user_orgs (Id)
SELECT 
	Id
FROM dbo.[Organizations];
END
ELSE 
BEGIN
WITH RecursiveOrg (Id, parentId) AS (
    SELECT
        o.Id,
        parent_organization_id
    FROM
        dbo.Organizations o
    WHERE
       o.Id = @organization_id
    UNION
    ALL
    SELECT
        o.Id,
        o.parent_organization_id
    FROM
        dbo.Organizations o
        INNER JOIN RecursiveOrg r ON o.parent_organization_id = r.Id
)

INSERT INTO @user_orgs (Id)
SELECT
DISTINCT 
	Id
FROM
    RecursiveOrg r ;
END

SELECT 
	assignment.[Id],
	CASE
      WHEN source.[name] = N''УГЛ'' 
		THEN N''УГЛ''
      WHEN source.[name] = N''Сайт/моб. додаток'' 
		THEN N''Електронні джерела''
      WHEN qtype.[emergency] = 1 
		THEN N''Пріоритетне''
      WHEN qtype.[parent_organization_is] = 1 
		THEN N''Зауваження''
      ELSE N''Інші доручення''
    END navigation,
	question.[registration_number],
	state.[name] AS states,
	qtype.[name] AS QuestionType,
	applicant.[full_name] AS zayavnyk,
	appeal_object.[name] AS adress,
	execute_org.[short_name] AS vykonavets,
	question.[control_date],
	applicant.[ApplicantAdress] AS zayavnyk_adress,
	question.[question_content] AS zayavnyk_zmist,
	balans_org.[short_name] AS balans_name
FROM '+@Archive+N'[dbo].[Appeals] appeal
INNER JOIN '+@Archive+N'[dbo].[Questions] question ON appeal.Id = question.appeal_id
INNER JOIN '+@Archive+N'[dbo].[Assignments] assignment ON assignment.question_id = question.Id
LEFT JOIN [dbo].[ReceiptSources] source ON source.Id = appeal.receipt_source_id
LEFT JOIN [dbo].[QuestionTypes] qtype ON qtype.Id = question.question_type_id
LEFT JOIN [dbo].[AssignmentStates] state ON state.Id = assignment.assignment_state_id
LEFT JOIN [dbo].[Applicants] applicant ON applicant.Id = appeal.applicant_id
LEFT JOIN [dbo].[Objects] appeal_object ON appeal_object.Id = question.object_id 
LEFT JOIN [dbo].[Organizations] execute_org ON execute_org.Id = assignment.executor_organization_id
LEFT JOIN [dbo].[Buildings] building ON building.Id = appeal_object.builbing_id
LEFT JOIN [dbo].[ExecutorInRoleForObject] balans ON balans.building_id = building.Id
	AND [executor_role_id]=1
LEFT JOIN [dbo].[Organizations] balans_org ON balans_org.Id = balans.executor_id
WHERE appeal.[registration_number] IN (SELECT 
										 [Num]
									 FROM @Numstab)
AND assignment.[executor_organization_id] IN (SELECT 
												  [Id]
											  FROM @user_orgs);
';

  EXEC sp_executesql @Query, N'@appealNum NVARCHAR(400), @user_id NVARCHAR(128), @organization_id INT ', 
							@appealNum = @appealNum,
							@organization_id = @organization_id,
							@user_id = @user_id ;
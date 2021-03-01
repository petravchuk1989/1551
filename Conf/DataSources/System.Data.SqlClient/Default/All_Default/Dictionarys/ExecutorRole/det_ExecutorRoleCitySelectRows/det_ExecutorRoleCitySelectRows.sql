--DECLARE @executor_role_id int = 1;
SELECT
    [ExecutorInRoleForObject].Id,
    [ExecutorInRoleForObject].executor_role_id,
    [ExecutorRole].name ExecutorRole,
    [City].Id CityId,
    [City].name City,
    [ExecutorInRoleForObject].executor_id,
    [Organizations].Id OrganizationsId,
    [Organizations].[short_name] OrganizationsName
FROM
      [dbo].[ExecutorInRoleForObject]
    LEFT JOIN   [dbo].[ExecutorRole] ON [ExecutorInRoleForObject].executor_role_id = [ExecutorRole].Id
    LEFT JOIN   [dbo].[City] ON [ExecutorInRoleForObject].city_id = City.id
    LEFT JOIN   [dbo].[Organizations] ON [ExecutorInRoleForObject].executor_id = [Organizations].Id
WHERE
    [city_id] IS NOT NULL
    AND [ExecutorInRoleForObject].executor_role_id = @executor_role_id
    AND [Organizations].active = 1
    AND #filter_columns#
        #sort_columns#
    OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY
--DECLARE @executor_role_id int = 1;
SELECT
  [ExecutorInRoleForObject].Id,
  [ExecutorInRoleForObject].executor_role_id,
  [ExecutorRole].name ExecutorRole,
  [Districts].Id DistrictId,
  [Districts].name District,
  [ExecutorInRoleForObject].executor_id,
  [Organizations].Id OrganizationsId,
  [Organizations].[short_name] OrganizationsName
FROM
    [dbo].[ExecutorInRoleForObject]
  LEFT JOIN   [dbo].[ExecutorRole] ON [ExecutorInRoleForObject].executor_role_id = [ExecutorRole].Id
  LEFT JOIN   [dbo].[Districts] ON [ExecutorInRoleForObject].district_id = Districts.id
  LEFT JOIN   [dbo].[Organizations] ON [ExecutorInRoleForObject].executor_id = [Organizations].Id
WHERE
  [district_id] IS NOT NULL
  AND [ExecutorInRoleForObject].executor_role_id = @executor_role_id
  AND [Organizations].active = 1
  AND #filter_columns#
      #sort_columns#
  OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY
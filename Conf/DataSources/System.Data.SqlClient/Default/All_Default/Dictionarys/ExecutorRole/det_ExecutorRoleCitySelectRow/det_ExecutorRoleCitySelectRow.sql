 -- det_ExecutorRoleCitySelectRow

 select [ExecutorInRoleForObject].Id, [ExecutorInRoleForObject].executor_role_id, [ExecutorRole].name ExecutorRole, [City].Id [City_id], 
  [City].name City, [ExecutorInRoleForObject].executor_id,
  [Organizations].Id OrganizationsId, [Organizations].[short_name] OrganizationsName
  from   [dbo].[ExecutorInRoleForObject]
  left join   [dbo].[ExecutorRole] on [ExecutorInRoleForObject].executor_role_id=[ExecutorRole].Id
  left join   [dbo].[City] on [ExecutorInRoleForObject].city_id=City.id
  left join   [dbo].[Organizations] on [ExecutorInRoleForObject].executor_id=[Organizations].Id
  where [ExecutorInRoleForObject].Id=@Id
  select [ExecutorInRoleForObject].Id, [ExecutorRole].name conn_type_name
  , [ExecutorRole].Id conn_type_id
  , [Organizations].short_name
  , [Organizations].Id as org_id
  , [Objects].Id object_id
  from   [dbo].[ExecutorInRoleForObject]
  left join   [dbo].[ExecutorRole] on [ExecutorInRoleForObject].executor_role_id=[ExecutorRole].Id
  left join   [dbo].[Organizations] on [ExecutorInRoleForObject].executor_id=[Organizations].Id
  inner join   [dbo].[Objects] on [ExecutorInRoleForObject].[object_id]=[Objects].[Id]

  where [ExecutorInRoleForObject].Id=@Id

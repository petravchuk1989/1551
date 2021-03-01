 --declare @Id int = 56408;

  select [ExecutorInRoleForObject].Id, [ExecutorInRoleForObject].[executor_role_id], 
  [ExecutorRole].name ExecutorRole, 
  [ExecutorInRoleForObject].object_id as building_id,
  [Buildings].name Building,
  [ObjectTypes].name ObjectType,
  [ExecutorInRoleForObject].executor_id [organization_id],
  [Objects].name ObjectName,
  [Organizations].short_name
  from   [dbo].[ExecutorInRoleForObject]
  inner join   [dbo].[Buildings] on [ExecutorInRoleForObject].object_id=[Buildings].Id
  inner join   [dbo].[Objects] on [Buildings].Id=[Objects].builbing_id
  left join   [dbo].[ExecutorRole] on [ExecutorInRoleForObject].executor_role_id=[ExecutorRole].Id
  left join   [dbo].[ObjectTypes] on [Objects].object_type_id=[ObjectTypes].Id
  left join   [dbo].[Organizations] on [ExecutorInRoleForObject].executor_id=[Organizations].Id
  where [Objects].object_type_id=1 and [ExecutorInRoleForObject].Id=@Id
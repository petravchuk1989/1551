 --declare @organization_id int =2000;

  select [ExecutorInRoleForObject].Id, [ExecutorRole].name ConnectionType, [ObjectTypes].name ObjectType,
  [Objects].name ObjectName
  from   [dbo].[ExecutorInRoleForObject]
  left join   [dbo].[Buildings] on [ExecutorInRoleForObject].object_id=[Buildings].Id
  inner join   [dbo].[Objects] on [Buildings].Id=[Objects].builbing_id
  left join   [dbo].[ExecutorRole] on [ExecutorInRoleForObject].executor_role_id=[ExecutorRole].Id
  left join   [dbo].[ObjectTypes] on [Objects].object_type_id=[ObjectTypes].Id
  where  
  #filter_columns# and
  [Objects].object_type_id=1 and [ExecutorInRoleForObject].executor_id=@organization_id

  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only

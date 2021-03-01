 -- det_ExecutorRoleBuildingSelectRow
 -- declare @Id int =1;

 select [ExecutorInRoleForObject].Id, [ExecutorInRoleForObject].executor_role_id, [ExecutorRole].name ExecutorRole, [Buildings].Id [build_id], 
  [StreetTypes].shortname+N' '+[Streets].name+N', '+[Buildings].name Building, 
  
  [ExecutorInRoleForObject].executor_id,
  [Organizations].Id OrganizationsId, [Organizations].[short_name] OrganizationsName
  from   [dbo].[ExecutorInRoleForObject]
  left join   [dbo].[ExecutorRole] on [ExecutorInRoleForObject].executor_role_id=[ExecutorRole].Id
  left join   [dbo].[Buildings] on [ExecutorInRoleForObject].object_id=Buildings.id
  left join   [dbo].[Streets] on [Buildings].street_id=[Streets].id
  left join   [dbo].[StreetTypes] on [Streets].street_type_id=[StreetTypes].Id
  left join   [dbo].[Organizations] on [ExecutorInRoleForObject].executor_id=[Organizations].Id
  where [ExecutorInRoleForObject].Id=@Id
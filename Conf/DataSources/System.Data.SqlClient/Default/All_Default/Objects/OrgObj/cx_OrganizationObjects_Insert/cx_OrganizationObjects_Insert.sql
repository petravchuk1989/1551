
INSERT INTO   [dbo].[ExecutorInRoleForObject]
  (
      [executor_role_id]
      ,[executor_id]
      ,[object_id]
  )
SELECT @conn_type_id, @org_id, @object_id;


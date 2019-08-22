  -- det_ExecutorRoleBuildingInsertRow

  insert into [CRM_1551_Analitics].[dbo].[ExecutorInRoleForObject]
  (
  [building_id]
      ,[executor_role_id]
      ,[executor_id]
  )

  select 
      @build_id
      ,@executor_role_id
      ,@executor_id
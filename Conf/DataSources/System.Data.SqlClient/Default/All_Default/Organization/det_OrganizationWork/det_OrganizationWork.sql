select [Workers].id, [Workers].name, [Workers].phone_number, [Workers].position, 
[Workers].active, [Workers].worker_user_id, [Roles].Id [roles_id], [Roles].[name] roles_name
  from   [dbo].[Workers]
  left join   [dbo].[Roles] on [Workers].roles_id=[Roles].Id
  where [Workers].id=@id
SELECT [Id]
      ,[name]
      ,[Id] RulesId
      ,ltrim(Id)+N'-'+[name] [Idname]
  FROM   [dbo].[Rules]
  where id=@Id
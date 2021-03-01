select [Id]
      ,[reportcode]
      ,[diagramcode]
      ,[content]
      ,[valuecode]
  from [CRM_1551_Site_Integration].[dbo].[ReportsInfo]
  where [Id]=@Id
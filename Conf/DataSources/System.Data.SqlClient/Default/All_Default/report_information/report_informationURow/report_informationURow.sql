update [CRM_1551_Site_Integration].[dbo].[ReportsInfo]
	set 
		[reportcode]=@reportcode
      ,[diagramcode]=@diagramcode
      ,[content]=@content
      ,[valuecode]=@valuecode
      --,[user_id]
      --,[add_date]
      ,[user_edit_id]=@user_id
      ,[edit_date]=getutcdate()
	where Id=@Id
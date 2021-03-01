
update [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  set [EditByDate]=getutcdate()
      ,[EditByUserId]=@user_Id
  where Id=@Id
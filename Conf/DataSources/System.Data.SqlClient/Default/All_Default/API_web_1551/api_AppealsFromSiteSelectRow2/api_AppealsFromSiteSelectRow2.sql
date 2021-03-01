-- select Id, [appeal_id]
--  from   [dbo].[AppealsFromSite]
select Id, [Appeal_Id]
 from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
 where [AppealsFromSite].Id=@Id
 
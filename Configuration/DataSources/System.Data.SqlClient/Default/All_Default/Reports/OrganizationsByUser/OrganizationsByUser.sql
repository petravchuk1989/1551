 -- declare @user_id nvarchar(128) = 'dc61a839-2cbc-4822-bfb5-5ca157487ced'

; WITH RecursiveOrg 
 (Id, parentID, orgName)
AS
    (
    SELECT o.Id, parent_organization_id, short_name
    FROM Organizations o
	join Positions p on p.organizations_id = o.Id
    WHERE p.programuser_id = @user_id
    UNION ALL
    SELECT o.Id, o.parent_organization_id, o.short_name
    FROM Organizations o
        JOIN RecursiveOrg r ON o.parent_organization_id = r.Id
         )
          SELECT distinct 
          Id, 
          parentID, 
          orgName
          Into #orgList
          FROM RecursiveOrg r

		  Select 
		  Id, orgName 
		  from #orgList 
		  where #filter_columns#
                #sort_columns#
          offset @pageOffsetRows rows fetch next @pageLimitRows rows only
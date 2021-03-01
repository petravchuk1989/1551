

--declare @Id int =7

select [Organizations].Id, [OrganizationTypes].Id organization_type_id, [OrganizationTypes].name OrganizationType, [Organizations2].Id organization_id, [Organizations2].short_name ParentOrganization, [Organizations].short_name, [Organizations].name,
  [Organizations].phone_number, [Organizations].address, [Organizations].head_name, [Organizations].population, [Organizations].active
      ,[Organizations].[edit_date]
      ,[Organizations].[user_edit_id]
	  ,[Organizations].organization_code, [Organizations].programworker, [Positions].Id positions_id, 
	  [Positions].[name]+ISNULL(N' ('+[Organizations3].short_name+N')', N'') positions_name
	  ,[Organizations].[notes]
      ,[Organizations].[othercontacts]
      ,[Organizations].Id organization_id_id
  from   [dbo].[Organizations]
  left join   [dbo].[OrganizationTypes] on [Organizations].organization_type_id=[OrganizationTypes].Id
  left join   [dbo].[Organizations] [Organizations2] on [Organizations].parent_organization_id=[Organizations2].Id
  left join   [dbo].[OrganizationInResponsibility] on [Organizations].Id=[OrganizationInResponsibility].organization_id
  left join   [dbo].[Positions] on [OrganizationInResponsibility].position_id=[Positions].Id
  left join [dbo].[Organizations] [Organizations3] on [Positions].organizations_id=[Organizations3].Id
  where [Organizations].Id=@Id
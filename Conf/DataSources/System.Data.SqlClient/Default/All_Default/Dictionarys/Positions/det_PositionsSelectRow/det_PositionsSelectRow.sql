select [OrganizationInResponsibility].Id, [Positions].Id position_id, [Positions].position, [Organizations].Id organization_id,
  [Organizations].short_name
  from   [dbo].[OrganizationInResponsibility]
  inner join   [dbo].[Positions] on [OrganizationInResponsibility].position_id=[Positions].Id
  inner join   [dbo].[Organizations] on [OrganizationInResponsibility].organization_id=[Organizations].Id
  where [OrganizationInResponsibility].Id= @Id
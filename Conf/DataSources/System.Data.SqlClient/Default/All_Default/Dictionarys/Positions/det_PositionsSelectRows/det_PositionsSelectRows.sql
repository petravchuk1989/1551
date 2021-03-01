select [OrganizationInResponsibility].Id, [Organizations].address, [Organizations].short_name
  from /*  [dbo].[Positions]
  inner join*/   [dbo].[OrganizationInResponsibility] /*on [Positions].Id=[OrganizationInResponsibility].position_id*/
  inner join   [dbo].[Organizations] on [OrganizationInResponsibility].organization_id=[Organizations].Id
  where [OrganizationInResponsibility].position_id=@position_id
   and #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
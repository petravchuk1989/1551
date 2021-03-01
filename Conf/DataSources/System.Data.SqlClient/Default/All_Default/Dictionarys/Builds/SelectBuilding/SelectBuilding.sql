  select [Buildings].Id, [Districts].Id district_id, 
  [Districts].name DistrictName, Streets.Id street_id, 
  Streets.name StreetName, [Buildings].is_active isActive,
  [Buildings].number, [Buildings].letter,
  [StreetTypes].shortname+N' '+[Streets].name+N', '+[Buildings].name full_name, 
  [Buildings].[bsecondname] bsecondname, [Buildings].[index] 'index'
  
  from   [dbo].[Buildings] left join   [dbo].[Districts] on [Buildings].district_id=[Districts].Id
  left join   [dbo].[Streets] on [Buildings].street_id=Streets.Id
  left join   [dbo].[StreetTypes] on [Streets].street_type_id=[StreetTypes].Id
  where [Buildings].Id = @Id
  and #filter_columns#
  #sort_columns#
 --offset @pageOffsetRows rows fetch next @pageLimitRows rows only
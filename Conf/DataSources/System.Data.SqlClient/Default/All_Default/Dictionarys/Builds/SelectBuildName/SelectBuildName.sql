  select [Buildings].Id,
  [StreetTypes].shortname+N' '+[Streets].name+N', '+[Buildings].name full_name
  
  from   [dbo].[Buildings] left join   [dbo].[Districts] on [Buildings].district_id=[Districts].Id
  left join   [dbo].[Streets] on [Buildings].street_id=Streets.Id
  left join   [dbo].[StreetTypes] on [Streets].street_type_id=[StreetTypes].Id
  where [Buildings].Id = @Id
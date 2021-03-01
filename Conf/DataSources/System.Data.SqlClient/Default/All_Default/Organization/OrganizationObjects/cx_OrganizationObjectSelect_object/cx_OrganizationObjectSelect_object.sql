select [Objects].[Id], [Objects].name ObjectName, 
--[Districts].name District, [Streets].name Street, [ObjectTypes].name ObjectType,
[Objects].builbing_id,
[Districts].name+N' район,'+case when [Streets].name is not null then + ' ' + StreetTypes.name + ' '+[Streets].name + ', '  else N'' end+
case when [Buildings].number is not null then N' буд. '+rtrim([Buildings].name) end adress

  from   [dbo].[Objects]
  left join   [dbo].[Buildings] on [Objects].builbing_id=[Buildings].Id
  left join   [dbo].[Districts] on [Buildings].district_id=[Districts].Id
  left join   [dbo].[Streets] on [Buildings].street_id=[Streets].Id
  left join   [dbo].[ObjectTypes] on [Objects].object_type_id=[ObjectTypes].Id
  left join   [dbo].[StreetTypes] on Streets.street_type_id = StreetTypes.Id
  where [Objects].[object_type_id]=1 and 
  #filter_columns#
  order by [Objects].name desc
  --#sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only

/*select [Objects].[Id], [Objects].name ObjectName, [Districts].name District, [Streets].name Street, [ObjectTypes].name ObjectType
  from   [dbo].[Objects]
  left join   [dbo].[Buildings] on [Objects].builbing_id=[Buildings].Id
  left join   [dbo].[Districts] on [Buildings].district_id=[Districts].Id
  left join   [dbo].[Streets] on [Buildings].street_id=[Streets].Id
  left join   [dbo].[ObjectTypes] on [Objects].object_type_id=[ObjectTypes].Id
  --order by [Objects].name desc
  where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
 */


select 1 Id,
  sum(case when [CityName]=N'Київ' then 1 else 0 end) in_Kyiv,
  sum(case when [CityName]<>N'Київ' then 1 else 0 end) in_not_Kyiv
  /*
  Id
  in_Kyiv
  in_not_Kyiv
  */
  from
  (
  select Id, [ApplicantFromSiteId], [CityName],
  row_number() over (partition by [ApplicantFromSiteId] order by case when [AddressTypeId]=1 /*місце проживання*/ then 1 else 2 end, Id desc) n
  from [CRM_1551_Site_Integration].[dbo].[ApplicantFromSiteAddresses]
  ) t
  where n=1
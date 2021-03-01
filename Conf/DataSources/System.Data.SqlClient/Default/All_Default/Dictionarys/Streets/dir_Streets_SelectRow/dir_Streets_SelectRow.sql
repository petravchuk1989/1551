SELECT
  s.[Id],
  s.[name],
  d.[name] AS district,
  st.[name] AS streetTypeName,
  st.[Id] AS streetTypeId
   --   ,[old_name]
FROM
  [dbo].[Streets] s
  LEFT JOIN [dbo].[Districts] d ON s.district_id = d.Id
  LEFT JOIN [dbo].[StreetTypes] st ON st.id = s.street_type_id
WHERE
  s.Id = @Id ;
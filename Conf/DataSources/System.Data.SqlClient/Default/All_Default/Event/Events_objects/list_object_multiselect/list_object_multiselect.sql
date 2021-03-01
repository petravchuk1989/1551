SELECT 
	[Id],
	[object_name]
FROM (
SELECT
TOP 50 
	 [Objects].[Id],
			IIF(
				[Objects].[name] IS NULL,
				concat(
					ObjectTypes.[name],
					' : ',
					Streets.[name],
					' ',
					Buildings.[number],
					Buildings.[letter]
				),
				IIF(
					Buildings.street_id IS NULL,
					[Objects].[name],
					concat(
						ObjectTypes.[name],
						' : ',
						Streets.[name],
						' ',
						Buildings.[number],
						Buildings.[letter],
						' ( ',
						[Objects].[name],
						' )'
					)
				)
			) AS [object_name]
FROM [dbo].[Objects] [Objects]
LEFT JOIN [dbo].[Buildings] [Buildings] ON [Buildings].Id = [Objects].builbing_id
LEFT JOIN [dbo].[Streets] [Streets] ON [Streets].Id = [Buildings].street_id
LEFT JOIN [dbo].[ObjectTypes] [ObjectTypes] ON [ObjectTypes].Id = [Objects].object_type_id
LEFT JOIN [dbo].[Districts] [Districts] ON [Districts].Id = [Buildings].district_id
LEFT JOIN [dbo].[StreetTypes] [StreetTypes] ON [StreetTypes].Id = [Streets].street_type_id
WHERE [Objects].object_type_id = 1
AND #filter_columns#
) sub
ORDER BY 2
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY
;
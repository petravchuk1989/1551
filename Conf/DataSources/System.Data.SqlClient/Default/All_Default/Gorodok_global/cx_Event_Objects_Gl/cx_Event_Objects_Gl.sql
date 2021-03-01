--declare @Id int = 8;
SELECT
   o.Id,
   [Districts].name [district_name],
   [ObjectTypes].name obj_type_name,
   o.name [object_name]
FROM
   [CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_global] AS gl
   JOIN [CRM_1551_GORODOK_Integrartion].[dbo].[AllObjectInClaim] AS oc ON oc.claims_number_id = gl.claim_number
   JOIN [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses] gh ON gh.gorodok_houses_id = oc.object_id
   JOIN [dbo].[Objects] AS o ON o.builbing_id = gh.[1551_houses_id]
   JOIN [dbo].[ObjectTypes] ON o.object_type_id = [ObjectTypes].Id
   JOIN [dbo].[Buildings] ON o.builbing_id = [Buildings].Id
   JOIN [dbo].[Districts] ON [Buildings].district_id = [Districts].Id
WHERE
   gl.claim_number = @Id
   AND #filter_columns#
       #sort_columns#
   OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY ;
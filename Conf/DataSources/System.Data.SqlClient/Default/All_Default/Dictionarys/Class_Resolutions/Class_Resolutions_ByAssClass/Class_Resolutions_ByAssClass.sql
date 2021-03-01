-- DECLARE @assignment_class_id INT;	

SELECT	
    [Id],	
    [name]	
FROM	
    dbo.Class_Resolutions	
WHERE	
    [assignment_class_id] = @assignment_class_id
AND #filter_columns#
ORDER BY 1 	
OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY; 
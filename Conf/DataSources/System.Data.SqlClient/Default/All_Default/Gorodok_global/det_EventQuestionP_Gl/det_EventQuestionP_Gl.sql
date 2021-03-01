-- DECLARE @Id INT = 6557176;

SET NOCOUNT ON;

SELECT
	q.Id,
	q.registration_number,
	q.registration_date,
	Organizations.short_name AS org_name
FROM
	[CRM_1551_GORODOK_Integrartion].[dbo].[Lokal_copy_gorodok_global] AS gl
	JOIN dbo.Event_Class AS es ON es.name = gl.claims_type
	JOIN dbo.EventClass_QuestionType AS eq ON eq.event_class_id = es.id
	JOIN dbo.QuestionTypes qt ON qt.Id = eq.question_type_id
	JOIN [CRM_1551_GORODOK_Integrartion].[dbo].[AllObjectInClaim] AS oc ON oc.claims_number_id = gl.claim_number
	JOIN [CRM_1551_GORODOK_Integrartion].[dbo].[Gorodok_1551_houses] gh ON gh.gorodok_houses_id = oc.object_id
	JOIN [dbo].[Objects] AS o ON o.builbing_id = gh.[1551_houses_id]
	LEFT JOIN Questions AS q ON q.question_type_id = qt.Id
	AND q.[object_id] = o.id
	LEFT JOIN Assignments ON Assignments.Id = q.last_assignment_for_execution_id
	LEFT JOIN Organizations ON Organizations.Id = Assignments.executor_organization_id
WHERE
	gl.claim_number = @Id
	AND CONVERT(
		DATETIME,
		CONVERT(DATETIMEOFFSET(4), q.registration_date) AT TIME ZONE N'FLE Standard Time'
	) BETWEEN DATEADD(HOUR, -6, gl.registration_date)
	AND gl.registration_date
	AND eq.[is_hard_connection] = 0 
	--AND Assignments.main_executor = 1
	--AND Assignments.assignment_state_id <> 5
	AND #filter_columns#
		#sort_columns#
	OFFSET @pageOffsetRows ROWS FETCH next @pageLimitRows ROWS ONLY;
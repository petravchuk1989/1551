-- DECLARE @class_resolution_id INT = 1;

DECLARE @assignment_result_id INT,
		@assignment_resolution_id INT,
		@assignment_state_id INT;

SELECT 
	@assignment_result_id = assignment_result_id,
	@assignment_resolution_id = assignment_resolution_id
FROM dbo.[Class_Resolutions]
WHERE Id = @class_resolution_id;

SELECT TOP 1
		@assignment_state_id = [new_assignment_state_id]
		FROM [dbo].[TransitionAssignmentStates] 
WHERE new_assignment_resolution_id = @assignment_resolution_id 
AND new_assignment_result_id = @assignment_result_id;

SELECT @assignment_result_id AS assignment_result_id, 
	   [result].[name] AS assignment_result_name,
	   @assignment_resolution_id AS assignment_resolution_id,
	   [resolution].[name] AS assignment_resolution_name,
	   @assignment_state_id AS assignment_state_id,
	   [state].[name] AS assignment_state_name
FROM dbo.AssignmentResults [result]
LEFT JOIN dbo.AssignmentResolutions [resolution] ON [resolution].Id = @assignment_resolution_id
LEFT JOIN dbo.AssignmentStates [state] ON [state].Id = @assignment_state_id
WHERE [result].Id = @assignment_result_id;
DECLARE @output_con TABLE (Id INT);
DECLARE @new_con INT;
DECLARE @result_id INT;
DECLARE @resolution_id INT;
DECLARE @current_consid INT;
DECLARE @ass_state_id INT;
SELECT
	@ass_state_id = assignment_state_id,
	@result_id = AssignmentResultsId,
	@resolution_id = AssignmentResolutionsId,
	@current_consid = current_assignment_consideration_id
FROM
	dbo.Assignments
WHERE
	Id = @Id;

IF(
	@current_edit_date <> (
		SELECT
			edit_date
		FROM
			dbo.[Assignments]
		WHERE
			Id = @Id
	)
) 
BEGIN 
	RAISERROR(
	N'У дорученні відбулися зміни, оновіть сторінку',
	16,
	1
);
RETURN;
END
ELSE 
BEGIN
-- 	if @result_id = 1 and @resolution_id is null and @executor_organization_id is not null
IF @executor_organization_id IS NOT NULL 
BEGIN 
-- 	if @executor_organization_id <> (select organization_id from Assignments where Id = @Id)
-- 	begin
UPDATE
	[dbo].[Assignments]
SET
	--[assignment_state_id]= @ass_state_id 
	[executor_organization_id] = @executor_organization_id, -- новый исполнитель на кого переопределили  
	[edit_date] = getutcdate(),
	[user_edit_id] = @user_edit_id,
	[LogUpdated_Query] = N'Button_Nadiishlo_Rozpodility_Row24' --,[AssignmentResultsId] = @result_id
	--, AssignmentResolutionsId= @resolution_id
WHERE
	Id = @Id;
UPDATE
	dbo.AssignmentConsiderations
SET
	[edit_date] = getutcdate(),
	[user_edit_id] = @user_edit_id,
	[consideration_date] = getutcdate()
WHERE
	Id = @current_consid;
DELETE FROM
	@output_con;
INSERT INTO
	dbo.AssignmentConsiderations (
		[assignment_id],
		[consideration_date],
		[assignment_result_id],
		[assignment_resolution_id],
		[user_id],
		[edit_date],
		[user_edit_id],
		[first_executor_organization_id],
		create_date,
		transfer_date
	) output inserted.Id INTO @output_con([Id])
VALUES
(
		@Id,
		GETUTCDATE(),
		@result_id,
		@resolution_id,
		@user_edit_id,
		GETUTCDATE(),
		@user_edit_id,
		@executor_organization_id -- новый исполнитель на кого переопределили
,
		GETUTCDATE(),
		GETUTCDATE()
	);
SET
	@new_con = (
		SELECT
			TOP (1) Id
		FROM
			@output_con
	);
UPDATE
	dbo.[Assignments]
SET
	current_assignment_consideration_id = @new_con,
	[edit_date] = GETUTCDATE()
WHERE
	Id = @Id; -- 	end
END
END
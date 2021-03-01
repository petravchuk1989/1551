DECLARE @output TABLE (Id INT);

DECLARE @ActionCode NVARCHAR(50);
SET @ActionCode = (SELECT top 1 [Code] 
                   FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Actions]
                   WHERE Id = @Action)



INSERT INTO [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ServiceTypesTexts_ToSend] 
    ([ExternalSendServiceId]
      ,[ServiceTypeId]
      ,[Action]
      ,[Title]
      ,[UseClaimTypeTitle]
      ,[Description]
      ,[UseClaimTypeDescription]
      ,[Description_without_Executor]
      ,[Text]
      ,[UseClaimTypeText]
      ,[Text_without_Executor]
      ,[Text_without_PlanDate]
      ,[Text_without_Executor_PlanDate]
      ,[user_created_id]
      ,[created_at]
      ,[user_updated_id]
      ,[updated_at]
      ,[IsActive])
output [inserted].[Id] INTO @output (Id)
VALUES
  (
    1 /*ExternalSendServiceId*/
    ,@ServiceTypeId
    ,@ActionCode
    ,@Title
    ,@UseClaimTypeTitle
    ,@Description  
    ,@UseClaimTypeDescription
    ,@Description_without_Executor
    ,@Text
    ,@UseClaimTypeText
    ,@Text_without_Executor
    ,@Text_without_PlanDate
    ,@Text_without_Executor_PlanDate
    ,@user_id
    ,getutcdate()
    ,@user_id
    ,getutcdate()
    ,@IsActive
  );

DECLARE @row_id INT;

SET
  @row_id =(
    SELECT
      TOP 1 Id
    FROM
      @output
  );


SELECT
  @row_id AS [Id];

RETURN;
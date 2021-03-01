
DECLARE @ActionCode NVARCHAR(50);
SET @ActionCode = (SELECT top 1 [Code] 
                   FROM [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_Actions]
                   WHERE Id = @Action)



UPDATE [CRM_1551_GORODOK_Integrartion].[dbo].[ServiceNotification_ServiceTypesTexts_ToSend] SET
      [ServiceTypeId] = @ServiceTypeId
      ,[Action] = @ActionCode
      ,[Title] = @Title
      ,[UseClaimTypeTitle] = @UseClaimTypeTitle
      ,[Description] = @Description
      ,[UseClaimTypeDescription] = @UseClaimTypeDescription
      ,[Description_without_Executor] = @Description_without_Executor
      ,[Text] = @Text
      ,[UseClaimTypeText] = @UseClaimTypeText
      ,[Text_without_Executor] = @Text_without_Executor
      ,[Text_without_PlanDate] = @Text_without_PlanDate
      ,[Text_without_Executor_PlanDate] = @Text_without_Executor_PlanDate
      ,[user_updated_id] = @user_id
      ,[updated_at] = getutcdate()
      ,[IsActive] = @IsActive
WHERE [Id] = @Id
      
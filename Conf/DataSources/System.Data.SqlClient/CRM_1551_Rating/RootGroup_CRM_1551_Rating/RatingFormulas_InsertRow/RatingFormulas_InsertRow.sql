DECLARE @OutId TABLE ( Id INT );

insert into [dbo].[Rating_ReferenceWeight_IntegratedMetric_PerformanceLevel] 
      ([Date_Start]
      ,[k1_name]
      ,[k1_value]
      ,[k1_isUse]
      ,[k2_name]
      ,[k2_value]
      ,[k2_isUse]
      ,[k3_name]
      ,[k3_value]
      ,[k3_isUse]
      ,[k4_name]
      ,[k4_value]
      ,[k4_isUse]
      ,[k5_name]
      ,[k5_value]
      ,[k5_isUse]
      ,[k6_name]
      ,[k6_value]
      ,[k6_isUse]
      ,[k7_name]
      ,[k7_value]
      ,[k7_isUse]
      ,[formula_id]
      ,[comment]
      ,[RatingId]
      ,[CreatedAt]
      ,[CreatedUserById]
      ,[UpdatedAt]
      ,[UpdatedUserById]
      )
output inserted.[Id] into @OutId(Id)
select @Date_Start
      ,@k1_name
      ,@k1_value
      ,@k1_isUse
      ,@k2_name
      ,@k2_value
      ,@k2_isUse
      ,@k3_name
      ,@k3_value
      ,@k3_isUse
      ,@k4_name
      ,@k4_value
      ,@k4_isUse
      ,@k5_name
      ,@k5_value
      ,@k5_isUse
      ,@k6_name
      ,@k6_value
      ,@k6_isUse
      ,@k7_name
      ,@k7_value
      ,@k7_isUse
      ,@formula_id
      ,@comment
      ,@RatingId
      ,getutcdate()
      ,@UpdatedUserById
      ,getutcdate()
      ,@UpdatedUserById


 SELECT TOP 1 Id FROM @OutId
INSERT INTO [dbo].[GorodokClaims]
           ([claim_number]
           ,[claim_state]
           ,[claim_type]
           ,[claim_content]
           ,[main_object_id]
           ,[executor]
           ,[start_date]
           ,[planned_end_date]
           ,[fact_end_date]
           ,[comment_executor]
           ,[global]
           ,[audio_start_date]
           ,[audio_end_date]
           ,[standart_audio]
           ,[say_liveAddress_id]
           ,[say_organization_id]
           ,[say_phone_for_information]
           ,[phone_for_information]
           ,[say_plan_end_date]
           ,[audio_on])
     VALUES
           (@claim_number
           ,@claim_state
           ,@claim_type
           ,@claim_content
           ,@main_object_id
           ,@executor
           ,@start_date
           ,@planned_end_date
           ,@fact_end_date
           ,@comment_executor
           ,@global
           ,@audio_start_date
           ,@audio_end_date
           ,@standart_audio
           ,@say_liveAddress_id
           ,@say_organization_id
           ,@say_phone_for_information
           ,@phone_for_information
           ,@say_plan_end_date
           ,@audio_on)
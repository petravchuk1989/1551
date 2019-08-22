UPDATE [dbo].[Objects]
        set [object_type_id]= @obj_type_id
           --,[district_id]= @district_id
           --,[street_id]= @street_id
           ,[name]= @object_name
           ,[builbing_id]= @builbing_id
           ,is_active = @is_active
		where Id = @Id
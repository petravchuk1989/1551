declare @output table (Id int)

INSERT INTO [dbo].[Objects]
           ([object_type_id]
        --   ,[district_id]
        --   ,[street_id]
           ,[name]
           ,[builbing_id]
           ,is_active
		   )
		output inserted.Id into @output(Id)
     VALUES
           (@obj_type_id
        --   ,@district_id
        --   ,@street_id
           ,@object_name
           ,@builbing_id
           ,1
		   )

	declare @obj_id int;
	set @obj_id = (select top 1 Id from @output)
	
select @obj_id as Id 
return;

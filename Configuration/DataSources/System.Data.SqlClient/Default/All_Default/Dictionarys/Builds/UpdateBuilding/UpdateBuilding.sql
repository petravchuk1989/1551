UPDATE [dbo].[Buildings]
   SET [district_id] = @district_id
    --   ,[street_id] = @street_id     
    --   ,[number] = @number
      ,[letter] = @letter
      ,[bsecondname] = @bsecondname 
      ,[name] = isnull(rtrim(@number),N'')+isnull(rtrim(' ' + @letter),N'')+
      isnull(rtrim(', к.'+ @bsecondname), N'')
      ,[index] = @index
      ,[is_active] = @isActive
 WHERE Id = @Id
 

update [Objects]
set name = (select 
	 st.shortname + ' ' + s.name +
					isnull(rtrim(', ' + number),N'')+
						isnull(rtrim(' '+ @letter),N'')+
							isnull(rtrim(', '+ @bsecondname), N'')
	from [Objects] as o
		left join Buildings as b on b.Id = o.builbing_id
		left join Streets as s on s.Id = b.street_id
		left join StreetTypes as st on st.Id = s.street_type_id
	where b.Id = @Id ),
	[is_active] = @isActive
	
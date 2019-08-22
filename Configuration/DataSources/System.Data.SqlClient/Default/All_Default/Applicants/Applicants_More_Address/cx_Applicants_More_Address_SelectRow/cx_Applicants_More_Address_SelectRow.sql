SELECT [LiveAddress].[Id]
	  ,[LiveAddress].applicant_id
	  ,Districts.name as districts_name
	  ,Districts.Id as districts_id
      ,Buildings.name as buildings_name
	  ,Buildings.Id as buildings_id
	  ,[LiveAddress].[flat]
      ,[LiveAddress].[house_block]
      ,[LiveAddress].[entrance]
      ,[LiveAddress].[main]
      ,[LiveAddress].[active]
  FROM [dbo].[LiveAddress]
	left join Applicants on Applicants.Id = LiveAddress.applicant_id
	left join Buildings on Buildings.Id	= LiveAddress.building_id
	left join Districts on Districts.Id = Buildings.district_id
  WHERE LiveAddress.Id = @Id
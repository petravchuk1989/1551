-- declare @applicant int = 1490958;

select 
full_name as Applicant_PIB,
b.Id as buildingId,
st.shortname + ' ' + s.[name] +  isnull(' ' + b.[name],'') buildingName,
house_block as Applicant_HouseBlock,
entrance as Applicant_Entrance,
flat as Applicant_Flat,
d.[name] as Applicant_District,
ap.Id as privilegeId,
ap.[Name] as privilegeName,
ss.Id as socialId,
ss.[name] as socialName,
--o.[short_name] as org
at.Id as applicantTypeId,
at.[name] as applicantTypeName,
a.sex as Applicant_Sex,
cast(a.birth_date as date) as Applicant_BirthDate,
a.mail as Applicant_Email,
a.comment as Applicant_Comment,
a.Id as ApplicantId,
IIF(
a.birth_date is not null,
year(getdate()) - year(a.birth_date),
null
) as Applicant_Age 

from Applicants a
join LiveAddress la on la.applicant_id = a.Id 
left join Buildings b on b.Id = la.building_id
left join Streets s on s.Id = b.street_id
left join StreetTypes st on st.Id = s.street_type_id
left join Districts d on d.Id = s.district_id
left join SocialStates ss on ss.Id = a.social_state_id
left join ApplicantPrivilege ap on ap.Id = a.applicant_privilage_id
left join ApplicantTypes at on at.Id = a.applicant_type_id

where a.Id = @applicantId 
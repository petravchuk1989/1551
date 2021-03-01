--declare @zayiavnykId int = 20;
--declare @questionId int =1034;
declare @question_content nvarchar(500)=
(select [question_content]
  FROM   [dbo].[Questions]
  where Id=@questionId);

select [LiveAddress].Id, N'вул. '+[Streets].name+N', буд. '+ [Buildings].name+ 
  case when [Buildings].letter is not null then [Buildings].letter else N'' end
  +case when [LiveAddress].house_block is not null then N', корпус '+[LiveAddress].house_block else N'' end+
  case when [LiveAddress].entrance is not null then N', парадне '+convert(nvarchar(200),[LiveAddress].entrance) else N'' end+
  case when [LiveAddress].flat is not null then N', кв. '+convert(nvarchar(200), [LiveAddress].flat) else N'' end address,
  @question_content comment
  from   [dbo].[LiveAddress]-- left join   [dbo].[Applicants] on [LiveAddress].applicant_id=[Applicants].Id
  left join   [dbo].[Buildings] on [LiveAddress].building_id=[Buildings].Id
  left join   [dbo].[Streets] on [Buildings].street_id=[Streets].Id
  where [LiveAddress].applicant_id=@zayiavnykId
--declare @zayiavnykId int = 26;
--declare @questionId int =1029;

declare @comment nvarchar(300)=
(
select [AssignmentConsiderations].short_answer
  from   [dbo].[Assignments]
  inner join   [dbo].[Questions] on [Assignments].question_id=[Questions].Id
--   inner join   [dbo].[AssignmentConsiderations] on [Assignments].Id=[AssignmentConsiderations].assignment_id
  inner join   [dbo].[AssignmentConsiderations] on [Assignments].current_assignment_consideration_id=[AssignmentConsiderations].Id
  inner join   [dbo].[Appeals] on [Questions].appeal_id=[Appeals].Id
  --inner join 
  where [Questions].id=@questionId and [Appeals].applicant_id=@zayiavnykId
);


declare @question_content nvarchar(500)=
(select [question_content]
  FROM   [dbo].[Questions]
  where Id=@questionId);

  --select @question_content

select [LiveAddress].Id, [StreetTypes].shortname+N' '+[Streets].name+N' '+ [Buildings].name+ 
  case when [Buildings].letter is not null then [Buildings].letter else N'' end
  --+case when [LiveAddress].house_block is not null then N', корпус '+[LiveAddress].house_block else N'' end+
  --case when [LiveAddress].entrance is not null then N', п. '+convert(nvarchar(200),[LiveAddress].entrance) else N'' end+
  --case when [LiveAddress].flat is not null then N', кв. '+convert(nvarchar(200), [LiveAddress].flat) else N'' end 
  address,
  @question_content content, @comment comment
  from   [dbo].[LiveAddress]-- left join   [dbo].[Applicants] on [LiveAddress].applicant_id=[Applicants].Id
  left join   [dbo].[Buildings] on [LiveAddress].building_id=[Buildings].Id
  left join   [dbo].[Streets] on [Buildings].street_id=[Streets].Id
  left join   [dbo].[Districts] on [Buildings].district_id=[Districts].Id
  left join   [dbo].[StreetTypes] on [Streets].street_type_id=[StreetTypes].Id
  where [LiveAddress].applicant_id=@zayiavnykId
  select [Questions].Id, [Questions].question_content, [Organizations].name, [Questions].event_id
  from   [dbo].[Questions]
  left join   [dbo].[Assignments] on [Questions].last_assignment_for_execution_id=[Assignments].Id
  left join   [dbo].[Organizations] on [Assignments].executor_organization_id=[Organizations].Id
  where [Questions].event_id=@eventId
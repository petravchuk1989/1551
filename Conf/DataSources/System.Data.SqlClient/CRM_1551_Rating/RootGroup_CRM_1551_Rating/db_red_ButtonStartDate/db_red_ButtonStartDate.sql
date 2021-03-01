

 --declare @Ids nvarchar(500)=N'52, 53',
 --  --@user_Id nvarchar(128)=N'test',
 --  @DateStart datetime='2019-09-25 17:37:06.090'

  declare @table table (Id int)

  insert into @table (Id)
  select value n
  from string_split((select @Ids n), N',')

  --select * from @table
  /**/
  update [dbo].[Rating_EtalonDaysToExecution]
  set [DateStart]=@DateStart
  where Id in
  (
  


  select [Id]
  from
  (
select [Id], [QuestionTypeId]
  ,row_number() over (partition by [QuestionTypeId] order by ABS(DATEDIFF(DAY,[DateStart],CONVERT(DATE,GETUTCDATE()))), DATEDIFF(DAY,[DateStart],CONVERT(DATE,GETUTCDATE()))) n
  from [dbo].[Rating_EtalonDaysToExecution] with (nolock)
  ) t
  where n=1
  and [QuestionTypeId] in (select Id from @table)

  )
declare @output table (Id int)


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
declare @AppealNumberSeq int = NEXT VALUE FOR GenerateNumberSequence
--select @AppealNumberSeq


if not exists(
					select top 1 id
					from [dbo].[Appeals]
					where left(registration_number, 1) in (right(ltrim(year(getutcdate())),1))
					order by id desc
				)
begin
	ALTER SEQUENCE dbo.GenerateNumberSequence
	RESTART WITH 1;
	set @AppealNumberSeq = NEXT VALUE FOR GenerateNumberSequence
end

declare @AppealNumberSeqText nvarchar(50) = LTRIM(RIGHT(YEAR(getutcdate()),1))+N'-'+ltrim(@AppealNumberSeq)
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


INSERT INTO [dbo].[Appeals]
           ([registration_date]
           ,[registration_number]
           ,[receipt_source_id]
           ,[phone_number]
           ,[receipt_date]
           ,[start_date]
           ,[user_id]
           ,[edit_date]
           ,[user_edit_id]
           ,[sipcallid]
           ,[LogUpdated_Query])
output [inserted].[Id] into @output (Id)
     VALUES
           (getutcdate() --@registration_date
           --,@registration_number 222
		   --,concat( SUBSTRING ( rtrim(YEAR(getutcdate())),4,1),'-',(select count(Id)+1 from Appeals where year(Appeals.registration_date) = year(getutcdate())) )
            ,@AppealNumberSeqText
           ,@receipt_source_id
           ,@phone_number
           ,getutcdate() -- @receipt_date
           ,getutcdate() -- @start_date
           ,@user_id
           ,getutcdate() -- @edit_date
           ,@user_id
           ,@sipcallid
	      ,N'query_Appeals_Insert'   )

declare @app_id int
set @app_id = (select top 1 Id from @output)

-- update [dbo].[Appeals] set registration_number =  concat( YEAR(getdate()),'-',MONTH(getdate()),'/',@app_id  ) where Id =  @app_id
/*
update [dbo].[Appeals] 
set registration_number =  concat( SUBSTRING ( rtrim(YEAR(getdate())),4,1),'-',(select count(Id) from Appeals where year(Appeals.registration_date) = year(getdate())) ) 
where Id =  @app_id
*/
select @app_id as [Id]
return;
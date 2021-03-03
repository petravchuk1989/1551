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
           ([applicant_id]
           ,[registration_date]
           ,[registration_number]
           ,[receipt_source_id]
           ,[phone_number]
           ,[mail]
           ,[enter_number]
           ,[submission_date]
           ,[receipt_date]
           ,[start_date]
           ,[end_date]
           ,[article]
           ,[sender_name]
           ,[sender_post_adrress]
           ,[city_receipt]
           ,[user_id]
           ,[edit_date]
           ,[user_edit_id]
           ,[LogUpdated_Query])
output [inserted].[Id] into @output (Id)
     VALUES
           (@applicant_Id
           ,getutcdate() --@registration_date
           --,@registration_number
           ,@AppealNumberSeqText
           ,@receipt_source_id
           ,@phone_number
           ,@mail
           ,@enter_number
           ,@submission_date
           ,getutcdate() -- @receipt_date
           ,@start_date
           ,@end_date
           ,@article
           ,@sender_name
           ,@sender_post_adrress
           ,@city_receipt
           ,@user_id
           ,getutcdate() -- @edit_date
           ,@user_edit_id
           ,N'cx_Appeals_Insert_ROW58'
		   )

declare @app_id int
set @app_id = (select top 1 Id from @output)

--update [dbo].[Appeals] set registration_number =  concat( YEAR(getutcdate()),'-',MONTH(getutcdate()),'/',@app_id  ) where Id =  @app_id

select @app_id as [Id]
return;
INSERT INTO [dbo].[Buildings]
           ([district_id], [street_id], [number], [letter], 
           [bsecondname], [name], [index])
          output [inserted].[Id]
     VALUES (@district_id, @street_id, @number, @letter, 
           @bsecondname, isnull(rtrim(@number),N'')+
           isnull(rtrim(@letter),N'')+isnull(rtrim(', к.'+ @bsecondname), N''), @index)
 
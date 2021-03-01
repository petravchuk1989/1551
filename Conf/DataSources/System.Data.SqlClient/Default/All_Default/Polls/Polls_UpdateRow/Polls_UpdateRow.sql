Update [dbo].[Polls] set poll_name = @poll_name
							,is_active = @is_active
							,start_date = @start_date
							,end_date = @end_date
							,people_limit = @people_limit						
							,edit_date = GETUTCDATE() 
							,user_edit_id = @user_edit_id			
Where [Id] = @Id
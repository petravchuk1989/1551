INSERT INTO [dbo].[SearchTableFilters]
  (
  [user_id]
      ,[filter_name]
      ,[filters]
      ,[report_code]
  )

  SELECT @user_id, @filter_name, @filters, N'poshuk'
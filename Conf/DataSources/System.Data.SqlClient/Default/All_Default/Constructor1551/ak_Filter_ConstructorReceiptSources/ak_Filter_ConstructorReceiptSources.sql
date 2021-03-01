SELECT [Id]
      ,[Name]
  FROM   [dbo].[ReceiptSources]
   where #filter_columns#
  #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only


select * from (
SELECT [Id] as [Id]
      ,[name] as [Name]
  FROM [dbo].[RatingFormulas]
) as t
  WHERE 
    #filter_columns#
    #sort_columns#
    offset @pageOffsetRows rows fetch next @pageLimitRows rows only
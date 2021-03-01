    SELECT [Streets].[Id]
          ,[StreetTypes].[shortname] + ' '+ [Streets].name as street_name

    FROM   [dbo].[Streets]

    left join [dbo].[StreetTypes]
    On [Streets].[street_type_id] = [StreetTypes].[Id]
  
    where 
    #filter_columns#
    #sort_columns#
    offset @pageOffsetRows rows fetch next @pageLimitRows rows only
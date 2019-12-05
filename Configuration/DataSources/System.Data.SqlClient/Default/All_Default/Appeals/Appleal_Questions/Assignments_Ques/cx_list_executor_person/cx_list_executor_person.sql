SELECT [Id]
      , concat([name], ' (' + [position] +')') as executor_person
FROM [dbo].[Positions]
WHERE organizations_id = @org_id
  AND active <> 0
    and #filter_columns#
        #sort_columns#
 offset @pageOffsetRows rows fetch next @pageLimitRows rows only
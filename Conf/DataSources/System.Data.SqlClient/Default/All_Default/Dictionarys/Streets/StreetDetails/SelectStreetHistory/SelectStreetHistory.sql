SELECT
    [user_id],
    [field],
    [before],
    [after],
    [change_datetime]
FROM
      [dbo].[Object_History]
WHERE
    element_id = @Id
    AND #filter_columns#
    #sort_columns#
    OFFSET @pageOffsetRows ROWS FETCH NEXT @pageLimitRows ROWS ONLY;
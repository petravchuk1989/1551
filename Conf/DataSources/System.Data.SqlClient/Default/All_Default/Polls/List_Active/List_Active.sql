select 0 as [Id], N'Виключений' as [Name]
union all
select 1 as [Id], N'Включений' as [Name]
where #filter_columns#
--#sort_columns#
order by 1
offset @pageOffsetRows rows fetch next @pageLimitRows rows only

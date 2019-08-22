declare @sources table (Id int, source nvarchar(200));
declare @call_q int;
declare @site_q int;
declare @ugl_q int;
declare @result table (source nvarchar(200), val int);

-- declare @dateFrom datetime = '2019-06-01 00:00:00';
-- declare @dateTo datetime = current_timestamp;

insert into @sources (Id, source)
select Id, [name] from ReceiptSources
where Id in (1,2,3)

begin
set @call_q = (
select isnull(COUNT(a.Id),0) 
from @sources s
join ReceiptSources rs on s.Id = rs.Id 
join Appeals a on a.receipt_source_id = rs.Id 
join Questions q on q.appeal_id = a.Id 
join [Objects] o on o.Id = q.[object_id]
where rs.Id = 1 and o.name = 'Об`єкт Метрополітену'
and q.registration_date between @dateFrom and @dateTo
group by s.Id )
end
begin
set @site_q = (
select isnull(COUNT(a.Id),0) 
from @sources s
join ReceiptSources rs on s.Id = rs.Id 
join Appeals a on a.receipt_source_id = rs.Id 
join Questions q on q.appeal_id = a.Id 
join [Objects] o on o.Id = q.[object_id]
where rs.Id = 2 and o.name = 'Об`єкт Метрополітену'
and q.registration_date between @dateFrom and @dateTo
group by s.Id )
end
begin
set @ugl_q = (
select isnull(COUNT(a.Id),0) 
from @sources s
join ReceiptSources rs on s.Id = rs.Id 
join Appeals a on a.receipt_source_id = rs.Id 
join Questions q on q.appeal_id = a.Id 
join [Objects] o on o.Id = q.[object_id]
where rs.Id = 3 and o.name = 'Об`єкт Метрополітену'
and q.registration_date between @dateFrom and @dateTo
group by s.Id )
end

begin
insert into @result (source, val)
select source, isnull(@call_q, 0) call_q
from @sources 
where Id = 1;
end
begin
insert into @result (source, val)
select source, isnull(@site_q, 0) site_q
from @sources 
where Id = 2;
end
begin 
insert into @result (source, val)
select source, isnull(@ugl_q, 0) ugl_q
from @sources 
where Id = 3;
end

select ROW_NUMBER() OVER(ORDER BY z.val asc) AS Id, * 
from (           
select 'Надано консультація' [source] , '         ' val
UNION ALL
select * from @result ) z
where 
#filter_columns#
#sort_columns#
declare @tab_Rel table (source nvarchar(200), prev_val int, cur_val int);
declare @tab_exPow table (source nvarchar(200), prev_val int, cur_val int);
declare @tab_locMun table (source nvarchar(200), prev_val int, cur_val int);
declare @tab_locPow table (source nvarchar(200), prev_val int, cur_val int);
declare @tab_stCon table (source nvarchar(200), prev_val int, cur_val int);
declare @tab_Oth table (source nvarchar(200), prev_val int, cur_val int);
declare @tab_Employees table (sourse nvarchar(200), prev_val int, cur_val int);

--declare @dateFrom date = '2019-04-05';
--declare @dateTo date = cast(current_timestamp as date);

IF OBJECT_ID('tempdb..#sources') IS NOT NULL DROP TABLE #sources
CREATE TABLE #sources (
    source_name VARCHAR(MAX)
);
begin
insert into #sources
select name from ReceiptSources
where Id not in (4,5,6,7)
Union 
select  'КБУ'
--select * from #sources
end
--- Діяльність об'єднань громадян, релігії та міжконфесійних відносин
begin 
insert into @tab_Rel (source, prev_val, cur_val) 
-- Попередній рік
select z.source_name, isnull(RelPrev,0) ComPrev, isnull(RelCur,0) ComCur
from #sources z
left join (
select source_name, count(q.Id) RelPrev
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 18
and year(q.registration_date) = (select dateadd(year, -1, year(current_timestamp))) 
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0)
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 18 and 
year(registration_date) = (select dateadd(year, -1, year(current_timestamp))) 
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))) s on s.source_name = z.source_name
-- Теперішній рік
left join (
select source_name, count(q.Id) RelCur
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 18
and year(q.registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo 
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0) Val
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 18 and 
year(registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo) ss on ss.source_name = z.source_name
end
--- Діяльність центральних органів виконавчої влади
begin 
insert into @tab_exPow (source, prev_val, cur_val) 
select z.source_name, 0, 0 
from #sources z
UNION
select 'КБУ' as source_name, 0, 0
end
--- Діяльність місцевих органів виконавчої влади
begin 
insert into @tab_locMun (source, prev_val, cur_val) 
-- Попередній рік
select z.source_name, isnull(locMunPrev,0) locMunPrev, isnull(locMunCur,0) locMunCur
from #sources z
left join (
select source_name, count(q.Id) locMunPrev
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 19
and year(q.registration_date) = (select dateadd(year, -1, year(current_timestamp))) 
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0)
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 19 and 
year(registration_date) = (select dateadd(year, -1, year(current_timestamp))) 
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))) s on s.source_name = z.source_name
-- Теперішній рік
left join (
select source_name, count(q.Id) locMunCur
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 19
and year(q.registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo 
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0) Val
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 19 and 
year(registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo) ss on ss.source_name = z.source_name
end
--- Забезпечення дотримання законності та охорони правопорядку, запобігання дискримінації
begin 
insert into @tab_locPow (source, prev_val, cur_val) 
select z.source_name, 0, 0
from #sources z
UNION
select 'КБУ' as source_name, 0, 0
end
--- Державного будівництва, адміністративно-територіального устрою
begin 
insert into @tab_stCon (source, prev_val, cur_val) 
-- Попередній рік
select z.source_name, isnull(stConPrev,0) stConPrev, isnull(stConCur,0) stConCur
from #sources z
left join (
select source_name, count(q.Id) stConPrev
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 13
and year(q.registration_date) = (select dateadd(year, -1, year(current_timestamp)))
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0)
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 13 and 
year(registration_date) = (select dateadd(year, -1, year(current_timestamp))) 
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))) s on s.source_name = z.source_name
-- Теперішній рік
left join (
select source_name, count(q.Id) stConCur
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 13
and year(q.registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo 
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0) Val
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 13 and 
year(registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo) ss on ss.source_name = z.source_name
end
--- Інші
begin 
insert into @tab_Oth (source, prev_val, cur_val) 
-- Попередній рік
select z.source_name, isnull(OthPrev,0) OthPrev, isnull(OthCur,0) OthCur
from #sources z
left join (
select source_name, count(q.Id) OthPrev
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 20
and year(q.registration_date) = (select dateadd(year, -1, year(current_timestamp)))
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo)) 
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0) Val
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 20 and 
year(registration_date) = (select dateadd(year, -1, year(current_timestamp))) 
and q.registration_date between dateadd(year, -1, year(@dateFrom))
and dateadd(year, -1, year(@dateTo))) s on s.source_name = z.source_name
-- Теперішній рік
left join (
select source_name, count(q.Id) OthCur
from #sources 
left join ReceiptSources rs on rs.name = #sources.source_name
left join Appeals a on a.receipt_source_id = rs.Id
left join Questions q on q.appeal_id = a.Id
				 left join QuestionTypes qt on qt.Id = q.question_type_id
				 left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = qt.Id
				 left join QuestionGroups qg on qg.Id = qgiqt.group_question_id
where group_question_id = 20
and year(q.registration_date) = year(current_timestamp) 
and q.registration_date between @dateFrom and @dateTo
group by #sources.source_name 
UNION
select 'КБУ' as source_name, isnull(count(q.Id),0) Val
from Questions q
left join QGroupIncludeQTypes qgiqt on qgiqt.type_question_id = q.question_type_id
where group_question_id = 20 and 
year(registration_date) = year(current_timestamp)
and q.registration_date between @dateFrom and @dateTo) ss on ss.source_name = z.source_name
end
--- Штатна чисельність підрозідлу роботи зі зверненнями
begin
insert into @tab_Employees (sourse, prev_val, cur_val)
select source_name, case when source_name = 'КБУ' then 125 else 0 end,
case when source_name = 'КБУ' then 125 else 0 end 
from #sources 
end
begin
declare @result table (source nvarchar(200),
                       prevRel nvarchar(10), curRel nvarchar(10), prevExPow nvarchar(10),
					   curExPow nvarchar(10), prevLocMun nvarchar(10), curLocMun nvarchar(10),
					   prevLocPow nvarchar(10), curLocPow nvarchar(10), prevStCon nvarchar(10),
					   curStCon nvarchar(10), prevOth nvarchar(10), curOth nvarchar(10),
					   prevEmployees nvarchar(10), curEmployees nvarchar(10)) 

	              insert into @result 
				  select source_name, 
				  t_rel.prev_val prevRel, t_rel.cur_val curRel,
				  t_expow.prev_val prevResidential, t_expow.cur_val curResidential,
				  t_locmun.prev_val prevEcology, t_locmun.cur_val curEcology,
				  t_locpow.prev_val prevLaw, t_locpow.cur_val curLaw,
				  t_stcon.prev_val prevFamily, t_stcon.cur_val curFamily,
				  t_oth.prev_val prevSince, t_oth.cur_val curSince,
				  t_empl.prev_val prevEmployees, t_empl.cur_val curEmployees
			from #sources s
			join @tab_Rel t_rel on t_rel.[source] = s.source_name
			join @tab_exPow t_expow on t_expow.source = s.source_name
			join @tab_locMun t_locmun on t_locmun.source = s.source_name
			join @tab_locPow t_locpow on t_locpow.source = s.source_name
			join @tab_stCon t_stcon on t_stcon.source = s.source_name
			join @tab_Oth t_oth on t_oth.source = s.source_name
            join @tab_Employees t_empl on t_empl.sourse = s.source_name

end
     select [source],
	 IIF(prevRel = '0', '-', prevRel) prevReligy, IIF(curRel = '0', '-', curRel) curReligy,
	 IIF(prevExPow = '0', '-', prevExPow) prevCentralExecutePower, IIF(curExPow = '0', '-', curExPow) curCentralExecutePower,
	 IIF(prevLocMun = '0', '-', prevLocMun) prevLocalExecutePower, IIF(curLocMun = '0', '-', curLocMun) curLocalExecutePower,
	 IIF(prevLocPow = '0', '-', prevLocPow) prevLocalMunicipalitet, IIF(curLocPow = '0', '-', curLocPow) curLocalMunicipalitet,
	 IIF(prevStCon = '0', '-', prevStCon) prevStateConstruction, IIF(curStCon = '0', '-', curStCon) curStateConstruction,
	 IIF(prevOth = '0', '-', prevOth) prevOther, IIF(curOth = '0', '-', curOth) curOther,
	 IIF(prevEmployees = '0', '-', prevEmployees) prevEmployees, IIF(curEmployees = '0', '-', curEmployees) curEmployees
	 from @result	 
	 order by curOth desc



if object_id('tempdb..#org_and_parent') is not null 
begin
drop table #org_and_parent
end


;with
pit as -- родители @id
(
select Id, parent_organization_id ParentId, short_name name, Id lev_Id, short_name lev_name, t.phone_number
from [dbo].[Organizations] t
--where Id=@id
union all
select t.Id, t.parent_organization_id ParentId, t.short_name name, pit.lev_Id, pit.lev_name, t.phone_number
from [dbo].[Organizations] t inner join pit on t.Id=pit.ParentId
)
select distinct * into #org_and_parent from pit-- pit it
--select distinct * into #org_and_parent from pit-- pit it

--select * from #org_and_parent where phone_number=N'044-247-40-40'
-- вывести:
/*
1.организацию исполнителя
2.их родительские организации
3.главные посади родительских организаций
*/

if object_id('tempdb..#position_org') is not null 
begin
drop table #position_org
end

select [Positions].Id, [Positions].organizations_id, [Positions].Id position_id, ISNULL([Positions].position+N' ',N'')+ISNULL(N'('+[Organizations].short_name+N')',N'') name
into #position_org
from [dbo].[Positions]
left join [dbo].[Organizations] on [Positions].organizations_id=[Organizations].Id
where [Positions].is_main='true'


--select * from #org_and_parent
select row_number() over(order by vykonavets_Id) Id, vykonavets_Id, possible_Id, possible_name, phone_number
from 
(
select distinct #org_and_parent.Id possible_Id, #org_and_parent.name possible_name, #org_and_parent.lev_Id vykonavets_Id, #org_and_parent.phone_number
from #position_org
inner join #org_and_parent on #position_org.organizations_id=#org_and_parent.Id
--union
--select Id, Id, short_name, 1 n 
--from [dbo].[Organizations]
) t

--where vykonavets_Id=4005--phone_number=N'044-247-40-40'


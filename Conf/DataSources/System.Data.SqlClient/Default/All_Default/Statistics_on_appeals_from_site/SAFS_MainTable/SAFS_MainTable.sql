



/*
declare @date_from datetime='2020-10-01T00:00:00.000Z',
  @date_to date='2020-10-26T19:53:00.000Z';
  */

  --convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))
   /*
  set @date_from=
    CONVERT(datetime, SWITCHOFFSET(@date_from, DATEPART(TZOFFSET,@date_from AT TIME ZONE 'E. Europe Standard Time')))
  set @date_to=
	CONVERT(datetime, SWITCHOFFSET(@date_to, DATEPART(TZOFFSET,@date_to AT TIME ZONE 'E. Europe Standard Time')))
	*/

  declare @reportcode nvarchar(200)=N'appeals_statistics';

  IF object_id('tempdb..#temp_main') IS NOT NULL DROP TABLE #temp_main

  select 1 Id, ltrim(count(Id))+N' ('+ltrim(convert(numeric(8,2),convert(float,count(Id))/convert(float,1+(datediff(dd, convert(date, @date_from), convert(date, @date_to))))))+N')' cell1,
  
  count(Id) inf2_1,

  ltrim(convert(numeric(8,2),convert(float,count(Id))/convert(float,1+(datediff(dd, convert(date, @date_from), convert(date, @date_to)))))) inf2_2,

  (select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=convert(date, getdate())) cell2, --+


  case 
  when 
  convert(numeric(8,2),(select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=dateadd(dd, -1, getdate())))-
  convert(numeric(8,2),convert(float,count(Id))/convert(float,1+(datediff(dd, convert(date, @date_from), convert(date, @date_to)))))<=0 --+
  then 
  ltrim(convert(numeric(8,2),(select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=dateadd(dd, -1, getdate())))-
  convert(numeric(8,2),convert(float,count(Id))/convert(float,1+(datediff(dd, convert(date, @date_from), convert(date, @date_to)))))) --+
  else
  N'+'+ltrim(convert(numeric(8,2),(select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=dateadd(dd, -1, getdate())))-
  convert(numeric(8,2),convert(float,count(Id))/convert(float,1+(datediff(dd, convert(date, @date_from), convert(date, @date_to)))))) --+
  end
  cell2_delta,+
  ltrim((select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where [AppealFromSiteResultId]=1 and convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time')))) between convert(date, @date_from) and convert(date, @date_to)))+
  N'('+ltrim((select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=convert(date, getdate()) and [AppealFromSiteResultId]=1))+

  N'/'+ltrim((select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))<>convert(date, getdate()) and [AppealFromSiteResultId]=1
  and convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time')))) between convert(date, @date_from) and convert(date, @date_to)))+N')' cell3, --+

  ltrim((select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where [AppealFromSiteResultId]=1 and convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time')))) between convert(date, @date_from) and convert(date, @date_to))) inf3_1, --+

  ltrim((select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=convert(date, getdate()) and [AppealFromSiteResultId]=1)) inf3_2, --+

  ltrim((select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))<>convert(date, getdate()) and [AppealFromSiteResultId]=1
  and convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time')))) between convert(date, @date_from) and convert(date, @date_to))) inf3_3, --+

  (select sum([indicator_value])
  
  from [CRM_1551_Site_Integration].[dbo].[Statistic]
  where [indicator_name] in (N'Заяввники без телефону та адреси', N'Заявники без адреси, з телефоном')
  and date between convert(date, @date_from) and convert(date, @date_to)) cell4,

  (select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time')))) between convert(date, @date_from) and convert(date, @date_to) and [AppealFromSiteResultId]=2) cell5
 /* */


 ,(select count(Id) from [CRM_1551_Site_Integration].[dbo].[ApplicantsFromSite]) cell1_count_applicants

 ,count(distinct ApplicantFromSiteId) cell1_count_applicants_more1appeals
 ,(select count(Id) from [CRM_1551_Site_Integration].[dbo].[ApplicantsFromSite] where [is_verified]='true') cell1_count_applicants_verified
 ,sum(case when charindex(N'Windows', [SystemIP], 1)>1 then 1 else 0 end) cell4_windows
 ,sum(case when charindex(N'android', [SystemIP], 1)>1 then 1 else 0 end) cell4_android
 ,sum(case when charindex(N'Apple', [SystemIP], 1)>1 then 1 else 0 end) cell4_Apple
 --,sum(case when [AppealFromSiteResultId]=2 /*повернуто заявникові*/ then 1 else 0 end) cell5_ReturnToApplicant
 ,(select count(Id) from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite] where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time'))))=convert(date, getdate()) and [AppealFromSiteResultId]=2) cell5_ReturnToApplicant --+




 into #temp_main
  from [CRM_1551_Site_Integration].[dbo].[AppealsFromSite]
  where convert(date, CONVERT(datetime, SWITCHOFFSET(ReceiptDate, DATEPART(TZOFFSET,ReceiptDate AT TIME ZONE 'E. Europe Standard Time')))) between convert(date, @date_from) and convert(date, @date_to) --+

  select Id, cell1, cell2, cell2_delta, cell3, cell4, cell5, cell1_count_applicants, cell1_count_applicants_more1appeals
 ,cell1_count_applicants_verified, cell4_windows, cell4_android, cell4_Apple, cell5_ReturnToApplicant

 ,ltrim(cell1_count_applicants)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'1' and [valuecode]=N'1 ячейка, 1 показник') cell1_info_value1
 ,ltrim(cell1_count_applicants_more1appeals)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'1' and [valuecode]=N'1 ячейка, 2 показник') cell1_info_value2
 ,ltrim(cell1_count_applicants_verified)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'1' and [valuecode]=N'1 ячейка, 3 показник') cell1_info_value3

 ,ltrim(inf2_1)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'2' and [valuecode]=N'2 ячейка, 1 показник') cell2_info_value1
 ,ltrim(inf2_2)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'2' and [valuecode]=N'2 ячейка, 2 показник') cell2_info_value2
 ,ltrim(cell2)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'2' and [valuecode]=N'2 ячейка, 3 показник') cell2_info_value3
 ,ltrim(cell2_delta)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'2' and [valuecode]=N'2 ячейка, 4 показник') cell2_info_value4

 ,ltrim(inf3_1)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'3' and [valuecode]=N'3 ячейка, 1 показник') cell3_info_value1
 ,ltrim(inf3_2)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'3' and [valuecode]=N'3 ячейка, 2 показник') cell3_info_value2
 ,ltrim(inf3_3)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'3' and [valuecode]=N'3 ячейка, 3 показник') cell3_info_value3

 ,ltrim(cell4_windows)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'4' and [valuecode]=N'4 ячейка, 1 показник') cell4_info_value1
 ,ltrim(cell4_android)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'4' and [valuecode]=N'4 ячейка, 2 показник') cell4_info_value2
 ,ltrim(cell4_Apple)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'4' and [valuecode]=N'4 ячейка, 3 показник') cell4_info_value3

 ,ltrim(cell5)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'5' and [valuecode]=N'5 ячейка, 1 показник') cell5_info_value1
 ,ltrim(cell5_ReturnToApplicant)+N' - '+(select [content] from [CRM_1551_Site_Integration].[dbo].[ReportsInfo] where reportcode=@reportcode and [diagramcode]=N'5' and [valuecode]=N'5 ячейка, 2 показник') cell5_info_value2

  from #temp_main

  --df


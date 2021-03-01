select  JSON_QUERY((
	select 
		[ReferenceAPI_Categories].[name] as 'about.category',
		resp.[name] as 'about.name',
		resp.[description] as 'about.description',
		resp.[url] as 'request.url',
		resp.[method] as 'request.method',
		JSON_QUERY(isnull(resp.[headers],N'[]')) as 'request.headers',
		JSON_QUERY(isnull(resp.[body],N'[]')) as 'request.body',
		(SELECT t1.[status],
				t1.[value] 
		 FROM [dbo].[ReferenceAPI_Response] as t1 with (nolock)
		 where t1.RequestId = resp.Id
		 order by t1.[value]
		 FOR JSON PATH, INCLUDE_NULL_VALUES) as 'response'
	from [dbo].[ReferenceAPI_Request] as resp
	left join  [dbo].[ReferenceAPI_Categories] on [ReferenceAPI_Categories].Id = resp.CategoryId
	order by resp.[name]
	FOR JSON PATH, INCLUDE_NULL_VALUES
)) as Result
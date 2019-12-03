--declare @Ids nvarchar(300)=N'1,2,3';

  -- наша входная строка с айдишниками
declare @input_str nvarchar(max) = @Ids+N','
-- создаем таблицу в которую будем
-- записывать наши айдишники
declare @table table (id int)
-- создаем переменную, хранящую разделитель
declare @delimeter nvarchar(1) = ','
-- определяем позицию первого разделителя
declare @pos int = charindex(@delimeter,@input_str)
-- создаем переменную для хранения
-- одного айдишника
declare @id nvarchar(10)
while (@pos != 0)
begin
    -- получаем айдишник
    set @id = SUBSTRING(@input_str, 1, @pos-1)
    -- записываем в таблицу
    insert into @table (id) values(cast(@id as int))
    -- сокращаем исходную строку на
    -- размер полученного айдишника
    -- и разделителя
    set @input_str = SUBSTRING(@input_str, @pos+1, LEN(@input_str))
    -- определяем позицию след. разделителя
    set @pos = CHARINDEX(@delimeter,@input_str)
end

--select * from @table


  update [ApplicantDublicate]
  set [IsDone]='true',
  [User_done_id]=@user_Id,
  [Done_date]=getutcdate()
  where Id in (select Id from @table)
update   [dbo].[StreetTypes]
  set shortname=@shortname,
  name=@name
  where id=@Id
-- DECLARE @Id INT = 2;

UPDATE dbo.Test_Bag 
SET SystemUserId = @SystemUserId, SystemUser = @SystemUser
WHERE Id = @Id;
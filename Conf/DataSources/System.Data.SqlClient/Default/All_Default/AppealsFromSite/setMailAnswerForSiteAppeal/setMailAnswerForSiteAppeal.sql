-- DECLARE @Id INT = 6695889;

DECLARE @AppealID INT = (SELECT appeal_id FROM dbo.Questions WHERE Id = @Id);

DECLARE @ApplicantID INT = (SELECT applicant_id FROM dbo.Appeals WHERE Id = @AppealID);

DECLARE @Mail NVARCHAR(100) = (SELECT mail FROM dbo.Applicants WHERE Id = @ApplicantID);

SELECT @Mail AS applicantMail;
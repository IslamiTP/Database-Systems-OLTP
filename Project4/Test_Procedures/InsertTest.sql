USE HumanResourcesProject4;
GO

TRUNCATE TABLE tblLogErrors;

--=======================================================
-- New Employee: Violates 1 Business Rule (Column: Gender)
-- Invalid Gender
--=======================================================
EXEC usp_InsertEmployee 
	'Smith',
	'Emily',
	'',
	'01/15/1985',
	'S123456',
	'X',
	'123456789';

--=======================================================
-- New Employee: Violates 1 Business Rule (Column: Date of Birth)
-- Bad Date of Birth (too young)
--=======================================================
EXEC usp_InsertEmployee 
	'Doe',
	'John',
	'',
	'01/01/2010',
	'D123456',
	'M',
	'987654321';

--=======================================================
-- New Employee: Violates 2 Business Rules
-- Missing SSN, Missing First Name
--=======================================================
EXEC usp_InsertEmployee 
	'Jackson',
	'',
	'',
	'02/20/1975',
	'J123456',
	'M',
	'';

--=======================================================
-- New Employee: Violates 3 Business Rules
-- Bad Middle Initial, Bad Gender, Missing SSN
--=======================================================
EXEC usp_InsertEmployee 
	'White',
	'Sandra',
	'XX',
	'05/15/1980',
	'W123456',
	'X',
	'';

--=======================================================
-- New Employee: Violates 4 Business Rules
-- Missing Last Name, Missing First Name, Bad DOB, Missing SSN
--=======================================================
EXEC usp_InsertEmployee 
	'',
	'',
	'',
	'01/01/1920',
	'',
	'F',
	'';

-- ===================== REVIEW LOGS =====================
SELECT ErrorLogID, ErrorMessage FROM tblLogErrors
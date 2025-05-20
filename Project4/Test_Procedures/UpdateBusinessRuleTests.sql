USE HumanResourcesProject4;
GO
-- RESET LOGS
TRUNCATE TABLE tblLogErrors;

-- ===================== UPDATE SCENARIOS =====================

--=======================================================
-- Update Employee: Violates 1 Business Rule (Column: Gender)
-- Invalid Gender on Update
--=======================================================
EXEC usp_UpdateEmployee 
	1,
	'Doe',
	'Jane',
	'',
	'04/18/1985',
	'C000001',
	'Z',
	'111111111';

--=======================================================
-- Update Employee: Violates 1 Business Rule (Column: DOB)
-- DOB too young on Update
--=======================================================
EXEC usp_UpdateEmployee 
	1,
	'Doe',
	'Jane',
	'',
	'01/01/2012',
	'C000001',
	'F',
	'111111111';

--=======================================================
-- Update Employee: Violates 2 Business Rules
-- Missing SSN, Bad Gender
--=======================================================
EXEC usp_UpdateEmployee 
	1,
	'Doe',
	'Jane',
	'',
	'03/15/1980',
	'C000001',
	'K',
	'';



USE HumanResourcesProject4;
GO
-- RESET LOGS
TRUNCATE TABLE tblLogErrors;
--=======================================================
-- Update Employee: Violates 3 Business Rules
-- Bad Middle Initial, Missing First Name, Bad Emp Number
--=======================================================
EXEC usp_UpdateEmployee 
	1, -- ID
	'Doe', -- L N
	'',  -- F N
	'XXSDD', -- M I  XXXXXXXXXXXXXXXXXXXXXXXXXX
	'08/01/1970', -- DOB
	'Z999999',  -- E#
	'M', -- GENDER
	'';  -- SSN  - HALF XXXXXXXXXXXXXXXXXXXXXXXXXX

SELECT * FROM tblLogErrors;




USE HumanResourcesProject4;
GO
-- RESET LOGS
TRUNCATE TABLE tblLogErrors;

--=======================================================
-- Update Employee: Violates 4 Business Rules
-- Missing Last Name, Missing Gender, Bad DOB, Missing SSN
--=======================================================
EXEC usp_UpdateEmployee 
	1, -- D
	'', -- L N
	'Sarah', -- FN
	'', -- M I 
	'01/01/1900', -- DOB
	'C000001', -- EMPLOYEE NUMBER
	'', -- GENDER
	''; -- SSN

--=======================================================
-- View the error log to confirm
--=======================================================
SELECT * FROM tblLogErrors;
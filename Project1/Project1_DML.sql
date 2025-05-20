/****************************************************************
Author Name:   IslamiTP
Create Date:   07/03/2025 -- DD/MM/YYYY

Description:
In this is DML script there will be mutliple parameters that will
test the procedures in the DDL script. Insert, Delete, and Update
procedures. Apart from that this is how the Database HumanResou-
rsces tables will get populated.

Functionality:
- Executes INSERT procedure with sample employee data.
- Executes UPDATE procedure to modify specific employee info.
- Executes DELETE procedure to remove a test employee.
- Validates business rules and logs outcomes through the 
  corresponding logging mechanism.

Assumptions:
- All relevant tables (e.g., tblEmployees, tblLogErrors) and 
  procedures (Insert, Update, Delete) already exist.
- Script will be executed in the context of the 'HumanResources' 
  database.
- Audit fields (CreatedDate, CreatedBy, ModifiedDate, ModifiedBy) 
  are managed by the procedures.

****************************************************************/

-- Uses DATABASE HumanResources for any changes to be made.
USE HumanResources;
GO

/******************************************************************
*                                                                *
*                  REQUIRED SCENARIO 1: INSERT EMPLOYEE          *
*                                                                *
*  Description:                                                  *
*  Demonstrates inserting a new employee with populated audit    *
*  fields (CreatedDate, CreatedBy). Returns the generated        *
*  EmployeeID (IDENTITY value).                                  *
*                                                                *
******************************************************************/

INSERT INTO dbo.tblEmployees (
	EmployeeLastName
	,EmployeeFirstName
	,EmployeeMiddleInitial
	,EmployeeDateOfBirth
	,EmployeeNumber
	,EmployeeGender 
	,EmployeeSocialSecurityNumber
	,CreatedDate
	,CreatedBy
	)

	-- The value input order is the same as above.
values (
	'Cristiano'
	,'Ronaldo'
	,'S'  -- Middle Initial
	,'1985-02-05' -- Date of Birth
	,'C928005' -- Employee Number
	,'M' -- Employee Gender
	,'982331985' -- Employee Social Security Number
	,GETDATE() -- Function grabs current date and time.
	,SYSTEM_USER -- Function grabs user that ran the process.
)

SELECT EmployeeID FROM dbo.tblEmployees WHERE EmployeeNumber = 'C928005';

--

/******************************************************************
*                                                                *
*             REQUIRED SCENARIO 2: VIOLATE BUSINESS RULES        *
*                                                                *
*  Description:                                                  *
*  Demonstrates an attempt to insert an employee record that     *
*  violates business rules for multiple fields:                  *
*  - Invalid DOB (underage)                                      *
*  - Invalid Middle Initial (too long)                           *
*  - Invalid Employee Number format                              *
*  - Invalid Gender (not 'M' or 'F')                             *
*  - Invalid SSN (non-numeric or incorrect length)              *
*                                                                *
*  Excluded Columns: EmployeeID, CreatedDate/By, ModifiedDate/By *
******************************************************************/
-- Valid Prompt
EXEC usp_InsertEmployees 
    @EmployeeLastName = 'Lionel'
    ,@EmployeeFirstName = 'Messi'
    ,@EmployeeMiddleInitial = 'S' -- Invalid Middle Initial
    ,@EmployeeDateOfBirth = '1987-06-24'
    ,@EmployeeNumber = 'M564043'
    ,@EmployeeGender = 'M'
    ,@EmployeeSocialSecurityNumber = '500410001';

	SELECT * FROM dbo.tblEmployees

	-- Invalid Middle Initial
EXEC usp_InsertEmployees 
    @EmployeeLastName = 'Cristiano'
    ,@EmployeeFirstName = 'Ronaldo'
    ,@EmployeeMiddleInitial = '34' -- Invalid Middle Initial
    ,@EmployeeDateOfBirth = '1985-02-05'
    ,@EmployeeNumber = 'C928005'
    ,@EmployeeGender = 'M'
    ,@EmployeeSocialSecurityNumber = '982331985';

	SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_InsertEmployees';


-- Invalid Date Of Birth
EXEC usp_InsertEmployees 
    @EmployeeLastName = 'Cristiano'
    ,@EmployeeFirstName = 'Ronaldo'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1942-01-25' -- Invalid Date of Birth (Oldern than 65)
    ,@EmployeeNumber = 'C928005'
    ,@EmployeeGender = 'M'
    ,@EmployeeSocialSecurityNumber = '982331985';

	SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_InsertEmployees';

-- Invalid Gender
EXEC usp_InsertEmployees 
    @EmployeeLastName = 'Cristiano'
    ,@EmployeeFirstName = 'Ronaldo'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1985-02-05'
    ,@EmployeeNumber = 'C928005'
    ,@EmployeeGender = 'X' -- Invalid Gender
    ,@EmployeeSocialSecurityNumber = '982331985';

	SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_InsertEmployees';


-- Invalid Employee Number
EXEC usp_InsertEmployees 
    @EmployeeLastName = 'Cristiano'
    ,@EmployeeFirstName = 'Ronaldo'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1985-02-05'
    ,@EmployeeNumber = 'R9281985'					-- Invalid Number 7 digits long not 6. And Not Last name Character.
    ,@EmployeeGender = 'M'
    ,@EmployeeSocialSecurityNumber = '982331985';

	SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_InsertEmployees';

-- Invalid Social Security Number
EXEC usp_InsertEmployees 
    @EmployeeLastName = 'Cristiano'
    ,@EmployeeFirstName = 'Ronaldo'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1985-02-05'
    ,@EmployeeNumber = 'C928005'
    ,@EmployeeGender = 'M'
    ,@EmployeeSocialSecurityNumber = '9823319O85' -- Invalid Social Security Number

	SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_InsertEmployees';




/******************************************************************
*                                                                *
*         REQUIRED SCENARIO 3: UPDATE VIOLATING BUSINESS RULES   *
*                                                                *
*  Description:                                                  *
*  Demonstrates updates on an employee record that intentionally *
*  violate business rules for the following fields:              *
*  - Middle Initial                                              *
*  - Date of Birth                                               *
*  - Gender                                                      *
*  - Employee Number                                             *
*  - Social Security Number                                      *
*                                                                *
*  Excluded Columns: EmployeeID, CreatedDate/By, ModifiedDate/By *
******************************************************************/

-- Valid Update Prompt
EXEC usp_UpdateEmployee
    @EmployeeID = 1,
    @EmployeeLastName = 'Cristiano',
    @EmployeeFirstName = 'Ronaldo',
    @EmployeeMiddleInitial = 'S',
    @EmployeeDateOfBirth = '1985-02-05',
    @EmployeeNumber = 'C928111',
    @EmployeeGender = 'M',
    @EmployeeSocialSecurityNumber = '982331985',
    @EmployeeActiveFlag = 1;

SELECT * FROM tblEmployees;


-- Invalid Middle Initial
EXEC usp_UpdateEmployee
    @EmployeeID = 1,
    @EmployeeLastName = 'Cristiano',
    @EmployeeFirstName = 'Ronaldo',
    @EmployeeMiddleInitial = 'LARRY', -- Middle Initial too long
    @EmployeeDateOfBirth = '1985-02-05',
    @EmployeeNumber = 'C928005',
    @EmployeeGender = 'M',
    @EmployeeSocialSecurityNumber = '982331985',
    @EmployeeActiveFlag = 1;

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_UpdateEmployee';


-- Invalid Date Of Birth
EXEC usp_UpdateEmployee
    @EmployeeID = 1,
    @EmployeeLastName = 'Cristiano',
    @EmployeeFirstName = 'Ronaldo',
    @EmployeeMiddleInitial = 'S',
    @EmployeeDateOfBirth = '1785-02-05',  -- Invalid Date Of Birth (Ages exceeds parameters)
    @EmployeeNumber = 'C928005',
    @EmployeeGender = 'M',
    @EmployeeSocialSecurityNumber = '982331985',
    @EmployeeActiveFlag = 1;

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_UpdateEmployee';



-- Invalid Gender
EXEC usp_UpdateEmployee
    @EmployeeID = 1,
    @EmployeeLastName = 'Cristiano',
    @EmployeeFirstName = 'Ronaldo',
    @EmployeeMiddleInitial = 'S',
    @EmployeeDateOfBirth = '1985-02-05',
    @EmployeeNumber = 'C928005',
    @EmployeeGender = 'X',  -- Invalid Gender Character
    @EmployeeSocialSecurityNumber = '982331985',
    @EmployeeActiveFlag = 1;

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_UpdateEmployee';


-- Invalid Employee Number
EXEC usp_UpdateEmployee
    @EmployeeID = 1
    ,@EmployeeLastName = 'Cristiano'
    ,@EmployeeFirstName = 'Ronaldo'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1985-02-05'
    ,@EmployeeNumber = 'R928005'                  -- Invalid Character( Using First Name not Last Name character)
    ,@EmployeeGender = 'M'
    ,@EmployeeSocialSecurityNumber = '982331985'
    ,@EmployeeActiveFlag = 1

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_UpdateEmployee';

--- Invalid Social Security Number
EXEC usp_UpdateEmployee
    @EmployeeID = 1,
    @EmployeeLastName = 'Cristiano',
    @EmployeeFirstName = 'Ronaldo',
    @EmployeeMiddleInitial = 'S',
    @EmployeeDateOfBirth = '1985-02-05',
    @EmployeeNumber = 'C928005',
    @EmployeeGender = 'M',
    @EmployeeSocialSecurityNumber = '903438O988',  -- Invalid SSN (10 digits)
    @EmployeeActiveFlag = 1;

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_UpdateEmployee';

--

/******************************************************************
*                                                                *
*                  REQUIRED SCENARIO 4: DELETE PROCEDURES        *
*                                                                *
*  Description:                                                  *
*  Demonstrates the use of the Delete procedure with:            *
*  - A valid EmployeeID (expected successful deletion)           *
*  - An invalid EmployeeID (expected to trigger error logging)   *
*                                                                *
******************************************************************/
EXEC usp_DeleteEmployees @EmployeeID = 1;

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_DeleteEmployees';

-- Invalid Deletion procedure
EXEC usp_DeleteEmployees @EmployeeID = 0;

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_DeleteEmployees';

--

/******************************************************************
*                                                                *
*                       ERROR LOG REVIEW SECTION                 *
*                                                                *
*  Description:                                                  *
*  Displays all logged errors by procedure name from             *
*  tblLogErrors for:                                             *
*  - Insert Procedure                                            *
*  - Update Procedure                                            *
*  - Delete Procedure                                            *
*                                                                *
******************************************************************/

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_InsertEmployees';
--
SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_UpdateEmployee';

SELECT * FROM tblLogErrors WHERE ErrorProcedure = 'usp_DeleteEmployees';
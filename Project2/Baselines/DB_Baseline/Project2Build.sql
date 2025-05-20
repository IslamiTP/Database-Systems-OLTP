/********************************************************************************
Create Date: 03/18/2024
Project: 1
Functionality: DDL scripts
Assumptions: Creating two tables
--------------------------------------------------------------------------------
Mod Date:		03/19/2024
Description:	1) Reworked the Create Database Section 
				2) Additional comenting with flower pots / white space
				3) Additional sample EXEC for insert stored procedure.
				4) Create statements positioned BEFORE actual create / drops
				5) Flower Pots now within print margin.
				6) Unit Test of Creating an Employee
				7) Unit Test of Deleting an Employee
				8) Unit Test of Updating an Employee
				9) Added SET NOCOUNT ON statemets

Assumptions:	Exisiting business rules checks are accurate

*/

--******************************************************************************
-- CREATE HUMAN RESOURCES DATABASE
--******************************************************************************

use master;
go

RAISERROR (N'Creating Database %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

-- If the database exists it should be dropped
IF EXISTS (SELECT * FROM sys.databases WHERE [name] = 'HumanResources')
BEGIN
	ALTER DATABASE HumanResources set SINGLE_USER with ROLLBACK Immediate;
	DROP DATABASE HumanResources;
END
GO

-- Create the new HumanResources database
CREATE DATABASE HumanResources;
GO

--******************************************************************************
-- CREATE TABLES
--******************************************************************************

-- Use the new HumanResources database
USE HumanResources;
GO

-------------------------------------------------------------------------------
-- tblEmployee
-------------------------------------------------------------------------------

RAISERROR (N'Creating Table %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'tblEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP TABLE IF EXISTS tblEmployee -- If the table exists it should be dropped

CREATE TABLE tblEmployee (
    EmployeeID [int]			IDENTITY(1,1) NOT NULL,
    EmployeeLastName			NVARCHAR(1000) NOT NULL,
    EmployeeFirstName			NVARCHAR(1000) NOT NULL,
    EmployeeMiddleInitial		NVARCHAR(1) NULL,
    EmployeeDateOfBirth			DATE NOT NULL,
    EmployeeNumber				NVARCHAR(10) NOT NULL,
    EmployeeGender				VARCHAR(1) NOT NULL,
    EmployeeSSN					NVARCHAR(9) NOT NULL,
    EmployeeActiveFlag			INT DEFAULT 1,
    CreatedDate					DATETIME DEFAULT GETDATE() ,
    CreatedBy					NVARCHAR(100) DEFAULT SUSER_NAME() ,
    ModifiedDate				DATETIME,
    ModifiedBy					NVARCHAR(1000)
);

-------------------------------------------------------------------------------
-- tblLogErrors
-------------------------------------------------------------------------------

RAISERROR (N'Creating Table %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'tblLogErrors', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP TABLE IF EXISTS tblLogErrors -- If the table exists it should be dropped

CREATE TABLE [tblLogErrors] (
    [ErrorLogID]				INT IDENTITY(1,1) PRIMARY KEY,
    [ErrorNumber] INT,
    [ErrorSeverity] INT,
    [ErrorState] INT,
    [ErrorProcedure] NVARCHAR(128),
    [ErrorLine] INT,
    [ErrorMessage] NVARCHAR(4000),
    [ErrorUser] NVARCHAR(128),
	[ErrorDateTime] DATETIME
);
GO


--******************************************************************************
-- CREATE STORED PROCEDURES
--******************************************************************************

-------------------------------------------------------------------------------
-- usp_InsertEmployee
-------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS usp_InsertEmployee;
GO

RAISERROR (N'Creating Stored Procedure %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'usp_InsertEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

CREATE PROCEDURE usp_InsertEmployee
/********************************************************************************
Create Date: 03/18/2024
Parameter 1: @EmployeeLastName
Parameter 2: @EmployeeFirstName
Parameter 3: @EmployeeMiddleInitial
Parameter 4: @EmployeeDateOfBirth
Parameter 5: @EmployeeNumber
Parameter 6: @EmployeeGender
Parameter 7: @EmployeeSSN
Functionality: Make sure no business rules or contstraints are violated.
Assumptions: Create stored procedure usp_InsertEmployee
********************************************************************************/
/* DECLARE @EmployeeID INT
	DECLARE @RC INT
		
		EXEC  @RC  = usp_InsertEmployee 
					'Doe'
					,'David'
					,'L'
					,'08/01/1970'
					,'C123456'
					,'M'
					,'123459696'
					,@EmployeeID

	SELECT @RC
					*/

    @EmployeeLastName NVARCHAR(1000)
    ,@EmployeeFirstName NVARCHAR(1000)
    ,@EmployeeMiddleInitial NVARCHAR(1)
    ,@EmployeeDateOfBirth DATE
    ,@EmployeeNumber VARCHAR(10)
    ,@EmployeeGender VARCHAR(1)
    ,@EmployeeSSN	NVARCHAR(9)
	,@EmployeeID	INT  = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING

   -- DECLARE @EmployeeID int
    DECLARE @CustomErrorMessage NVARCHAR(125)
    DECLARE @CustomErrorNumber int

    BEGIN TRY

-- check for the business rules print out the custom error codes

	IF LEN(@EmployeeMiddleInitial) > 1
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Middle Initial'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

     IF @EmployeeDateOfBirth < DATEADD(YEAR, -65, GETDATE()) OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeGender NOT IN ('M', 'F')
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Gender'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END
        
	IF @EmployeeLastName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeFirstName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing First Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeDateOfBirth IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'Missing DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeSSN IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'SSN is NULL'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeNumber NOT LIKE LEFT(@EmployeeLastName, 1) + '%'
	BEGIN
		SELECT @CustomErrorMessage = 'Employee Number does not start with first letter of Employee Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END


-- inserting into the tbl.Employee that have been created
	INSERT INTO tblEmployee (
			EmployeeLastName
            ,EmployeeFirstName
            ,EmployeeMiddleInitial
            ,EmployeeDateOfBirth
            ,EmployeeNumber
            ,EmployeeGender
            ,EmployeeSSN
	)
	VALUES 
	(
            @EmployeeLastName
            ,@EmployeeFirstName
            ,@EmployeeMiddleInitial
            ,@EmployeeDateOfBirth
            ,@EmployeeNumber
            ,@EmployeeGender
            ,@EmployeeSSN
        );

-- get the employeeid
        SELECT @EmployeeID = @@IDENTITY;
		

		RETURN @EmployeeID;
 END TRY
BEGIN CATCH
--inserting logerrors
		INSERT INTO tblLogErrors (
			ErrorNumber
			,ErrorSeverity
			,ErrorState
			,ErrorProcedure
			,ErrorLine
			,ErrorMessage
			,ErrorUser
			,ErrorDateTime
		)
		SELECT  ErrorNumber = ERROR_NUMBER()
				,ErrorSeverity = ERROR_SEVERITY()
				,ErrorState = ERROR_STATE()
				,ErrorProcedure = ERROR_PROCEDURE()
				,ErrorLine = ERROR_LINE()
				,ErrorMessage = ERROR_MESSAGE()
				,ErrorUser = SYSTEM_USER
				,GETDATE()
		
	END CATCH;
END;
go



-------------------------------------------------------------------------------
-- usp_DeleteEmployee
-------------------------------------------------------------------------------

RAISERROR (N'Creating Stored Procedure %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'usp_DeleteEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP PROCEDURE IF EXISTS usp_DeleteEmployee;
GO

CREATE PROCEDURE usp_DeleteEmployee

-- Create stored procedure usp_DeleteEmployee which adheres to Stored Procedure Standards
/********************************************************************************
Create Date: 03/18/2024
Parameter 1: @EmployeeID
Functionality: Given and employee id, do a proper delete
Assumptions: Create stored procedure usp_DeleteEmployee
********************************************************************************/
    @EmployeeID INT
AS
BEGIN
	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING
    DECLARE @ErrorMessage NVARCHAR(125)
    DECLARE @ErrorNumber int

	BEGIN TRY
-- Delete this 
        DELETE 
		FROM tblEmployee 
		WHERE EmployeeID = @EmployeeID;

     
-- Log delete in the tblLogsError table
	INSERT INTO tblLogErrors (
			ErrorMessage
			,ErrorDateTime
		)
        VALUES
		(
			ERROR_MESSAGE()
			,GETDATE()
		);

    END TRY

       BEGIN CATCH
--inserting logerrors
		INSERT INTO tblLogErrors (
			ErrorNumber
			,ErrorSeverity
			,ErrorState
			,ErrorProcedure
			,ErrorLine
			,ErrorMessage
			,ErrorUser
			,ErrorDateTime
		)
		SELECT  ErrorNumber = ERROR_NUMBER()
				,ErrorSeverity = ERROR_SEVERITY()
				,ErrorState = ERROR_STATE()
				,ErrorProcedure = ERROR_PROCEDURE()
				,ErrorLine = ERROR_LINE()
				,ErrorMessage = ERROR_MESSAGE()
				,ErrorUser = SYSTEM_USER
				,GETDATE()
	END CATCH;
END;
GO

-------------------------------------------------------------------------------
-- usp_UpdateEmployee
-------------------------------------------------------------------------------

RAISERROR (N'Creating Stored Procedure %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'usp_UpdateEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO
DROP PROCEDURE IF EXISTS usp_UpdateEmployee;
GO

CREATE PROCEDURE usp_UpdateEmployee
/********************************************************************************
Create Date: 03/18/2024
Parameter 1: @EmployeeID
Parameter 2: @EmployeeLastName
Parameter 3: @EmployeeFirstName
Parameter 4: @EmployeeMiddleInitial
Parameter 5: @EmployeeDateOfBirth
Parameter 6: @EmployeeNumber
Parameter 7: @EmployeeGender
Parameter 8: @EmployeeSSN

Functionality: Make sure no business rules or contstraints are violated.
Assumptions: Create stored procedure usp_UpdateEmployee
*/

/* 
		
		EXEC  usp_UpdateEmployee 
					3
					,'Doe'
					,'Davie'
					,'L'
					,'08/01/1970'
					,'C123456'
					,'M'
					,'123459696'
					,1

	SELECT @RC
					*/

     @EmployeeID INT
    ,@EmployeeLastName VARCHAR(1000)
    ,@EmployeeFirstName VARCHAR(1000)
    ,@EmployeeMiddleInitial CHAR(1)
    ,@EmployeeDateOfBirth DATE
    ,@EmployeeNumber VARCHAR(10)
    ,@EmployeeGender CHAR(1)
    ,@EmployeeSSN NVARCHAR(9)
AS
BEGIN

	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING
    DECLARE @CustomErrorMessage NVARCHAR(125)
    DECLARE @CustomErrorNumber int

    BEGIN TRY

-- check for the business rules print out the custom error codes

	IF LEN(@EmployeeMiddleInitial) > 1
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Middle Initial'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

     IF @EmployeeDateOfBirth < DATEADD(YEAR, -65, GETDATE()) OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeGender NOT IN ('M', 'F')
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Gender'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END
        
	IF @EmployeeLastName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeFirstName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing First Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeDateOfBirth IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'Missing DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeSSN IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'SSN is NULL'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeNumber NOT LIKE LEFT(@EmployeeLastName, 1) + '%'
	BEGIN
		SELECT @CustomErrorMessage = 'Employee Number does not start with first letter of Employee Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END


-- update the following
	UPDATE tblEmployee
	SET EmployeeLastName = @EmployeeLastName
        ,EmployeeFirstName = @EmployeeFirstName
        ,EmployeeMiddleInitial = @EmployeeMiddleInitial
        ,EmployeeDateOfBirth = @EmployeeDateOfBirth
        ,EmployeeNumber = @EmployeeNumber
        ,EmployeeGender = @EmployeeGender
        ,EmployeeSSN = @EmployeeSSN
       
	WHERE EmployeeID = @EmployeeID;
      
-- Log Update in the tblLogsError
	INSERT INTO tblLogErrors (
			ErrorMessage
			,ErrorDateTime
		)
        VALUES
		(
			ERROR_MESSAGE()
			,GETDATE()
		);



 END TRY
	BEGIN CATCH

--inserting logerrors
		INSERT INTO tblLogErrors (
			ErrorNumber
			,ErrorSeverity
			,ErrorState
			,ErrorProcedure
			,ErrorLine
			,ErrorMessage
			,ErrorUser
			,ErrorDateTime
		)
		SELECT  ErrorNumber = ERROR_NUMBER()
				,ErrorSeverity = ERROR_SEVERITY()
				,ErrorState = ERROR_STATE()
				,ErrorProcedure = ERROR_PROCEDURE()
				,ErrorLine = ERROR_LINE()
				,ErrorMessage = ERROR_MESSAGE()
				,ErrorUser = SYSTEM_USER
				,GETDATE()
		
	END CATCH;
END;

GO

-- CREATE SOME TEST DATA
EXEC  usp_InsertEmployee 
					'Doe'
					,'Joe'
					,'J'
					,'11/21/1970'
					,'D111111'
					,'M'
					,'123459697'


EXEC  usp_InsertEmployee 
					'Doe'
					,'Dory'
					,'A'
					,'08/21/1981'
					,'D222222'
					,'F'
					,'123459698'


EXEC  usp_InsertEmployee 
					'Doe'
					,'Larry'
					,''
					,'12/21/1970'
					,'D333333'
					,'M'
					,'123459699'

--******************************************************************************
-- CREATE PROTOTYPE REBUILD PART 2
--******************************************************************************

-- Insert a new employee using the stored procedure (Create Date/By populated, Modify Date/By not populated)
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Doe'
    ,@EmployeeFirstName = 'John'
    ,@EmployeeMiddleInitial = 'J'
    ,@EmployeeDateOfBirth = '1990-01-01'
    ,@EmployeeNumber = 'D123456'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '123456789';


-- Insert a new 2nd employee using the stored procedure (Create Date/By populated, Modify Date/By not populated)
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Doe'
    ,@EmployeeFirstName = 'Jane'
    ,@EmployeeMiddleInitial = 'J'
    ,@EmployeeDateOfBirth = '1996-06-06'
    ,@EmployeeNumber = 'D654321'
    ,@EmployeeGender = 'F'
    ,@EmployeeSSN = '987654321';

SELECT * FROM tblEmployee;
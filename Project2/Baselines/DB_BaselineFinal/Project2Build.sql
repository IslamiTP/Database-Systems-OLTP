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
-- Employee History Table
-------------------------------------------------------------------------------
RAISERROR (N'Creating Table %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'tblEmployeeHistory', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

-- Create the tblEmployeeHistory table for tracking changes over time
DROP TABLE IF EXISTS tblEmployeeHistory;
GO

CREATE TABLE tblEmployeeHistory (
/********************************************************************************
Author Name: IslamiTP
Create Date: 03/29/2025
	Parameter 1: @EmployeeHistoryID
	Parameter 2: @EmployeeID
	Parameter 3: @EmployeeLastName
	Parameter 4: @EmployeeFirstName
	Parameter 5: @EmployeeMiddleInitial
	Parameter 6: @EmployeeDateOfBirth
	Parameter 7: @EmployeeNumber
	Parameter 8: @EmployeeGender
	Parameter 9: @EmployeeSSN
	Parameter 10: @EmployeeActiveFlag
	Parameter 11: @CreatedDate
	Parameter 12: @CreatedBy
	Parameter 13: @ModifiedDate
	Parameter 14: @ModifiedBy

Functionality: 
	Create a table for tracking employee history over time, ensuring the system 
	captures necessary employee data with proper identity, and records any 
	changes to the employee's information.

Assumptions: 
	Create table tblEmployeeHistory for auditing purposes, with fields to track
	employee details and maintain history for any modifications.
********************************************************************************/

    EmployeeHistoryID INT IDENTITY(1,1) PRIMARY KEY,  -- Identity column for history
    EmployeeID INT,  -- EmployeeID from tblEmployee (no identity here)
    EmployeeLastName NVARCHAR(1000) NOT NULL,
    EmployeeFirstName NVARCHAR(1000) NOT NULL,
    EmployeeMiddleInitial NVARCHAR(1),
    EmployeeDateOfBirth DATE NOT NULL,
    EmployeeNumber NVARCHAR(10) NOT NULL,
    EmployeeGender VARCHAR(1) NOT NULL,
    EmployeeSSN NVARCHAR(9) NOT NULL,
    EmployeeActiveFlag INT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) DEFAULT SUSER_NAME(),
    ModifiedDate DATETIME,
    ModifiedBy NVARCHAR(1000)
);
GO


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
					'Colon'
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
					,'Colon'
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
					'Colon'
					,'Joseph'
					,'J'
					,'11/21/1970'
					,'C111111'
					,'M'
					,'123459697'


EXEC  usp_InsertEmployee 
					'Colon'
					,'Renee'
					,'A'
					,'08/21/1981'
					,'C222222'
					,'F'
					,'123459698'


EXEC  usp_InsertEmployee 
					'Colon'
					,'Damian'
					,''
					,'12/21/1970'
					,'C333333'
					,'M'
					,'123459699'

--******************************************************************************
-- CREATE PROTOTYPE REBUILD PART 2
--******************************************************************************

-- Insert a new 4th employee using the stored procedure (Create Date/By populated, Modify Date/By not populated)
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Doe'
    ,@EmployeeFirstName = 'John'
    ,@EmployeeMiddleInitial = 'J'
    ,@EmployeeDateOfBirth = '1990-01-01'
    ,@EmployeeNumber = 'D123456'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '123456789';


-- Insert a new 5th employee using the stored procedure (Create Date/By populated, Modify Date/By not populated)
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Doe'
    ,@EmployeeFirstName = 'Jane'
    ,@EmployeeMiddleInitial = 'J'
    ,@EmployeeDateOfBirth = '1996-06-06'
    ,@EmployeeNumber = 'D654321'
    ,@EmployeeGender = 'F'
    ,@EmployeeSSN = '987654321';

SELECT * FROM tblEmployee;


--******************************************************************************
-- CREATE TRIGGERS
--******************************************************************************

-------------------------------------------------------------------------------
-- Employee Update Trigger
-------------------------------------------------------------------------------
RAISERROR (N'Creating Trigger %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'trgEmployeeUpdate', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

-- Trigger for updating ModifiedDate, ModifiedBy, and storing history
DROP TRIGGER IF EXISTS trgEmployeeUpdate;
GO

CREATE TRIGGER trgEmployeeUpdate ON tblEmployee
/********************************************************************************
Author Name: IslamiTP
Create Date: 03/29/2025
	Parameter 1: @EmployeeID
	Parameter 2: @EmployeeLastName
	Parameter 3: @EmployeeFirstName
	Parameter 4: @EmployeeMiddleInitial
	Parameter 5: @EmployeeDateOfBirth
	Parameter 6: @EmployeeNumber
	Parameter 7: @EmployeeGender
	Parameter 8: @EmployeeSSN
	Parameter 9: @EmployeeActiveFlag
	Parameter 10: @CreatedDate
	Parameter 11: @CreatedBy
	Parameter 12: @ModifiedDate
	Parameter 13: @ModifiedBy

Functionality: 
	Create a trigger that tracks updates made to employee data by copying the 
	modified record to the history table and updating the ModifiedDate 
	and ModifiedBy fields.

Assumptions: 
	Create trigger trgEmployeeUpdate to ensure any employee update action is 
	logged and the history table is maintained for future reference.
********************************************************************************/

FOR UPDATE
AS
BEGIN
	
	SET NOCOUNT ON; -- to prevent extra results from interfering -w- SELECT stat.
	
    -- Insert a copy of the record into the history table before updating
    INSERT INTO tblEmployeeHistory (
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeMiddleInitial,
        EmployeeDateOfBirth,
        EmployeeNumber,
        EmployeeGender,
        EmployeeSSN,
        EmployeeActiveFlag,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    )
    SELECT 
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeMiddleInitial,
        EmployeeDateOfBirth,
        EmployeeNumber,
        EmployeeGender,
        EmployeeSSN,
        EmployeeActiveFlag,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    FROM deleted;

    -- Update the ModifiedDate and ModifiedBy fields
    UPDATE tblEmployee
    SET  ModifiedDate = GETDATE()
        ,ModifiedBy = SUSER_NAME()
	FROM tblEmployee e
	INNER JOIN inserted i on
		e.EmployeeID = i.EmployeeID
END;
GO

-------------------------------------------------------------------------------
-- Trigger Employee Delete
-------------------------------------------------------------------------------
RAISERROR (N'Creating Trigger %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'trgEmployeeDelete', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

-- Trigger for logical deletion and storing history
DROP TRIGGER IF EXISTS trgEmployeeDelete;
GO

CREATE TRIGGER trgEmployeeDelete ON tblEmployee
/********************************************************************************
Author Name: IslamiTP
Create Date: 03/29/2025
	Parameter 1: @EmployeeID
	Parameter 2: @EmployeeLastName
	Parameter 3: @EmployeeFirstName
	Parameter 4: @EmployeeMiddleInitial
	Parameter 5: @EmployeeDateOfBirth
	Parameter 6: @EmployeeNumber
	Parameter 7: @EmployeeGender
	Parameter 8: @EmployeeSSN
	Parameter 9: @EmployeeActiveFlag
	Parameter 10: @CreatedDate
	Parameter 11: @CreatedBy
	Parameter 12: @ModifiedDate
	Parameter 13: @ModifiedBy

Functionality: 
	Create a trigger for logical deletion, where the employee's record is moved 
	to the history table and the EmployeeActiveFlag is set to 0, marking 
	the employee as inactive.

Assumptions: 
	Create trigger trgEmployeeDelete to ensure that instead of physically 
	deleting an employee record, a logical deletion is performed with 
	history preservation.
********************************************************************************/
INSTEAD OF DELETE
AS
BEGIN

    -- Insert a copy of the record into the history table before deleting
    INSERT INTO tblEmployeeHistory (
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeMiddleInitial,
        EmployeeDateOfBirth,
        EmployeeNumber,
        EmployeeGender,
        EmployeeSSN,
        EmployeeActiveFlag,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    )
    SELECT 
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeMiddleInitial,
        EmployeeDateOfBirth,
        EmployeeNumber,
        EmployeeGender,
        EmployeeSSN,
        EmployeeActiveFlag,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    FROM deleted;

    -- Update the EmployeeActiveFlag to 0 for logical deletion
    UPDATE tblEmployee
    SET 
        EmployeeActiveFlag = 0
    WHERE EmployeeID IN (SELECT EmployeeID FROM deleted);
END;
GO
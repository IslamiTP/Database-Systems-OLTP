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
-------------------------------------------------------------------------------
Author Name:	IslamiTP
Mod Date:		18/04/2025
Description:	1) Created centralized business rule function
				2) Refactored insert and update procedures
				3) Added cursor-based error message handling
				4) Ensured single error log entry per violation group
				5) Added full validation test coverage

Assumptions: Business rule violations must be evaluated consistently 
			 across all procedures
********************************************************************************/

--******************************************************************************
-- CREATE HUMAN RESOURCES DATABASE
--******************************************************************************

use master;
go

RAISERROR (N'Creating Database %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResourcesProject4', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

-- If the database exists it should be dropped
IF EXISTS (SELECT * FROM sys.databases WHERE [name] = 'HumanResourcesProject4')
BEGIN
	ALTER DATABASE HumanResourcesProject4 set SINGLE_USER with ROLLBACK Immediate;
	DROP DATABASE HumanResourcesProject4;
END
GO

-- Create the new HumanResources database
CREATE DATABASE HumanResourcesProject4;
GO

--******************************************************************************
-- CREATE TABLES
--******************************************************************************

-- Use the new HumanResourcesProject4 database
USE HumanResourcesProject4;
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
    EmployeeLastName			NVARCHAR(1000) ,
    EmployeeFirstName			NVARCHAR(1000) ,
    EmployeeMiddleInitial		NVARCHAR(1) NULL,
    EmployeeDateOfBirth			DATE ,
    EmployeeNumber				NVARCHAR(10),
    EmployeeGender				VARCHAR(1),
    EmployeeSSN					NVARCHAR(9),
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
-- CREATE USER DEFINED FUNCTION 
--******************************************************************************
-------------------------------------------------------------------------------
-- ufn_EvaluateEmployeeBusinessRules
-------------------------------------------------------------------------------
--******************************************************************************
-- NOT SURE IF NECESSARY
DROP FUNCTION IF EXISTS ufn_EvaluateEmployeeBusinessRules
GO

CREATE FUNCTION ufn_EvaluateEmployeeBusinessRules(
/********************************************************************************
Author Name: IslamiTP
Create Date: 18/04/2025 -- DD/MM/YYYY
Parameter 1: @EmployeeLastName
Parameter 2: @EmployeeFirstName
Parameter 3: @EmployeeMiddleInitial
Parameter 4: @EmployeeDateOfBirth
Parameter 5: @EmployeeNumber
Parameter 6: @EmployeeGender
Parameter 7: @EmployeeSSN
Functionality: Handles Business rules for insert and update procedure.
Assumptions:	Validates all fields consistently in one place.
********************************************************************************/

	--Input Parameters
	@EmployeeLastName NVARCHAR(1000),
    @EmployeeFirstName NVARCHAR(1000),
    @EmployeeMiddleInitial NVARCHAR(10),
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber VARCHAR(10),
    @EmployeeGender VARCHAR(1),
    @EmployeeSSN NVARCHAR(9)
)


RETURNS @ViolationTable Table
(

	BRViolationID INT IDENTITY(1,1)
	,BRViolationErrorDescription NVARCHAR(1000)

)
AS

BEGIN
	-- START CHECKING BUSSINESS RULES -- INSERT Violations
	
	    -- Middle Initial Length Check
    IF LEN(@EmployeeMiddleInitial) > 1
        INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Invalid Middle Initial: Length > 1');

    -- Missing Date of Birth
    IF ISNULL(@EmployeeDateOfBirth, '') = ''
	BEGIN
		INSERT INTO @ViolationTable VALUES ('Missing Date of Birth');
	END
    -- Invalid Date of Birth Range (not between 18�65)
    ELSE IF @EmployeeDateOfBirth < DATEADD(YEAR, -65, GETDATE()) 
		 OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
	BEGIN         
		INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Invalid Date of Birth � must be between 18 and 65 years old');
	END

    -- Missing Gender
    IF ISNULL(@EmployeeGender, '') = ''
    BEGIN
		INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Missing Gender');
	END
    -- Invalid Gender
    ELSE IF ISNULL(@EmployeeGender, '') NOT IN ('M', 'F')
    BEGIN
		INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Invalid Gender � must be M or F');
	END

    -- Missing Last Name
    IF ISNULL(@EmployeeLastName, '') = ''
        INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Missing Last Name');

    -- Missing First Name
    IF ISNULL(@EmployeeFirstName, '') = ''
        INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Missing First Name');

    -- Missing SSN
    IF ISNULL(@EmployeeSSN, '') = ''
        INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES ('Missing SSN');

    -- Employee Number Format Check (must start with first letter of last name)
    IF ISNULL(@EmployeeNumber, '') 
	NOT LIKE LEFT(ISNULL(@EmployeeLastName, ''), 1) + '%'
        INSERT INTO @ViolationTable (BRViolationErrorDescription)
		VALUES 
		('Employee Number must start with the first letter of Last Name');

	RETURN;
END
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
--------------------------------------------------------------------------------
Modified By: IslamiTP
Mod Date:    20/04/2025
Description: 
    - Integrated centralized validation using ufn_EvaluateEmployeeBusinessRules
    - Replaced individual checks with dynamic rule evaluation
    - Used a cursor to concatenate multiple violations into one message
    - Logged violations as a single entry in tblLogErrors (Error #50500)
********************************************************************************/
/* DECLARE @EmployeeID INT
	DECLARE @RC INT
		
		EXEC  @RC  = usp_InsertEmployee 
					'Doe'
					,'David'
					,'L'
					,'08/01/1970'
					,'D123456'
					,'M'
					,'123459696'
					,@EmployeeID

	SELECT @RC
					*/

    @EmployeeLastName NVARCHAR(1000)
    ,@EmployeeFirstName NVARCHAR(1000)
    ,@EmployeeMiddleInitial NVARCHAR(10)
    ,@EmployeeDateOfBirth DATE
    ,@EmployeeNumber VARCHAR(10)
    ,@EmployeeGender VARCHAR(1)
    ,@EmployeeSSN	NVARCHAR(9)
	,@EmployeeID	INT  = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- Setting up the ufn function calling
	DECLARE @ViolationCount INT;

	-- TEMP TABlE TO STORE RULE VIOLATIONS
	DECLARE @ViolationTable TABLE (
		BRViolationID INT
		,BRViolationErrorDescription NVARCHAR(1000)
	);

	INSERT INTO @ViolationTable (BRViolationID, BRViolationErrorDescription)
	SELECT BRViolationID, BRViolationErrorDescription 
	FROM dbo.ufn_EvaluateEmployeeBusinessRules(
		@EmployeeLastName
		,@EmployeeFirstName
		,@EmployeeMiddleInitial
		,@EmployeeDateOfBirth
		,@EmployeeNumber
		,@EmployeeGender
		,@EmployeeSSN
	);


	-- Check if any violations were returned
    SELECT @ViolationCount = COUNT(*) FROM @ViolationTable;

	IF @ViolationCount > 0
	BEGIN

		-- Build the custom error message string
        DECLARE @Message NVARCHAR(MAX) = 
            CAST(@ViolationCount AS NVARCHAR(10)) 
			+ ' Employee Business Rule Violation(s) encountered: ' 
			+ CHAR(13) + CHAR(10);

		DECLARE @ViolationText NVARCHAR(1000);

		-- Could set as a cursor , double check method.
        DECLARE RuleCursor CURSOR FOR
			SELECT BRViolationErrorDescription FROM @ViolationTable;

		OPEN RuleCursor;
        FETCH NEXT FROM RuleCursor INTO @ViolationText;

		WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @Message = @Message + CHAR(9) + @ViolationText 
			+ CHAR(13) + CHAR(10);
			FETCH NEXT FROM RuleCursor INTO @ViolationText;        
		END;

		CLOSE RuleCursor;
        DEALLOCATE RuleCursor;
		-- END OF CURSOR LOGIC


		 -- Logs the errors (just once)
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
        SELECT
            50500,
            16,
            1,
            OBJECT_NAME(@@PROCID),
            0,
            @Message,
            SYSTEM_USER,
            GETDATE();

        -- Raise a single combined error
        RAISERROR (@Message, 16, 1);
        RETURN;
    END;


		-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING
    BEGIN TRY
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
---------------------------------------------------------------------------------
Modified By: IslamiTP
Mod Date:    20/04/2025
Description:
    - Replaced hardcoded checks with centralized rule validation via function
    - Added cursor logic to format multiple rule violations into one message
    - Logged all violations as a single entry in tblLogErrors (Error #50500)
    - Fixed parameter type mismatch and improved DOB/gender validation flow
********************************************************************************/
/* 
		
		EXEC  usp_UpdateEmployee 
					3
					,'Doe'
					,'Davie'
					,'L'
					,'08/01/1970'
					,'D123456'
					,'M'
					,'123459696'
					,1

	SELECT @RC
					*/

     @EmployeeID INT
    ,@EmployeeLastName VARCHAR(1000)
    ,@EmployeeFirstName VARCHAR(1000)
    ,@EmployeeMiddleInitial NVARCHAR(10)
    ,@EmployeeDateOfBirth DATE
    ,@EmployeeNumber VARCHAR(10)
    ,@EmployeeGender CHAR(1)
    ,@EmployeeSSN NVARCHAR(9)
AS
BEGIN

	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING
    --DECLARE @CustomErrorMessage NVARCHAR(125)
    --DECLARE @CustomErrorNumber int


	-- Setting Up ufn function
	DECLARE @ViolationCount INT;

	--TEMP TABLE TO STORE RULE VIOLATIONS
	DECLARE @ViolationTable TABLE(
		BRViolationID int
		,BRViolationErrorDescription NVARCHAR(1000)
	);

	INSERT INTO @ViolationTable (BRViolationID, BRViolationErrorDescription)
	SELECT BRViolationID, BRViolationErrorDescription
	FROM ufn_EvaluateEmployeeBusinessRules(
			@EmployeeLastName
			,@EmployeeFirstName
			,@EmployeeMiddleInitial
			,@EmployeeDateOfBirth
			,@EmployeeNumber
			,@EmployeeGender
			,@EmployeeSSN
	);


	-- CHECK IF ANY Violations are returned
	SELECT @ViolationCount = COUNT(*) FROM @ViolationTable;

	
	-- BEGINNING OF FUNCTION LOGIC
	IF @ViolationCount > 0
	BEGIN
		
		DECLARE @Message NVARCHAR(MAX) = 
			CAST(@ViolationCount AS NVARCHAR(10))
			+ ' Employee Business Rule Violation(s) encountered: '
			+ char(13) + char(10);
		
		-- This sets the message of the violation(s)
		DECLARE  @ViolationText NVARCHAR(1000);
		
		-- START OF THE CURSOR LOGIC
		DECLARE RuleCursor CURSOR FOR
			SELECT BRViolationErrorDescription FROM @ViolationTable;

		OPEN RuleCursor;
		FETCH NEXT FROM RuleCursor INTO @ViolationText;

		-- WHILE LOOP STATEMENT
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Message = @Message + char(9) + @ViolationText
					+ char(13) + char(10);
					FETCH NEXT FROM RuleCursor INTO @ViolationText;
		END

		CLOSE RuleCursor;
		DEALLOCATE RuleCursor;
		-- END OF CURSOR LOGIC

		 -- Logs the errors (just once)
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
        SELECT
            50500,
            16,
            1,
            OBJECT_NAME(@@PROCID),
            0,
            @Message,
            SYSTEM_USER,
            GETDATE();

        -- Raise a single combined error
        RAISERROR (@Message, 16, 1);
        RETURN;
    END;
		-- END OF FUNCTION CALLING --


	BEGIN TRY
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
					,'Joseph'
					,'J'
					,'11/21/1970'
					,'D111111'
					,'M'
					,'123459697'


EXEC  usp_InsertEmployee 
					'Doe'
					,'Renee'
					,'A'
					,'08/21/1981'
					,'D222222'
					,'F'
					,'123459698'


EXEC  usp_InsertEmployee 
					'Doe'
					,'Damian'
					,''
					,'12/21/1970'
					,'D333333'
					,'M'
					,'123459699'

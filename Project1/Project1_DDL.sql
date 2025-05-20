/******************************************************************
*                                                                *
*                 SECTION: CREATE DATABASE HUMANRESOURCES       *
*                                                                *
******************************************************************/


/****************************************************************
Author Name: IslamiTP
Create Date: 07/03/2025 -- DD/MM/YYYY
Description: Create HumanResources database, taking DEFAULT 
             configuration where applicable.

Functionality:
- Creates a new HumanResources database (commented out).
- Switches context to the HumanResources database to allow further 
  operations like table creation, data insertion, etc.

Assumptions:
- The user has appropriate privileges to create and drop databases.
- Any changes following this script will be made within the context 
  of the HumanResources database.
****************************************************************/
--CREATE DATABASE HumanResources;

-- Uses DATABASE HumanResources for any changes to be made.
USE HumanResources;
GO




/******************************************************************
*                                                                *
*                     SECTION: CREATE tblEmployees               *
*                                                                *
******************************************************************/

/****************************************************************
Author:         IslamiTP
Date:           07/03/2025

Parameter 1:    @EmployeeFirstName             -- First name of the employee
Parameter 2:    @EmployeeLastName              -- Last name of the employee
Parameter 3:    @EmployeeMiddleInitial         -- Optional middle initial
Parameter 4:    @EmployeeDateOfBirth           -- Date of birth
Parameter 5:    @EmployeeNumber                -- Unique 7-character employee number
Parameter 6:    @EmployeeGender                -- Gender (e.g., 'M', 'F')
Parameter 7:    @EmployeeSocialSecurityNumber  -- Unique 9-character SSN
Parameter 8:    @EmployeeActiveFlag            -- Status flag (1 = active, 0 = inactive)
Parameter 9:    @CreatedDate                   -- Timestamp of record creation
Parameter 10:   @CreatedBy                     -- Username or system that created the record
Parameter 11:   @ModifiedDate                  -- Last modification date (managed by trigger)
Parameter 12:   @ModifiedBy                    -- User/system who modified (managed by trigger)

Description:
Creates the 'tblEmployees' table to store personal and employment 
information about staff members, including tracking details 
for auditing purposes.

Functionality:
- Drops the 'tblEmployees' table if it exists.
- Creates a new table with:
    - A primary key auto-incrementing 'EmployeeID'.
    - Required and optional personal data fields.
    - Audit and tracking fields for record lifecycle.
- Certain fields (ModifiedDate, ModifiedBy) are assumed to be updated 
  only via triggers.

Assumptions:
- Table name must follow the 'tbl******' naming convention.
- All column names should be prefixed with the entity they belong to (Employee).
- 'EmployeeActiveFlag' should default to 1 (not currently implemented).
- 'CreatedDate' and 'CreatedBy' are expected to be set at insertion time.
- 'ModifiedDate' and 'ModifiedBy' are maintained automatically by triggers.
- Application code or procedures will enforce data validation (e.g., format of SSN, gender).

****************************************************************/

DROP TABLE IF EXISTS tblEmployees

-- This table lists of the employees information.
CREATE TABLE dbo.tblEmployees (
	EmployeeID INT IDENTITY(1,1) PRIMARY KEY				-- Identity Column
	,EmployeeFirstName nvarchar(25) NOT NULL			-- Required	
	,EmployeeLastName nvarchar(25) NOT NULL				-- Required
	,EmployeeMiddleInitial nvarchar(1)					-- Optional Single Character
	,EmployeeDateOfBirth date NOT NULL					-- Required
	,EmployeeNumber nvarchar(7) NOT NULL				-- Required
	,EmployeeGender varchar(1) NOT NULL					-- Required
	,EmployeeSocialSecurityNumber NVARCHAR(9) NOT NULL	-- Required
	,EmployeeActiveFlag int								-- Default is 1
	,CreatedDate datetime								-- Default to Current Time
	,CreatedBy nvarchar(25)								-- Default to Current Database User
	,ModifiedDate datetime NULL							-- Can Only Be Changed Via Trigger, & Nowhere Else
	,ModifiedBy nvarchar(1000) NULL						-- Can Only Be Changed Via Trigger, & Nowhere Else
);



/******************************************************************
*                                                                *
*                     SECTION: CREATE tblLogErrors               *
*                                                                *
******************************************************************/


/****************************************************************
Author:       IslamiTP
Date:         07/03/2025 

Parameter 1:  @ErrorNumber � Numeric code of the error
Parameter 2:  @ErrorSeverity � Severity level of the error
Parameter 3:  @ErrorState � State or scope of the error
Parameter 4:  @ErrorProcedure � Name of the stored procedure (if applicable)
Parameter 5:  @ErrorLine � Line number where the error occurred
Parameter 6:  @ErrorMessage � Detailed message describing the error
Parameter 7:  @ErrorUser � Username or system context that encountered the error

Description:
Creates the 'tblLogErrors' table to store detailed information 
about errors encountered during database operations. This supports 
debugging, auditing, and tracking system-level issues.

Functionality:
- Drops the existing 'tblLogErrors' table if it exists.
- Creates a new 'tblLogErrors' table with:
   - Auto-incrementing primary key (ErrorLogID).
   - Fields for capturing structured error metadata:
     error number, severity, state, procedure, line, message, and user.

Assumptions:
- Table name must follow the 'tbl******' naming convention.
- Attribute names should include the table name prefix for clarity.
- Error data is expected to be inserted by a TRY...CATCH block or 
  a logging mechanism.
- 'ErrorProcedure' and 'ErrorLine' can be null if context is not available.

****************************************************************/

-- This table is to store error logs for debugging and auditing purposes.
DROP TABLE IF EXISTS tblLogErrors
CREATE TABLE tblLogErrors (
    ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,		-- Identity Column
    ErrorNumber INT NOT NULL,						-- Required
    ErrorSeverity INT NOT NULL,						-- Required
    ErrorState INT NOT NULL,						-- Required
    ErrorProcedure NVARCHAR(128) NULL,				-- Can be NULL (if no procedure is involved)
    ErrorLine INT NULL,								-- Can be NULL (if no line number is recorded)
    ErrorMessage NVARCHAR(4000) NOT NULL,			-- Required
    ErrorUser NVARCHAR(500) NOT NULL,				-- Required
);



/******************************************************************
*                                                                *
*                 SECTION: PROCEDURE usp_InsertEmployees         *
*                                                                *
******************************************************************/



/****************************************************************
Author:         IslamiTP
Date:           14/03/2025

Description:
Creates stored procedure 'usp_InsertEmployees' to insert new 
employees into 'tblEmployees' after validating key business rules.

Parameter 1:    @EmployeeLastName              
Parameter 2:    @EmployeeFirstName             
Parameter 3:    @EmployeeMiddleInitial         
Parameter 4:    @EmployeeDateOfBirth           
Parameter 5:    @EmployeeNumber                
Parameter 6:    @EmployeeGender                
Parameter 7:    @EmployeeSocialSecurityNumber  

Functionality:
- Validates DOB (18�65), middle initial (1 char max), gender ('M'/'F'),
  SSN (9-digit numeric), and employee number format.
- Inserts new employee with audit defaults (ActiveFlag = 1, CreatedDate, CreatedBy).
- Returns generated EmployeeID.
- Catches and logs errors into 'tblLogErrors'.

Assumptions:
- Procedure name follows naming conventions.
- 'tblEmployees' and 'tblLogErrors' exist.
- Audit fields handled by app logic or triggers.
- Data constraints enforced at procedure level.

****************************************************************/


DROP PROCEDURE IF EXISTS usp_InsertEmployees;
GO

CREATE PROCEDURE usp_InsertEmployees
    @EmployeeLastName NVARCHAR(25),
    @EmployeeFirstName NVARCHAR(25),
    @EmployeeMiddleInitial NVARCHAR(1) = '',
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber NVARCHAR(7),
    @EmployeeGender VARCHAR(1),
    @EmployeeSocialSecurityNumber NVARCHAR(9)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewEmployeeID INT;
    DECLARE @CalculatedEmployeeNumber NVARCHAR(7);

    BEGIN TRY
        -- Business Rule 1: Ensure DOB is reasonable (between 18 and 65 years old)
        IF DATEDIFF(YEAR, @EmployeeDateOfBirth, GETDATE()) < 18 OR DATEDIFF(YEAR, @EmployeeDateOfBirth, GETDATE()) > 65
        BEGIN
            RAISERROR ('Invalid DOB. Employee must be between 18 and 65 years old.', 16, 1);
            RETURN;
        END;

        -- Business Rule 2: Ensure Middle Initial is exactly 1 character or empty string
        IF LEN(@EmployeeMiddleInitial) > 1
        BEGIN
            RAISERROR ('Middle Initial must be exactly 1 character or an empty string.', 16, 1);
            RETURN;
        END;

        -- Business Rule 3: Ensure Employee Gender is 'M' or 'F'
        IF @EmployeeGender NOT IN ('M', 'F')
        BEGIN
            RAISERROR ('Invalid Gender. Must be M or F.', 16, 1);
            RETURN;
        END;

        -- Business Rule 4: Ensure Employee Social Security Number is exactly 9 digits and numeric
        IF LEN(@EmployeeSocialSecurityNumber) <> 9 OR @EmployeeSocialSecurityNumber LIKE '%[^0-9]%'
		BEGIN
			RAISERROR('Social Security Number must be exactly 9 numeric digits.', 16, 1);
			RETURN;
		END;

        -- Business Rule 5: Validate Employee Number Format
        SET @CalculatedEmployeeNumber = CONCAT(LEFT(@EmployeeLastName,1), RIGHT(@EmployeeNumber,6));

        IF @EmployeeNumber <> @CalculatedEmployeeNumber
        BEGIN
            RAISERROR ('Invalid Employee Number. It must start with the first letter of Last Name followed by 6 digits.', 16, 1);
            RETURN;
        END;

        -- Insert Employee Record
        INSERT INTO tblEmployees (
            EmployeeFirstName, EmployeeLastName, EmployeeMiddleInitial,
            EmployeeDateOfBirth, EmployeeNumber, EmployeeGender,
            EmployeeSocialSecurityNumber, EmployeeActiveFlag, CreatedDate, CreatedBy
        )
        VALUES (
            @EmployeeFirstName, @EmployeeLastName, @EmployeeMiddleInitial,
            @EmployeeDateOfBirth, @EmployeeNumber, @EmployeeGender,
            @EmployeeSocialSecurityNumber, 1, GETDATE(), SUSER_NAME()
        );

        -- Get the new EmployeeID
        SET @NewEmployeeID = SCOPE_IDENTITY();

        -- Return EmployeeID
        SELECT @NewEmployeeID AS EmployeeID;
    END TRY
    BEGIN CATCH
        -- Capture Error Details
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorUser NVARCHAR(500) = SUSER_NAME();

        -- Log Error in tblLogErrors
        INSERT INTO tblLogErrors (
            ErrorNumber, ErrorSeverity, ErrorState, 
            ErrorProcedure, ErrorLine, ErrorMessage, ErrorUser
        )
        VALUES (
            @ErrorNumber, @ErrorSeverity, @ErrorState, 
            @ErrorProcedure, @ErrorLine, @ErrorMessage,
            @ErrorUser
        );

        -- Print Real Error for Debugging
        PRINT 'INSERT ERROR: ' + @ErrorMessage;

        -- Return the real error message to the caller
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO




/******************************************************************
*                                                                *
*                SECTION: PROCEDURE usp_DeleteEmployees          *
*                                                                *
******************************************************************/


/****************************************************************
Author:         IslamiTP
Date:           14/03/2025

Description:
Creates stored procedure 'usp_DeleteEmployees' to delete an employee 
record from 'tblEmployees' based on EmployeeID.

Parameter 1:    @EmployeeID    -- Required: Unique identifier of the employee

Functionality:
- Verifies existence of the given EmployeeID.
- Deletes the corresponding record from 'tblEmployees'.
- Logs success or failure in 'tblLogErrors'.
- Raises appropriate error messages if the ID does not exist or 
  if an exception occurs.

Assumptions:
- 'tblEmployees' and 'tblLogErrors' exist.
- Procedure name follows standard naming conventions.
- Logging mechanism is used for both success and failure tracking.

****************************************************************/

DROP PROCEDURE IF EXISTS usp_DeleteEmployees;
GO

CREATE PROCEDURE usp_DeleteEmployees
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables for logging
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, 
            @ErrorMessage NVARCHAR(4000), @ErrorProcedure NVARCHAR(128),
            @ErrorLine INT;

    BEGIN TRY
        -- Check if Employee Exists
        IF NOT EXISTS (SELECT 1 FROM tblEmployees WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR ('EmployeeID not found. Deletion failed.', 16, 1);
            RETURN;
        END;

        -- Perform the DELETE operation
        DELETE FROM tblEmployees
        WHERE EmployeeID = @EmployeeID;

        -- Log the successful deletion in tblLogErrors
        INSERT INTO tblLogErrors (
            ErrorNumber, ErrorSeverity, ErrorState, 
            ErrorProcedure, ErrorLine, ErrorMessage, ErrorUser
        )
        VALUES (
            0, 0, 0,  -- No real error occurred, so set to 0
            'usp_DeleteEmployee', NULL, 
            CONCAT('EmployeeID ', @EmployeeID, ' successfully deleted.'),
            SUSER_NAME()
        );

        PRINT 'Employee deleted successfully.';
    END TRY
    BEGIN CATCH
        -- Capture Error Details
        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();
        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorProcedure = ERROR_PROCEDURE();
        SET @ErrorLine = ERROR_LINE();

        -- Log Error in tblLogErrors
        INSERT INTO tblLogErrors (
            ErrorNumber, ErrorSeverity, ErrorState, 
            ErrorProcedure, ErrorLine, ErrorMessage, ErrorUser
        )
        VALUES (
            @ErrorNumber, @ErrorSeverity, @ErrorState, 
            @ErrorProcedure, @ErrorLine, @ErrorMessage,
            SUSER_NAME()
        );

        -- Re-throw the error
        RAISERROR ('Actual Error occurred while deleting employee.', 16, 1);
    END CATCH;
END;
GO



/******************************************************************
*                                                                *
*                SECTION: PROCEDURE usp_UpdateEmployee           *
*                                                                *
******************************************************************/

/****************************************************************
Author:         IslamiTP
Date:           14/03/2025

Description:
Creates stored procedure 'usp_UpdateEmployee' to update employee 
information in 'tblEmployees' based on provided EmployeeID.

Parameter 1:    @EmployeeID
Parameter 2:    @EmployeeLastName
Parameter 3:    @EmployeeFirstName
Parameter 4:    @EmployeeMiddleInitial
Parameter 5:    @EmployeeDateOfBirth
Parameter 6:    @EmployeeNumber
Parameter 7:    @EmployeeGender
Parameter 8:    @EmployeeSocialSecurityNumber
Parameter 9:    @EmployeeActiveFlag

Functionality:
- Verifies existence of EmployeeID before updating.
- Validates DOB (18�100), middle initial (1 char max), gender ('M'/'F'), 
  SSN (9-digit numeric), and employee number format.
- Updates employee record and audit fields (ModifiedDate, ModifiedBy).
- Logs any errors in 'tblLogErrors'.

Assumptions:
- 'tblEmployees' and 'tblLogErrors' exist.
- Audit fields are managed by the procedure.
- Naming conventions are followed for procedures and columns.

****************************************************************/

DROP PROCEDURE IF EXISTS usp_UpdateEmployee;
GO

CREATE PROCEDURE usp_UpdateEmployee
    @EmployeeID INT,
    @EmployeeLastName NVARCHAR(25),
    @EmployeeFirstName NVARCHAR(25),
    @EmployeeMiddleInitial NVARCHAR(1) = '',  
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber NVARCHAR(10),
    @EmployeeGender VARCHAR(1),
    @EmployeeSocialSecurityNumber NVARCHAR(9),
    @EmployeeActiveFlag INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CalculatedEmployeeNumber NVARCHAR(10);
    DECLARE @ErrorMessage NVARCHAR(4000); -- Declare the error message variable

    BEGIN TRY
        -- Check if Employee Exists
        IF NOT EXISTS (SELECT 1 FROM tblEmployees WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR ('EmployeeID not found. Update failed.', 16, 1);
            RETURN;
        END;

        -- Business Rule 1: Ensure DOB is reasonable (between 18 and 100 years old)
        IF DATEDIFF(YEAR, @EmployeeDateOfBirth, GETDATE()) < 18 OR DATEDIFF(YEAR, @EmployeeDateOfBirth, GETDATE()) > 100
        BEGIN
            RAISERROR ('Invalid DOB. Employee must be between 18 and 100 years old.', 16, 1);
            RETURN;
        END;

        -- Business Rule 2: Ensure Middle Initial is exactly 1 character or empty string
        IF LEN(@EmployeeMiddleInitial) > 1
        BEGIN
            RAISERROR ('Middle Initial must be exactly 1 character or an empty string.', 16, 1);
            RETURN;
        END;

        -- Business Rule 3: Ensure Employee Gender is 'M' or 'F'
        IF @EmployeeGender NOT IN ('M', 'F')
        BEGIN
            RAISERROR ('Invalid Gender. Must be M or F.', 16, 1);
            RETURN;
        END;

        -- Business Rule 4: Ensure Employee Social Security Number is exactly 9 digits and numeric
        IF LEN(@EmployeeSocialSecurityNumber) <> 9 OR @EmployeeSocialSecurityNumber LIKE '%[^0-9]%'
        BEGIN
            RAISERROR ('Invalid SSN. Must be exactly 9 digits and numeric.', 16, 1);
            RETURN;
        END;

        -- Business Rule 5: Validate Employee Number Format
        SET @CalculatedEmployeeNumber = CONCAT(LEFT(@EmployeeLastName,1), RIGHT(@EmployeeNumber,6));

        IF @EmployeeNumber <> @CalculatedEmployeeNumber
        BEGIN
            RAISERROR ('Invalid Employee Number. It must start with the first letter of Last Name followed by 6 digits.', 16, 1);
            RETURN;
        END;

        -- Perform Update
        UPDATE tblEmployees
        SET 
            EmployeeFirstName = @EmployeeFirstName,
            EmployeeLastName = @EmployeeLastName,
            EmployeeMiddleInitial = @EmployeeMiddleInitial,
            EmployeeDateOfBirth = @EmployeeDateOfBirth,
            EmployeeNumber = @EmployeeNumber,
            EmployeeGender = @EmployeeGender,
            EmployeeSocialSecurityNumber = @EmployeeSocialSecurityNumber,
            EmployeeActiveFlag = @EmployeeActiveFlag,
            ModifiedDate = GETDATE(),  -- Set the ModifiedDate to current timestamp
            ModifiedBy = SUSER_NAME()  -- Set the ModifiedBy to the current user
        WHERE EmployeeID = @EmployeeID;

        PRINT 'Employee updated successfully.';
    END TRY
    BEGIN CATCH
        -- Capture Error Details
        SET @ErrorMessage = ERROR_MESSAGE();  -- Assign the error message to the variable

        -- Log Error in tblLogErrors
        INSERT INTO tblLogErrors (
            ErrorNumber, ErrorSeverity, ErrorState, 
            ErrorProcedure, ErrorLine, ErrorMessage, ErrorUser
        )
        VALUES (
            ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), 
            ERROR_PROCEDURE(), ERROR_LINE(), @ErrorMessage,
            SUSER_NAME()
        );

        -- Print Real Error for Debugging
        PRINT 'Actual Error: ' + @ErrorMessage;

        -- Return the real error message to the caller
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

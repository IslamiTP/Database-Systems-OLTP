
USE HumanResources;
GO

--******************************************************************************
-- CREATE BUSINESS SCENARIO
--******************************************************************************
-------------------------------------------------------------------------------
-- REQUIRED SCENARIO 2
-- Demonstrate Update Employee Scenario -w- ModifiedDate/By Populated
-------------------------------------------------------------------------------
-- Insert a new employee using the stored procedure (Create Date/By populated, Modify Date/By not populated)
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Cox'
    ,@EmployeeFirstName = 'Brian'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1968-03-03'
    ,@EmployeeNumber = 'C123456'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '457601111';
SELECT * FROM tblEmployee WHERE EmployeeID = 6;


-------------------------------------------------------------------------------
-- REQUIRED SCENARIO 3
-- Demonstrate Update Employee Scenario -w- ModifiedDate/By Populated
-------------------------------------------------------------------------------
-- Update an existing employee's record (Modify Date/By should be populated)
EXEC usp_UpdateEmployee
    @EmployeeID = 6
    ,@EmployeeLastName = 'Tyson'
    ,@EmployeeFirstName = 'Neil'
    ,@EmployeeMiddleInitial = 'D'
    ,@EmployeeDateOfBirth = '1990-01-01'
    ,@EmployeeNumber = 'T123456'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '987654321';


-- Verify that Modify Date and Modify By are populated
SELECT * FROM tblEmployee WHERE EmployeeID = 6;

-------------------------------------------------------------------------------
-- REQUIRED SCENARIO 4
-- NO CHANGE IN CREATEDDATE AFTER RECORD MODIFICATION
-------------------------------------------------------------------------------
-- Verify that Create Date and Created By remain unchanged after modification
SELECT EmployeeID, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy 
FROM tblEmployee 
WHERE EmployeeID = 6;


-------------------------------------------------------------------------------
-- REQUIRED SCENARIO 5
-- Delete Employee Scenario
-------------------------------------------------------------------------------

-- Perform a logical delete (EmployeeActiveFlag set to 0 instead of physical deletion)
EXEC usp_DeleteEmployee @EmployeeID = 6;

-- Verify that EmployeeActiveFlag is set to 0 (inactive)
SELECT * FROM tblEmployee WHERE EmployeeID = 6;

-- Check the tblEmployeeHistory to ensure the record was copied before deletion
SELECT * FROM tblEmployeeHistory WHERE EmployeeID = 6;


-------------------------------------------------------------------------------
-- REQUIRED SCENARIO 6
-- CRUD OPERATION
-------------------------------------------------------------------------------
-- 1st Update an employee record

-- Insert an employee record 1st
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Smith'
    ,@EmployeeFirstName = 'Jane'
    ,@EmployeeMiddleInitial = 'A'
    ,@EmployeeDateOfBirth = '1985-05-15'
    ,@EmployeeNumber = 'S987654'
    ,@EmployeeGender = 'F'
    ,@EmployeeSSN = '987654321';

SELECT * FROM tblEmployee WHERE EmployeeID = 7;

-- Update the employee record
EXEC usp_UpdateEmployee
    @EmployeeID = 7
    ,@EmployeeLastName = 'Smith'
    ,@EmployeeFirstName = 'Janet'
    ,@EmployeeMiddleInitial = 'B'
    ,@EmployeeDateOfBirth = '1985-05-15'
    ,@EmployeeNumber = 'S987654'
    ,@EmployeeGender = 'F'
    ,@EmployeeSSN = '987654322';

-- Check the tblEmployeeHistory to ensure changes are being tracked
SELECT * FROM tblEmployeeHistory WHERE EmployeeID IN (1, 7);

------------------------------------------------
-- 2nd Update an employee record

-- Insert an employee record 2nd
EXEC usp_InsertEmployee
    @EmployeeLastName = 'Pato'
    ,@EmployeeFirstName = 'Alexandro'
    ,@EmployeeMiddleInitial = 'R'
    ,@EmployeeDateOfBirth = '1989-09-02'
    ,@EmployeeNumber = 'P987654'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '000110000';

SELECT * FROM tblEmployee WHERE EmployeeID = 8;


------------------------------------------------
-- Update the employee record
EXEC usp_UpdateEmployee
    @EmployeeID = 8
    ,@EmployeeLastName = 'Santos'
    ,@EmployeeFirstName = 'Neymar'
    ,@EmployeeMiddleInitial = 'S'
    ,@EmployeeDateOfBirth = '1992-02-05'
    ,@EmployeeNumber = 'S987654'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '999005041';

-- Check the tblEmployeeHistory to ensure changes are being tracked
SELECT * FROM tblEmployeeHistory WHERE EmployeeID IN (1, 8);


------------------------------------------------
-- 3rd Update an employee record

-- Insert an employee record 3rd
EXEC usp_InsertEmployee
    @EmployeeID = 9
    ,@EmployeeLastName = 'Pirlo'
    ,@EmployeeFirstName = 'Andrea'
    ,@EmployeeMiddleInitial = ''
    ,@EmployeeDateOfBirth = '1979-05-19'
    ,@EmployeeNumber = 'P174177'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '987654322';

SELECT * FROM tblEmployee WHERE EmployeeID = 9;

-- Update the employee record
EXEC usp_UpdateEmployee
    @EmployeeID = 9
    ,@EmployeeLastName = 'Gattuso'
    ,@EmployeeFirstName = 'Gennaro'
    ,@EmployeeMiddleInitial = 'I'
    ,@EmployeeDateOfBirth = '1978-01-09'
    ,@EmployeeNumber = 'G174177'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '987654322';

-- Check the tblEmployeeHistory to ensure changes are being tracked
SELECT * FROM tblEmployeeHistory WHERE EmployeeID IN (1, 9);

SELECT * FROM tblEmployee WHERE EmployeeID = 9;

-------------------------------------------------------------------------------
-- REQUIRED SCENARIO 7
-- DEMONSTRATE MULTIPE USERS UPDATES
-------------------------------------------------------------------------------
-- First update
EXEC usp_UpdateEmployee
    @EmployeeID = 6,
    @EmployeeLastName = 'Cox'
    ,@EmployeeFirstName = 'Brian'
    ,@EmployeeMiddleInitial = 'B'
    ,@EmployeeDateOfBirth = '1968-03-03'
    ,@EmployeeNumber = 'C001001'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '457601111';

-- Second update
EXEC usp_UpdateEmployee
    @EmployeeID = 6,
    @EmployeeLastName = 'Cox'
    ,@EmployeeFirstName = 'Brian'
    ,@EmployeeMiddleInitial = ''
    ,@EmployeeDateOfBirth = '1968-03-03'
    ,@EmployeeNumber = 'C123456'
    ,@EmployeeGender = 'M'
    ,@EmployeeSSN = '000993636';

-- Check tblEmployeeHistory for both versions of the record
SELECT * FROM tblEmployeeHistory
WHERE EmployeeHistoryID IN (8, 9);

-- Check for the latest update showing in the tblEmployee
SELECT * FROM tblEmployee WHERE EmployeeID = 6;

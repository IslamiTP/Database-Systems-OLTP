USE [HumanResources]
GO

RAISERROR (N'CREATING usp_FetchEmployees %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP PROCEDURE IF EXISTS usp_FetchEmployees
GO

CREATE PROCEDURE usp_FetchEmployees 
    @EmployeeID INT
AS
/********************************************************************************
Author Name: IslamiTP
Create Date: 16/04/2025 -- DD/MM/YYYY

Functionality: 

Assumptions: 

********************************************************************************/
BEGIN
	SET NOCOUNT ON

	DROP TABLE IF EXISTS #Employee 
	CREATE TABLE #Employee  (
		EmployeeID				varchar(25)
		,EmployeeLastName		nvarchar(25)
		,EmployeeFirstName		nvarchar(25)
		,EmployeeEmail			nvarchar(255)
		,EmployeePhone			varchar(100)
		,EmployeeHireDate		varchar(25)
		,EmployeeSalary			varchar(25)
		,DependentLastName		nvarchar(100) 
		,DependentFirstName		nvarchar(100) 
		,DependentRelationship	nvarchar(100) 
	)

	-- Inserting Header Row First --
	INSERT INTO #EMPLOYEE VALUES(
		'EmployeeID'
		,'EmployeeLastName'
		,'EmployeeFirstName'
		,'EmployeeEmail'
		,'EmployeePhone'
		,'EmployeeHireDate'
		,'EmployeeSalary'
		,'DependentLastName'
		,'DependentFirstName'
		,'DependentRelationship'
	)

	-- Temp Table Populate -w- Employee & Dependent Data --
	INSERT INTO #Employee
	SELECT RIGHT('000000' + CAST(e.employee_id AS VARCHAR), 6)
		,e.last_name
		,e.first_name
		,e.email
		,e.phone_number
		,e.hire_date
		,e.salary
		,d.last_name
		,d.first_name
		,d.relationship
	FROM HumanResources.dbo.employees e
	INNER JOIN HumanResources.dbo.dependents d ON d.employee_id = e.employee_id
	WHERE e.employee_id = @EmployeeID
	ORDER BY d.last_name, d.first_name, d.relationship

	SELECT * FROM #Employee;
	
	-- MIGHT REMOVE THIS
	--DROP TABLE #Employee

END
GO

-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
--					            END OF PROCEDURE						      --
-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --


RAISERROR (N'CREATING usp_Process %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO


DROP PROCEDURE IF EXISTS usp_Process
GO

-- This Store Procedure is for the BCP Process.
CREATE PROCEDURE usp_Process 
    @EmployeeID INT	
AS
/********************************************************************************
Author Name: IslamiTP
Create Date: 17/04/2025 -- DD/MM/YYYY
	-- Will Be Filled Later
Functionality: 
	-- Will Be Filled Later	
Assumptions: 
	-- Will Be Filled Later
********************************************************************************/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FrmtEmployeeID NVARCHAR(25) 
	= RIGHT('000000' + CAST(@EmployeeID AS VARCHAR), 6);
	
	DECLARE @CurrentDate VARCHAR(25) = CONVERT(VARCHAR(8), GETDATE(), 112);
	DECLARE @CurrentTime VARCHAR(25) = FORMAT(GETDATE(), 'HHmm');
	DECLARE @FileName NVARCHAR(255) = 'C:\HumanResources\DataTransfer\Census\'
										+ @FrmtEmployeeID  + '_Census_' 
										+ @CurrentDate + '_' 
										+ @CurrentTime + '.csv'	;

	DECLARE @CommandInsert VARCHAR(1000) -- Declaring the BCP Command		
	-- // -- // -- // -- // -- // -- // -- // -- // -- // -- // --	

		-- Prints Each Employee File Process
	PRINT ('Processing Employee' + @FrmtEmployeeID + 'Record: ' + @FileName)	

		-- Fetches Temp Table Data
	EXEC usp_FetchEmployees @EmployeeID = @EmployeeID

	SET @CommandInsert = 'bcp "EXEC HumanResources.dbo.usp_FetchEmployees @EmployeeID = ' 
    + CAST(@EmployeeID AS VARCHAR) + '" queryout "' + @FileName + '" -T -c -t ,'


	-- Outputs the bcp command
	--SELECT @CommandInsert

-- Executes BCP Command	
	EXEC xp_cmdshell @CommandInsert 
	
END
GO


-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
--					            END OF PROCEDURE						      --
-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --


RAISERROR (N'CREATING usp_EmployeeCensus %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP PROCEDURE IF EXISTS usp_EmployeeCensus
GO

CREATE PROCEDURE usp_EmployeeCensus AS
/********************************************************************************
Author Name: IslamiTP
Create Date: 14/04/2025 -- DD/MM/YYYY
	-- Will Fill Later
Functionality: 
	-- Will Fill Later
Assumptions: 
	-- Will Fill Later
********************************************************************************/
BEGIN
	SET NOCOUNT ON

	-- Declare Cursor
    DECLARE EmplCensusCrs CURSOR FOR 
        SELECT employee_id, last_name, first_name
        FROM HumanResources.dbo.employees
        ORDER BY last_name, first_name, employee_id
		
	DECLARE @EmployeeID NVARCHAR(25)
	DECLARE @EmployeeLastName NVARCHAR(25)
	DECLARE @EmployeeFirstName NVARCHAR(25)
		-- // -- // -- // -- // -- // -- // -- // -- // -- // -- // --
	
	OPEN EmplCensusCrs
			-- INITIAL FETCH STATEMENT
		FETCH NEXT FROM EmplCensusCrs
			INTO @EmployeeID, @EmployeeLastName, @EmployeeFirstName
			

		-- WHILE FETCH STATUS
		WHILE @@FETCH_STATUS = 0
			BEGIN

			-- Call BCP Process for this employee
			EXEC usp_Process @EmployeeID			

			FETCH NEXT FROM EmplCensusCrs
			INTO @EmployeeID, @EmployeeLastName, @EmployeeFirstName					
		END
				
	CLOSE EmplCensusCrs
	DEALLOCATE EmplCensusCrs

END
GO

EXEC usp_EmployeeCensus;


-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
--					            END OF PROCEDURE						      --
-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
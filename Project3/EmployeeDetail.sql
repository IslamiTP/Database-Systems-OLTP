USE HumanResources
GO

RAISERROR (N'CREATING usp_EmployeeDetails %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP PROCEDURE IF EXISTS usp_FetchEmployees
GO

CREATE PROCEDURE usp_FetchEmployees AS
/********************************************************************************
Author Name: IslamiTP
Create Date: 18/04/2025 -- DD/MM/YYYY
	-- Will Fill Later
Functionality: 
	-- Will Fill Later
Assumptions: 
	-- Will Fill Later
********************************************************************************/
BEGIN
	SET NOCOUNT ON

	DROP TABLE IF EXISTS #Employee
	CREATE TABLE #Employee  (
		EmployeeID					varchar(25)
		,EmployeeLastName			nvarchar(25)
		,EmployeeFirstName			nvarchar(25)
		,EmployeeEmail				nvarchar(255)
		,EmployeePhone				varchar(100)
		,EmployeeHireDate			varchar(500)
		,EmployeeSalary				varchar(500)
		,DepartmentRegionName		nvarchar(100)
		,DepartmentCountryName		nvarchar(100)
		,DepartmentName				nvarchar(100)
		,DepartmentLocation			nvarchar(100)
		,DepartmentStreetAddress	nvarchar(100)
		,DepartmentCity				nvarchar(100)
		,DepartmentState			nvarchar(100)
		,DepartmentZip				nvarchar(100)
		,JobTitle					nvarchar(500)
		,ManagerLastName			nvarchar(500)
		,ManagerFirstName			nvarchar(500)
	)

	-- INSERTS HEADER ROW FIRST
	INSERT INTO #Employee Values(
		'EmployeeID'
		,'EmployeeLastName'
		,'EmployeeFirstName'
		,'EmployeeEmail'
		,'EmployeePhone'
		,'EmployeeHireDate'
		,'EmployeeSalary'
		,'DepartmentRegionName'
		,'DepartmentCountryName'
		,'DepartmentName'
		,'DepartmentLocation'
		,'DepartmentStreetAddress'
		,'DepartmentCity'
		,'DepartmentState'
		,'DepartmentZip'
		,'JobTitle'
		,'ManagerLastName'
		,'ManagerFirstName'
	)

	-- Temp Table Populate
	INSERT INTO #Employee
	SELECT RIGHT('000000' + CAST(e.employee_id AS varchar),6)
			,e.last_name
			,e.first_name
			,e.email
			,e.phone_number
			,e.hire_date
			,e.salary
			,r.region_name
			,c.country_name
			,d.department_id
			,l.street_address
			,l.city
			,l.state_province
			,l.postal_code
			,c.country_name
			,j.job_title
			,m.last_name
			,m.first_name
	FROM HumanResources.dbo.employees e
	INNER JOIN HumanResources.dbo.employees m ON m.employee_id = e.manager_id
	INNER JOIN HumanResources.dbo.jobs j ON j.job_id = e.job_id
	INNER JOIN HumanResources.dbo.departments d ON d.department_id = e.department_id
	INNER JOIN HumanResources.dbo.locations l ON d.location_id = l.location_id
	INNER JOIN HumanResources.dbo.countries c ON l.country_id = c.country_id
	INNER JOIN HumanResources.dbo.regions r ON c.region_id = r.region_id

	ORDER BY c.country_id, r.region_name, m.last_name, m.first_name, e.last_name, e.first_name

	SELECT * FROM #Employee

	DROP TABLE #Employee
END 
GO		


-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
--					            END OF PROCEDURE						      --
-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --


RAISERROR (N'CREATING usp_EmployeeDetails %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP PROCEDURE IF EXISTS usp_EmployeeDetails
GO

CREATE PROCEDURE usp_EmployeeDetails AS
/********************************************************************************
Author Name: IslamiTP
Create Date: 18/04/2025 -- DD/MM/YYYY
	-- Will Fill Later
Functionality: 
	-- Will Fill Later
Assumptions: 
	-- Will Fill Later
********************************************************************************/
BEGIN
	SET NOCOUNT ON
	

	DECLARE @CurrentDate VARCHAR(25) = CONVERT(VARCHAR(8), GETDATE(), 112);
	DECLARE @CurrentTime VARCHAR(25) = FORMAT(GETDATE(), 'HHmm');
	DECLARE @FileName NVARCHAR(255) = 'C:\HumanResources\DataTransfer\Employee\Acme_Employees_'+ @CurrentDate + '_' + @CurrentTime + '.csv';
	DECLARE @CommandInsert VARCHAR(1000) -- Declaring the BCP Command		

		-- Prints Each Employee File Process
	PRINT ('Processing Employee Record: ' + @FileName)	

		-- Fetches Temp Table Data
	EXEC usp_FetchEmployees

	SET @CommandInsert = 'bcp "HumanResources.dbo.usp_FetchEmployees" queryout "' + @FileName + '"  -T -c -t,'
		
		-- Outputs the bcp command
	SELECT @CommandInsert;

		-- Executes BCP Command	            
	EXEC xp_cmdshell @CommandInsert;

END
GO

EXEC usp_EmployeeDetails;
-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
--					            END OF PROCEDURE						      --
-- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- ---- -- --
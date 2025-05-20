USE HumanResourcesProject4;
GO

truncate table tblLogErrors

-- this is a missing gender
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,''
					,'12/21/1979'
					,'D333333'
					,''
					,'123459699'
-- this is a bad gender
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,''
					,'12/21/1979'
					,'D333333'
					,'G'
					,'123459699'

-- this is a missing date of birth.
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,''
					,''
					,'D333333'
					,'F'
					,'123459699'
-- this is a bad date of birth.
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,''
					,'12/21/2020'
					,'D333333'
					,'F'
					,'123459699'

-- this is a bad employee number
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,''
					,'12/21/1973'
					,'G333333'
					,'F'
					,'123459699'


-- this is a bad middle initial
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,'MI'
					,'12/21/1973'
					,'D333333'
					,'F'
					,'123459699'

-- this is missing last name
EXEC  usp_InsertEmployee 
					''
					,'John'
					,''
					,'12/21/1973'
					,'D333333'
					,'F'
					,'123459699'


-- this is missing first name
EXEC  usp_InsertEmployee 
					'Doe'
					,''
					,''
					,'12/21/1973'
					,'D333333'
					,'F'
					,'123459699'

-- this is missing SSN
EXEC  usp_InsertEmployee 
					'Doe'
					,'John'
					,''
					,'12/21/1973'
					,'D333333'
					,'F'
					,''

select *
from tblLogErrors



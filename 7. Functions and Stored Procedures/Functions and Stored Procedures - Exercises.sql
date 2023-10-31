--01. Employees with Salary Above 35000
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 
AS  
BEGIN
	SELECT 
		 FirstName,
		 LastName
	  FROM Employees
	 WHERE Salary > 35000
END

EXEC dbo.usp_GetEmployeesSalaryAbove35000

--02. Employees with Salary Above Number
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber 
@minSalary DECIMAL (18,4)
AS
BEGIN
	SELECT 
		  FirstName,
		  LastName
	  FROM 
	      Employees
	 WHERE Salary >= @minSalary
END

EXEC dbo.usp_GetEmployeesSalaryAboveNumber 48100

--03. Town Names Starting With
CREATE PROCEDURE usp_GetTownsStartingWith
@subString NVARCHAR(100)
AS 
BEGIN
	SELECT 
	t.[Name]
	FROM Towns AS t
	WHERE t.[Name] LIKE @subString + '%'
END

GO
EXEC dbo.usp_GetTownsStartingWith 'b'

--04. Employees from Town
CREATE PROCEDURE usp_GetEmployeesFromTown 
@townName NVARCHAR(50)
AS
BEGIN
	SELECT 
		   FirstName,
		   LastName	
	  FROM Employees AS e
		   JOIN Addresses AS a
		ON e.AddressID = a.AddressID
		   JOIN Towns AS t
		ON a.TownID = t.TownID
	 WHERE t.Name = @townName
END

EXEC dbo.usp_GetEmployeesFromTown 'Sofia'

--05. Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(10)
AS 
	  BEGIN 
	DECLARE @salaryLevel VARCHAR(10) 
	     IF @salary < 30000
		SET @salaryLevel = 'Low'
	ELSE IF @salary <= 50000
		SET @salaryLevel = 'Average'
	ELSE IF @salary >50000
		SET @salaryLevel = 'High'

	 RETURN @salaryLevel
		END

SELECT 
	 Salary,
	 dbo.ufn_GetSalaryLevel(salary) AS SalaryLevel
  FROM Employees


--06. Employees by Salary Level
CREATE PROCEDURE usp_EmployeesBySalaryLevel (@salaryLevel VARCHAR (8))
AS 
BEGIN
	SELECT FirstName,
		   LastName
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END

EXEC dbo.usp_EmployeesBySalaryLevel 'High'

--07. Define Function
CREATE FUNCTION ufn_IsWordComprised
(@setOfLetters VARCHAR(50), @word VARCHAR(50)) 
RETURNS INT 
AS
BEGIN 
	  DECLARE @startIndex INT = 1
	  WHILE (@startIndex <= LEN(@word))
	  BEGIN 
			DECLARE @currentPosition CHAR = SUBSTRING(@word,@startIndex, 1)
				 IF CHARINDEX(@currentPosition, @setOfLetters) = 0
			  BEGIN 
			 RETURN 0
			    END

			    SET @startIndex += 1
	  END

	  RETURN 1
END

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia') AS Result

--08. *Delete Employees and Departments
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS 
BEGIN 
	 DECLARE @RemovedEmployees TABLE (Id INT)
	 INSERT INTO @RemovedEmployees 
		  SELECT EmployeeID
		    FROM Employees 
		   WHERE DepartmentID = @departmentId

	 DELETE FROM EmployeesProjects
	 WHERE EmployeeID IN (SELECT * FROM @RemovedEmployees)

	 ALTER TABLE Departments 
	 ALTER COLUMN ManagerID INT 

	 UPDATE Departments
		SET ManagerID = NULL
	  WHERE ManagerID IN (SELECT * FROM @RemovedEmployees)
	 
	 UPDATE Employees
		SET ManagerID = NULL
	  WHERE ManagerID IN (SELECT * FROM @RemovedEmployees)

	 DELETE FROM Employees
	 WHERE DepartmentID = @departmentId
	 
	 DELETE FROM Departments
	 WHERE DepartmentID = @departmentId

	 SELECT COUNT(*) FROM Employees
	 WHERE DepartmentID = @departmentId
END

EXEC dbo.usp_DeleteEmployeesFromDepartment 8

SELECT * FROM Employees
WHERE DepartmentID = 8

--09. Find Full Name
CREATE PROCEDURE usp_GetHoldersFullName 
AS 
	BEGIN 
		SELECT CONCAT_WS(' ',FirstName, LastName) AS [Full Name]
		FROM AccountHolders
	END

EXEC dbo.usp_GetHoldersFullName 

--10. People with Balance Higher Than
CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan @number MONEY
AS 
BEGIN 
	
	 SELECT			   
			ah.FirstName,
			ah.LastName
	   FROM AccountHolders AS ah
	   JOIN Accounts AS a ON ah.Id = a.AccountHolderId
   GROUP BY ah.FirstName, ah.LastName, a.AccountHolderId
	 HAVING SUM(a.Balance) > 19999
   ORDER BY FirstName, LastName
	
END 

EXECUTE dbo.usp_GetHoldersWithBalanceHigherThan 10000

--11. Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue 
(@sum DECIMAL (18,4), @yearlyInterestRate FLOAT, @yearNumber INT)
RETURNS DECIMAL (18,4)
AS 
BEGIN 
	 DECLARE @Result DECIMAL (18,4)
	     SET @Result = @sum * POWER(1 + @yearlyInterestRate, @yearNumber)
	  RETURN ROUND(@Result,4)
END

SELECT dbo.ufn_CalculateFutureValue (1000, 0.1, 5)

--12. Calculating Interest
CREATE PROCEDURE usp_CalculateFutureValueForAccount
				 @accountId INT, @interestRate FLOAT
AS 
BEGIN 
	 SELECT TOP 1
		    ah.Id,
			ah.FirstName,
			ah.LastName,
			a.Balance,
			dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS BalanceForFiveYears		   
	   FROM AccountHolders AS ah
	   JOIN Accounts AS a ON ah.Id = a.AccountHolderId
	  WHERE a.AccountHolderId = @accountId
END

EXEC dbo.usp_CalculateFutureValueForAccount 1, 0.1

--13. *Cash in User Games Odd Rows
GO

CREATE FUNCTION ufn_CashInUsersGames (@gameName NVARCHAR(50))
RETURNS TABLE 
		   AS
	   RETURN
			(
			SELECT SUM(Cash) AS SumCash
			  FROM
			(
				SELECT 
					   g.Name,
					   ug.Cash,
					   ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS [Rows]
				
				  FROM UsersGames AS ug
				  JOIN Games AS g ON ug.GameId = g.Id
				 WHERE g.Name = @gameName
			) AS SubQuery
			WHERE [Rows] % 2 <> 0
			)

GO

SELECT * FROM dbo.ufn_CashInUsersGames ('Love in a mist')


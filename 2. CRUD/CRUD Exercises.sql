USE [SoftUni]

-- TASK 02.	Find All the Information About Departments
SELECT * FROM [Departments]

-- TASK 03. Find all Department Names

SELECT [NAME] FROM [Departments]

-- TASK 04. Find Salary of Each Employee
SELECT [FirstName], [LastName], [Salary] FROM Employees

-- TASK 05. Find Full Name of Each Employee

SELECT [FirstName], [MiddleName], [LastName] FROM Employees

-- TASK 06. Find Email Address of Each Employee

SELECT [FirstName] + '.' + [LastName] + '@' + 'softuni.bg' AS [Full Email Address] FROM [Employees]

--SELECT CONCAT([FirstName], '.', [LastName], '@', 'softuni.bg') AS [Full Email Address] FROM [Employees]

-- TASK 07. Find All Different Employee’s Salaries

SELECT DISTINCT [Salary] FROM [Employees]

-- TASK 08. Find all Information About Employees

SELECT * FROM [Employees] WHERE [JobTitle] = 'Sales Representative'

-- TASK 09. Find Names of All Employees by Salary in Range

SELECT [FirstName], [LastName], [JobTitle] FROM [Employees] WHERE [Salary] >= 20000 AND [Salary] <= 30000

-- TASK 10. Find Names of All Employees

SELECT CONCAT([FirstName], ' ', [MiddleName], ' ', [LastName]) AS [FullName]
FROM Employees
WHERE [Salary] IN (25000, 14000, 12500, 23600)

-- TASK 11. Find All Employees Without Manager

SELECT [FirstName], [LastName] FROM [Employees]
WHERE [ManagerID] IS NULL

-- TASK 12. Find All Employees with Salary More Than
SELECT [FirstName], [LastName], [Salary] 
FROM [Employees]
WHERE [Salary] >= 50000 
ORDER BY [Salary] DESC

--TASK 13. Find 5 Best Paid Employees
SELECT TOP 5 [FirstName], [LastName] FROM [Employees]
ORDER BY [Salary] DESC

--TASK 14. Find All Employees Except Marketing
SELECT [FirstName], [LastName] FROM [Employees]
WHERE [DepartmentID] <> 4

-- TASK 15. Sort Employees Table
SELECT * FROM [Employees]
ORDER BY [Salary] DESC, 
		 [FirstName] ASC, 
		 [LastName] DESC,
		 [MiddleName] ASC

-- TASK 16. Create View Employees with Salaries
CREATE VIEW V_EmployeesSalaries AS
SELECT FirstName, LastName, Salary
FROM Employees

-- TASK 17. Create View Employees with Job Titles
CREATE VIEW V_EmployeeNameJobTitle AS 
     SELECT CONCAT([FirstName], ' ', [MiddleName], ' ', [LastName]) 
         AS [Full Name], JobTitle 
       FROM Employees

-- TASK 18. Distinct Job Titles
SELECT DISTINCT JobTitle FROM Employees

-- TASK 19. Find First 10 Started Projects
SELECT TOP 10 * FROM [Projects]
ORDER BY [StartDate], [Name]

-- TASK 20. Last 7 Hired Employees
SELECT TOP 7 [FirstName], [LastName], [HireDate] FROM [Employees]
ORDER BY [HireDate] DESC

-- TASK 21. Increase Salaries

UPDATE Employees
SET Salary = Salary * 1.12
WHERE [DepartmentID] IN
(
SELECT [DepartmentID] FROM Departments
WHERE [Name] IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services') 
)

SELECT [Salary] FROM Employees

--TASK 22. All Mountain Peaks
USE Geography

SELECT [PeakName] FROM [Peaks]
ORDER BY [PeakName]

-- TASK 23. Biggest Countries by Population
SELECT TOP 30 [CountryName], [Population] FROM [Countries]
WHERE [ContinentCode] IN
(
SELECT [ContinentCode] FROM Continents
WHERE [ContinentName] = 'Europe'
)
ORDER BY [Population] DESC, [CountryName] ASC

-- TASK 24. Countries and Currency (Euro / Not Euro)
SELECT [CountryName],
	   [CountryCode],
	   CASE [CurrencyCode] 
	   WHEN 'EUR' THEN 'Euro'
	   ELSE 'Not Euro'
	   END
AS [Currency]
FROM [Countries]
ORDER BY CountryName

-- TASK 25. All Diablo Characters
USE Diablo

SELECT [Name] FROM [Characters]
ORDER BY [Name] ASC

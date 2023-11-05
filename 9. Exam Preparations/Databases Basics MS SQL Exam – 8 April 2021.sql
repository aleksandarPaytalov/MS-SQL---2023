CREATE DATABASE Service
GO
USE Service
GO

--PROBLEM 1
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(50) NOT NULL,
	[Name] VARCHAR(50),
	Birthdate DATETIME,
	Age INT CHECK(Age >= 14 AND Age <= 110),
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25),
	LastName VARCHAR(25),
	Birthdate DATETIME,
	Age INT Check(Age >= 18 AND Age <=110),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE Status
(
	Id INT PRIMARY KEY IDENTITY,
	[Label] VARCHAR(20) NOT NULL
)

CREATE TABLE Reports
(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	Description VARCHAR(200) NOT NULL,
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

--PROBLEM 02
INSERT INTO Employees (FirstName, LastName, Birthdate, DepartmentId)
VALUES 
	  ('Marlo',	'O''Malley', '1958-9-21', 1),
	  ('Niki',	'Stanaghan', '1969-11-26',	4),
	  ('Ayrton',	'Senna',	'1960-03-21',	9),
	  ('Ronnie',	'Peterson',	'1944-02-14',	9),
	  ('Giovanna',	'Amati',	'1959-07-20',	5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate,CloseDate,Description,UserId,EmployeeId)
VALUES
	  (1,	1,	'2017-04-13', NULL,'Stuck Road on Str.133',	6,	2),
	  (6,	3,	'2015-09-05',	'2015-12-06',	'Charity trail running',	3,	5),
	  (14,	2,	'2015-09-07', NULL,'Falling bricks on Str.58',	5,	2),
	  (4,	3,	'2017-07-03',	'2017-07-06',	'Cut off streetlight on Str.11',	1,	1)

--PROBLEM 3
UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL OR CloseDate = ''

--PROBLEM 4
DELETE FROM Reports
WHERE [StatusID] = 4

-- PROBLEM 5

SELECT 
	  Description,
	  FORMAT(OpenDate, 'dd-MM-yyyy')
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

-- PROBLEM 6
SELECT 
	  r.Description,
	  c.Name AS CategoryName
FROM Reports AS r
JOIN Categories AS c ON c.Id = r.CategoryId
WHERE r.CategoryId IS NOT NULL
ORDER BY Description, CategoryName

--PROBLEM 7
SELECT TOP (5)
	  c.Name AS CategoryName,
	  Count(*) AS ReportsNumber
FROM Reports AS r
JOIN Categories AS c ON c.Id = r.CategoryId
GROUP BY c.Name
ORDER BY ReportsNumber DESC, CategoryName

--PROBLEM 8
SELECT 
	 u.Username,
	 c.Name AS CategoryName
FROM Reports AS r
JOIN Users AS u ON u.Id = r.UserId
JOIN Categories AS c ON c.Id = r.CategoryId
WHERE MONTH(u.Birthdate) IN (MONTH(r.OpenDate)) AND 
	  DAY(u.Birthdate) IN (DAY(r.OpenDate))
ORDER BY u.Username, c.Name

--PROBLEM 9
SELECT 
	  CONCAT_WS(' ', FirstName, LastName) AS FullName,
	  COUNT(u.Id) AS UsersCount
FROM Employees AS e
LEFT JOIN Reports AS r ON r.EmployeeId = e.[Id]
LEFT JOIN Users AS u ON u.[Id] = r.UserId
GROUP BY e.FirstName, e.LastName
ORDER BY UsersCount DESC, FullName

--PROBLEM 10

SELECT 
	  ISNULL(CONCAT_WS(' ', ISNULL(e.FirstName, 'None'), e.LastName), 'None') AS Employee,
	  ISNULL(d.Name, 'None') AS Department,
	  c.Name AS Category,
	  r.Description,
	  FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate,
	  s.Label AS [Status],
	  u.Name AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e ON e.Id = r.EmployeeId
LEFT JOIN Departments AS d ON d.Id = e.DepartmentId
LEFT JOIN Categories AS c ON c.Id = r.CategoryId
LEFT JOIN [Status] AS s ON s.Id = r.StatusId
LEFT JOIN Users AS u ON u.Id = r.UserId
ORDER BY e.FirstName DESC, e.LastName DESC, Department, Category, [Description], OpenDate, [User]


--PROBLEM 11
GO

CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT 
AS 
BEGIN 
	 DECLARE @TotalHours INT 
	 
	 IF @StartDate IS NULL OR @EndDate IS NULL
	 BEGIN
		 SET @TotalHours = 0
	 END
	 ELSE 
	 BEGIN 
		SET @TotalHours = DATEDIFF(HOUR, @StartDate, @EndDate)
	 END

	 RETURN @TotalHours

END

GO
SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports

   --Второ решение
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS 
BEGIN
		IF @EndDate IS NULL
		RETURN 0
		ELSE IF @StartDate IS NULL
		RETURN 0
		
		RETURN DATEDIFF(HOUR,@StartDate,@EndDate)
END

--PROBLEM 12
GO
CREATE OR ALTER PROCEDURE usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN 
    DECLARE @ReportCategoryDepartmentId INT
    DECLARE @EmployeeDepartmentId INT

    SELECT @EmployeeDepartmentId = DepartmentId
    FROM Employees
    WHERE Id = @EmployeeId

    SELECT @ReportCategoryDepartmentId = c.DepartmentId
    FROM Reports AS r
    LEFT JOIN Categories AS c ON c.Id = r.CategoryId
    WHERE r.Id = @ReportId

    IF @EmployeeDepartmentId = @ReportCategoryDepartmentId
    BEGIN 
        UPDATE Reports
        SET EmployeeId = @EmployeeId  -- Corrected this line
        WHERE Id = @ReportId;          -- Added this line to specify which report to update
    END
    ELSE 
    BEGIN
        THROW 50000, 'Employee doesn''t belong to the appropriate department!', 1; 
    END
END

EXEC usp_AssignEmployeeToReport 30, 1
EXEC usp_AssignEmployeeToReport 17, 2
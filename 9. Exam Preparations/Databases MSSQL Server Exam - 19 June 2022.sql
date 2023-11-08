 CREATE DATABASE Zoo

 GO

 USE Zoo

 GO

 --Problem 1. DDL

 CREATE TABLE Owners
 (
    Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50) 
 )

 CREATE TABLE AnimalTypes
 (
    Id INT PRIMARY KEY IDENTITY,
	AnimalType VARCHAR(30) NOT NULL
 )

 CREATE TABLE Cages
 (
    Id INT PRIMARY KEY IDENTITY,
	AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL 
 )

 CREATE TABLE Animals
 (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	BirthDate DATE NOT NULL,
	OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
	AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
 )

 CREATE TABLE AnimalsCages
 (
	CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
	PRIMARY KEY (CageId, AnimalId)
 )

 CREATE TABLE VolunteersDepartments
 (
	Id INT PRIMARY KEY IDENTITY,
	DepartmentName VARCHAR(30) NOT NULL
 )

 CREATE TABLE Volunteers
 (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR (50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
	DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
 )

 --Problem 2. Insert
 INSERT INTO Volunteers ([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
 VALUES 
	   ('Anita Kostova', '0896365412','Sofia, 5 Rosa str.',	15,	1),
	   ('Dimitur Stoev', '0877564223', NULL,	42,	4),
	   ('Kalina Evtimova', '0896321112','Silistra, 21 Breza str.',	9,	7),
	   ('Stoyan Tomov', '0898564100','Montana, 1 Bor str.',	18,	8),
	   ('Boryana Mileva', '0888112233', NULL,	31,	5)
 
 INSERT INTO Animals([Name], BirthDate, OwnerId, AnimalTypeId)
 VALUES
	   ('Giraffe', '2018-09-21', 21, 1),
	   ('Harpy Eagle', '2015-04-17', 15, 3),
	   ('Hamadryas Baboon',	'2017-11-02', NULL,	1),
	   ('Tuatara', '2021-06-30', 2, 4)

--PROBLEM 3. UPDATE

UPDATE Animals
   SET OwnerId = 
			   (
			    SELECT Id 
				  FROM Owners
				 WHERE [Name] = 'Kaloqn Stoqnov'
			   )
 WHERE OwnerId IS NULL

 
--PROBLEM 4. DELETE

SELECT * FROM VolunteersDepartments

SELECT * FROM Volunteers

DELETE FROM Volunteers
WHERE DepartmentId = (
						SELECT Id
						  FROM VolunteersDepartments
						 WHERE DepartmentName = 'Education program assistant'
					 )

DELETE FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant'

--PROBLEM 5. Volunteers
  SELECT 
  		 [Name],
  		 PhoneNumber,
  		 [Address],
  		 AnimalId,
  		 DepartmentId
    FROM Volunteers
ORDER By [Name], AnimalId, DepartmentId

--PROBLEM 6. Animals data
SELECT 
	  a.Name,
	  at.AnimalType,
	  --convert(varchar, a.BirthDate, 4)
	  FORMAT(a.BirthDate, 'dd.MM.yyyy') AS BirthDate
  FROM Animals AS a
  JOIN AnimalTypes AS at ON a.AnimalTypeId = at.Id
ORDER BY a.Name

--Problem 07. Owners and Their Animals
SELECT TOP 5
		o.Name AS Owner,
		COUNT(*) AS CountOfAnimals
      FROM Animals AS a
JOIN Owners AS o ON a.OwnerId = o.Id
  GROUP BY o.Name
  ORDER BY CountOfAnimals DESC, o.Name

--Problem 08. Owners, Animals and Cages
SELECT 
	  CONCAT_WS('-', o.Name, a.Name),
	  o.PhoneNumber,
	  ac.CageId
  FROM Owners AS o
  
JOIN Animals AS a ON o.Id = a.OwnerId
JOIN AnimalsCages AS ac ON ac.AnimalId = a.Id
JOIN AnimalTypes AS at ON a.AnimalTypeId = at.Id
WHERE at.AnimalType = 'mammals'
ORDER BY o.Name, a.Name DESC

--Problem 09. Volunteers in Sofia
SELECT 
	  v.Name,
	  v.PhoneNumber,
	  LTRIM(REPLACE(REPLACE(v.Address, 'Sofia', ''), ',','')) AS [Address]
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd ON vd.Id = v.DepartmentId
WHERE vd.DepartmentName = 'Education program assistant' AND
	  v.Address LIKE '%Sofia%'
ORDER BY v.Name

--Problem 10. Animals for Adoption 
SELECT 
	  a.Name,
	  YEAR(a.BirthDate) AS BirthYear,
	  at.AnimalType
FROM Animals AS a
LEFT JOIN AnimalTypes AS at ON at.Id = a.AnimalTypeId
WHERE a.OwnerId IS NULL AND at.AnimalType <> 'Birds' AND a.BirthDate > '01/01/2018'
ORDER BY a.Name

--PROBLEM 11. All Volunteers in a Department
GO

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment varchar(30))
    RETURNS INT 
		     AS 
		  BEGIN 
				   DECLARE @volunteersCount INT
					SELECT @volunteersCount = COUNT(*)
					  FROM Volunteers AS v
					  JOIN VolunteersDepartments AS vt ON vt.Id = v.DepartmentId					  
					 WHERE vt.DepartmentName = @VolunteersDepartment
				  GROUP BY v.DepartmentId						  
					RETURN @volunteersCount
		    END

GO

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')

--Problem 12. Animals with Owner or Not
GO

CREATE PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName varchar(30))
   AS 
BEGIN
	 SELECT 
		   a.Name,
		   ISNULL(o.Name, 'For adoption') AS OwnersName

	   FROM Animals AS a
  LEFT JOIN Owners AS o ON o.Id = a.OwnerId
	  WHERE a.Name = @AnimalName
	 
  END

GO

EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'
EXEC usp_AnimalsWithOwnersOrNot 'Hippo'
EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'
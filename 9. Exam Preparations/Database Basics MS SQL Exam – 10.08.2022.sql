CREATE DATABASE NationalTouristSitesOfBulgaria

GO 

USE NationalTouristSitesOfBulgaria

GO

--Problem 1
CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
Municipality VARCHAR(50),
Province VARCHAR(50)
)

CREATE TABLE Sites
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(100) NOT NULL,
LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Establishment VARCHAR(15)
)

CREATE TABLE Tourists(
Id INT IDENTITY PRIMARY KEY,
Name VARCHAR(50) NOT NULL,
Age INT CHECK(Age >= 0 AND Age <= 120) NOT NULL,
PhoneNumber VARCHAR(20) NOT NULL,
Nationality VARCHAR(30) NOT NULL,
Reward VARCHAR(20)
)

CREATE TABLE SitesTourists
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL,
PRIMARY KEY (TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
Id INT PRIMARY KEY IDENTITY, 
Name VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL
PRIMARY KEY (TouristId, BonusPrizeId)
)

--Problem 2
INSERT INTO Tourists (Name, Age, PhoneNumber, Nationality, Reward)
VALUES
	('Borislava Kazakova', 52, '+359896354244', 'Bulgaria',	NULL),
	('Peter Bosh', 48, '+447911844141', 'UK',	NULL),
	('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
	('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
	('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites (Name, LocationId, CategoryId, Establishment)
VALUES
	('Ustra fortress',	90,	7,	'X'),
	('Karlanovo Pyramids',	65,	7,	NULL),
	('The Tomb of Tsar Sevt',	63,	8,	'V BC'),
	('Sinite Kamani Natural Park',	17,	1,	NULL),
	('St. Petka of Bulgaria – Rupite',	92,	6,	'1994')				
				

--Problem 3
UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL

--Problem 4
DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId = 5

DELETE FROM BonusPrizes
WHERE Name = 'Sleeping bag'

--Problem 5
SELECT 
	  Name,
	  Age,
	  PhoneNumber, 
	  Nationality
FROM Tourists
ORDER BY Nationality, Age DESC, Name

--Problem 6

SELECT 
		s.Name AS Site,
		l.Name AS Location, 
		s.Establishment,
		c.Name AS Category
FROM Sites AS s
JOIN Locations AS l ON l.Id = s.LocationId
JOIN Categories AS c ON c.Id = s.CategoryId
ORDER BY Category DESC, Location, Site

--Problem 7
SELECT
      l.Province,
	  l.Municipality,
	  l.Name,
	  Count(*) AS CountOfSites
FROM Locations AS l
JOIN Sites AS s ON s.LocationId = l.Id
WHERE Province = 'Sofia'
GROUP BY l.Province, l.Municipality, l.Name
ORDER BY CountOfSites DESC, l.Name

--Problem 8

SELECT 
	  s.Name,
	  l.Name,
	  l.Municipality,
	  l.Province,
	  s.Establishment
FROM Sites AS s
JOIN Locations AS l ON l.Id = s.LocationId 
WHERE LEFT(l.Name, 1) NOT IN ('B', 'M', 'D')
       AND s.Establishment LIKE '%BC%'
ORDER BY s.Name

--Problem 9
SELECT 
	  t.Name,
	  t.Age,
	  t.PhoneNumber,
	  t.Nationality
	  ,ISNULL(bp.Name, '(no bonus prize)') AS Reward
FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tb ON t.Id = tb.TouristId
LEFT JOIN BonusPrizes AS bp ON bp.Id = tb.BonusPrizeId
ORDER BY t.Name

--Problem 10
SELECT 
      SUBSTRING(t.Name, CHARINDEX(' ', t.Name) + 1, LEN(t.Name) - CHARINDEX(' ', t.Name)) AS LastName,
	  t.Nationality,
	  t.Age,
	  t.PhoneNumber
FROM Tourists AS t
JOIN SitesTourists AS st ON st.TouristId = t.Id
JOIN Sites AS s ON s.Id = st.SiteId
JOIN Categories AS c ON c.Id = s.CategoryId
WHERE c.Name = 'History and archaeology'
GROUP BY t.Name, t.Nationality, t.Age, t.PhoneNumber
ORDER BY LastName

--Problem 11
GO 

CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100)) 
RETURNS INT 
AS 
BEGIN
	 DECLARE @Visitors INT 
	  SELECT 
			@Visitors = COUNT(*) 
	    FROM Tourists AS t
	    JOIN SitesTourists AS st ON st.TouristId = t.Id
	    JOIN Sites AS s ON s.Id = st.SiteId
	   WHERE s.Name = @Site
	 RETURN @Visitors
END 

GO

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress')

--Problem 12
GO 

CREATE PROCEDURE usp_AnnualRewardLottery(@TouristName varchar(50))
AS 
BEGIN 
DECLARE @SitesVisited INT 
DECLARE @Reward VARCHAR(20)
 SELECT 
        @SitesVisited = COUNT(*)
   FROM Tourists AS t
   JOIN SitesTourists AS st ON st.TouristId = t.Id
   JOIN Sites AS s ON s.Id = st.SiteId
  WHERE t.Name = @TouristName
	   IF @SitesVisited >= 100
    BEGIN
          SET @Reward = 'Gold badge'
      END	
  ELSE IF @SitesVisited >=50 AND @SitesVisited < 100
    BEGIN
		  SET @Reward = 'Silver badge'
	  END
  ELSE IF @SitesVisited >=25 AND @SitesVisited < 50
   BEGIN
	  SET @Reward = 'Bronze badge'
     END
     ELSE 
   BEGIN
	  SET @Reward = NULL
     END
	SELECT @TouristName AS Name, @Reward AS Reward;
	
END

GO

EXEC usp_AnnualRewardLottery 'Gerhild Lutgard'
EXEC usp_AnnualRewardLottery 'Teodor Petrov'
EXEC usp_AnnualRewardLottery 'Zac Walsh'
EXEC usp_AnnualRewardLottery 'Brus Brown'
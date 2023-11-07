CREATE DATABASE CigarShop

Go 

USE CigarShop

GO

--Problem 01
CREATE TABLE Sizes
(
	Id INT PRIMARY KEY IDENTITY,
	Length INT CHECK(Length >= 10 AND Length <= 25) NOT NULL,
	RingRange DECIMAL(2,1) CHECK(RingRange >= 1.5 AND RingRange <= 7.5) NOT NULL
)

CREATE TABLE Tastes
(
	Id INT PRIMARY KEY IDENTITY,
	TasteType VARCHAR(20) NOT NULL,
	TasteStrength VARCHAR(15) NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands
(
	Id INT PRIMARY KEY IDENTITY, 
	BrandName VARCHAR(30) NOT NULL,
	BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars
(
	Id INT PRIMARY KEY IDENTITY,
	CigarName VARCHAR(80) NOT NULL,
	BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
	TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL,
	SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
	PriceForSingleCigar MONEY NOT NULL,
	ImageURL VARCHAR(100) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
	Town VARCHAR(30) NOT NULL,
	Country NVARCHAR(30) NOT NULL,
	Streat NVARCHAR(100) NOT NULL,
	ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE ClientsCigars
(
	ClientId INT FOREIGN KEY REFERENCES Clients(Id),
	CigarId INT FOREIGN KEY REFERENCES Cigars(Id),
	PRIMARY KEY (ClientId, CigarId)
)

--Problem 02
INSERT INTO Cigars(CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL)
VALUES
	  ('COHIBA ROBUSTO',	9,	1,	5,	15.50,	'cohiba-robusto-stick_18.jpg'),
	  ('COHIBA SIGLO I',	9,	1,	10,	410.00,	'cohiba-siglo-i-stick_12.jpg'),
	  ('HOYO DE MONTERREY LE HOYO DU MAIRE',	14,	5,	11,	7.50,	'hoyo-du-maire-stick_17.jpg'),
	  ('HOYO DE MONTERREY LE HOYO DE SAN JUAN',	14,	4,	15,	32.00,	'hoyo-de-san-juan-stick_20.jpg'),
	  ('TRINIDAD COLONIALES',	2,	3,	8,	85.21,	'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses(Town, Country, Streat, ZIP)
VALUES
	  ('Sofia',	'Bulgaria', '18 Bul. Vasil levski',	1000),
	  ('Athens',	'Greece',	'4342 McDonald Avenue',	10435),
	  ('Zagreb',	'Croatia',	'4333 Lauren Drive',	10000)

--Problem 3
UPDATE Cigars 
SET PriceForSingleCigar = PriceForSingleCigar * 1.20
FROM Cigars AS C
JOIN Tastes AS T ON C.TastID = T.Id
WHERE T.TasteType = 'Spicy'

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL OR BrandDescription = '';

--Problem 4


-- 7, 8, 10
DELETE FROM Clients
WHERE AddressId IN (7,8,10, 23)
-- 7,8,10, 23
DELETE FROM Addresses
WHERE LEFT(Country, 1) = 'C'

--Problem 5
  SELECT 
  	     CigarName,
  	     PriceForSingleCigar,
  	     ImageURL
    FROM Cigars
ORDER BY PriceForSingleCigar, CigarName DESC

--PROBLEM 6
SELECT 
  	   c.Id,
	   c.CigarName,
	   c.PriceForSingleCigar,
	   t.TasteType,
  	   t.TasteStrength
    FROM Cigars AS c
JOIN Tastes AS t ON t.Id = c.TastId
WHERE t.TasteType = 'Earthy' OR t.TasteType = 'Woody'
ORDER BY PriceForSingleCigar DESC

--PROBLEM 7
SELECT 
	  c.Id,
	  CONCAT_WS(' ', c.FirstName, c.LastName) AS ClientName,
	  Email
FROM Clients AS c 
LEFT JOIN ClientsCigars AS cc ON cc.ClientId = c.Id
LEFT JOIN Cigars AS ci ON ci.Id = cc.CigarId
WHERE ci.Id IS NULL
ORDER BY ClientName

--PRoblem 8
SELECT TOP (5)
			 c.CigarName,
			 c.PriceForSingleCigar,
			 c.ImageURL
FROM Cigars AS c
JOIN Sizes AS s ON s.Id = c.SizeId
  WHERE s.Length >= 12 AND 
(c.CigarName LIKE '%ci%' OR PriceForSingleCigar > 50) AND s.RingRange > 2.55
ORDER BY CigarName, PriceForSingleCigar DESC

--Problem 9
SELECT 
	  CONCAT_WS(' ', FirstName, LastName) AS FullName,
	  a.Country,
	  a.ZIP,
	  CONCAT('$', MAX(PriceForSingleCigar)) AS CigarPrice
FROM Clients AS c
JOIN Addresses AS a ON a.Id = c.AddressId
JOIN ClientsCigars AS cc ON cc.ClientId = c.Id
LEFT JOIN Cigars AS ci ON ci.Id = cc.CigarId
WHERE ISNUMERIC(ZIP) = 1
GROUP BY a.Country, a.ZIP, c.FirstName, c.LastName
ORDER BY FullName

--Problem 10

SELECT
	  c.LastName,
	  AVG(s.Length) AS CiagrLength,
	  CEILING(AVG(s.RingRange)) AS CigarRingRange
FROM Clients AS c 
JOIN  ClientsCigars AS cc ON cc.ClientId = c.Id
JOIN Cigars AS ci ON ci.Id = cc.CigarId
JOIN Sizes AS s ON s.Id = ci.SizeId
GROUP BY c.LastName
ORDER BY CiagrLength DESC

--PRoblem 11
GO
CREATE FUNCTION udf_ClientWithCigars(@name nvarchar(30)) 
RETURNS INT 
AS 
BEGIN 
	DECLARE @NumberOfCigars INT
	 SELECT @NumberOfCigars = COUNT(*) 
	  FROM Clients AS c
	  JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
	  WHERE c.FirstName = @name
	RETURN @NumberOfCigars
END 

GO
SELECT dbo.udf_ClientWithCigars('Riley')



--PROBLEM 12
GO

CREATE PROCEDURE usp_SearchByTaste(@taste varchar(20))
AS 
BEGIN 
	 SELECT 
		   CigarName, 
		   CONCAT('$', PriceForSingleCigar),
		   TasteType,
		   BrandName, 
		   CONCAT_WS(' ',[Length], 'cm') AS CigarLength,
		   CONCAT_WS(' ', RingRange, 'cm') AS CigarRingRange
	 FROM Tastes AS t
	 JOIN Cigars AS ci ON ci.TastId = t.Id
	 JOIN Brands AS b ON b.Id = ci.BrandId
	 JOIN Sizes AS s ON s.Id = ci.SizeId
	 WHERE t.TasteType = @taste
	 ORDER BY s.[Length], s.RingRange DESC
END

GO
CREATE DATABASE Airport

GO 

USE Airport

GO
--PROBLEM 1

CREATE TABLE Passengers
(
	Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Pilots
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age TINYINT CHECK(Age >= 21 AND Age <= 62) NOT NULL,
	Rating FLOAT CHECK(Rating >= 0.0 AND Rating <= 10.0)
)

CREATE TABLE AircraftTypes
(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) NOT NULL
)

CREATE TABLE Aircraft
(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR(1) NOT NULL,
	TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft
(
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
	PRIMARY KEY (AircraftId, PilotId)
)

CREATE TABLE Airports
(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) NOT NULL,
	Country VARCHAR(100) NOT NULL
)

CREATE TABLE FlightDestinations
(
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
	[Start] DATETIME NOT NULL,
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
)

--Problem 02
INSERT INTO Passengers (FullName, Email)
SELECT *
FROM
	(
	SELECT 
		  CONCAT_WS(' ', p.FirstName, p.LastName) AS FullName,
		  CONCAT(FirstName,  LastName, '@gmail.com') AS Email
	  FROM Pilots AS p
	 WHERE p.Id BETWEEN 5 AND 15
	) AS PilotsSubQuesry

--Problem 03

UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('c','b') AND (FlightHours IS NULL OR FlightHours <= 100) AND [Year] >= 2013

--Problem 4
SELECT * 
FROM Passengers

DELETE FROM Passengers
WHERE LEN(FullName) <= 10

--Problem 5
SELECT 
	  Manufacturer,
	  Model,
	  FlightHours,
	  Condition
  FROM Aircraft
  ORDER BY FlightHours DESC

--PRoblem 6

   SELECT 
   	      p.FirstName,
   	      p.LastName,
   	      a.Manufacturer,
   	      a.Model,
   	      a.FlightHours
     FROM Pilots AS p
     JOIN PilotsAircraft AS pa ON pa.PilotId = p.Id
     JOIN Aircraft AS a ON a.Id = pa.AircraftId
    WHERE a.FlightHours IS NOT NULL AND a.FlightHours < 304
 ORDER BY a.FlightHours DESC, p.FirstName

--Problem 7
SELECT TOP 20
	  fd.Id AS DestinationId,
	  fd.Start,
	  p.FullName,
	  a.AirportName,
	  fd.TicketPrice
FROM FlightDestinations AS fd
JOIN Passengers AS p ON p.Id = fd.PassengerId
JOIN Airports AS a ON a.Id = fd.AirportId
WHERE DAY(fd.Start) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName

--Problem 8
SELECT * 
  FROM
  (
    SELECT 
    	   a.Id AS AircraftId,
    	   a.Manufacturer,
    	   a.FlightHours,
    	   COUNT(fd.AirportID) AS FlightDestinationsCount,
    	   ROUND(AVG(TicketPrice), 2) AS AvgPrice	  
      FROM Aircraft AS a
      JOIN FlightDestinations AS fd ON fd.AircraftId = a.Id
  GROUP BY a.Id, a.Manufacturer, a.FlightHours
   ) AS subQuery
     WHERE FlightDestinationsCount >= 2
  ORDER By FlightDestinationsCount DESC, AircraftId

  --Problem 9
  SELECT *
    FROM (
  
  	  SELECT 
  	    	  p.FullName,
  	    	  COUNT(fd.AirCraftId) AS CountOfAircraft, 
  	    	  SUM(TicketPrice) AS TotalPayed
  	    FROM Passengers AS p
  	    LEFT JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
  	    LEFT JOIN Aircraft AS a ON a.Id = fd.AircraftId
  	GROUP BY FullName
  	 )    AS SubQuery
    WHERE CountOfAircraft > 1 AND SUBSTRING(FullName, 2, 1) = 'a'
 ORDER BY FullName

 --Problem 10
   SELECT  
   	      a.AirportName,
   	      fd.Start AS DAyTime,
   	      fd.TicketPrice,
   	      p.FullName,
   	      ac.Manufacturer,
   	      ac.Model
     FROM FlightDestinations AS fd
     JOIN Airports AS a ON a.Id = fd.AirportId
     JOIN Passengers AS p ON p.Id = fd.PassengerId
     JOIN Aircraft AS ac ON ac.Id = fd.AircraftId
    WHERE DATEPART(HOUR, [Start]) BETWEEN 6 AND 20 AND TicketPrice > 2500
 ORDER BY ac.Model

 --Problem 11
 GO

 CREATE FUNCTION udf_FlightDestinationsByEmail(@email varchar(50)) 
 RETURNS INT 
 AS 
 BEGIN 
		DECLARE @DestinationFlights INT 
		 SELECT @DestinationFlights = COUNT(*)
		   FROM Passengers AS p
		   JOIN FlightDestinations AS fd ON fd.PassengerId = p .Id
		  WHERE p.Email = @email

		RETURN @DestinationFlights
 END

 GO

 SELECT dbo.udf_FlightDestinationsByEmail ('PierretteDunmuir@gmail.com')
 SELECT dbo.udf_FlightDestinationsByEmail('Montacute@gmail.com')
 SELECT dbo.udf_FlightDestinationsByEmail('MerisShale@gmail.com')

 --Problem 12
 GO 

 CREATE PROCEDURE usp_SearchByAirportName (@airportName VARCHAR(MAX))
 AS 
 BEGIN 
		SELECT 
			  a.AirportName,
			  p.FullName,
			  CASE 
				 WHEN fd.TicketPrice <= 400 THEN 'Low'
				 WHEN fd.TicketPrice >= 401 AND fd.TicketPrice <= 1500 THEN 'Medium'
				 WHEN fd.TicketPrice >= 1501 THEN 'High'
			   END AS LevelOfTickerPrice,
			  ac.Manufacturer,
			  ac.Condition,
			  att.TypeName			  
		FROM Airports AS a
		JOIN FlightDestinations AS fd ON fd.AirportId = a.Id
		JOIN Passengers AS p ON p.Id = fd.PassengerId
		JOIN Aircraft AS ac ON ac.Id = fd.AircraftId
		JOIN AircraftTypes AS att ON att.Id = ac.TypeId
		WHERE a.AirportName = @airportName
		ORDER BY ac.Manufacturer, p.FullName
 END

 GO

 EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'
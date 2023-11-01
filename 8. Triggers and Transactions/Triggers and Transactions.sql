--01. Create Table Logs
CREATE TABLE Logs (
  LogId INT PRIMARY KEY IDENTITY,
  AccountId INT,
  OldSum MONEY,
  NewSum MONEY
)

CREATE TRIGGER InsertNewEntryIntoLogs
  ON Accounts
  AFTER UPDATE
AS
  INSERT INTO Logs
  VALUES (
    (SELECT Id
     FROM inserted),
    (SELECT Balance
     FROM deleted),
    (SELECT Balance
     FROM inserted)
  )

--02. Create Table Emails
CREATE TABLE NotificationEmails (
  Id INT PRIMARY KEY IDENTITY,
  Recipient INT,
  Subject NVARCHAR(MAX),
  Body NVARCHAR(MAX)
)

CREATE TRIGGER CreateNewEmail
  ON Logs
  AFTER INSERT
AS
  BEGIN
    INSERT INTO NotificationEmails
    VALUES (
      (SELECT AccountId
       FROM inserted),
      (CONCAT('Balance change for account: ', (SELECT AccountId
                                               FROM inserted))),
      (CONCAT('On ', (SELECT GETDATE()
                      FROM inserted), 'your balance was changed from ', (SELECT OldSum
                                                                         FROM inserted), 'to ', (SELECT NewSum
                                                                                                 FROM inserted), '.'))
    )
  END

--03. Deposit Money

CREATE PROCEDURE usp_DepositMoney(@AccountId INT, @MoneyAmount MONEY)
AS
  BEGIN TRANSACTION
  UPDATE Accounts
  SET Balance += @MoneyAmount
  WHERE Id = @AccountId
  COMMIT

--04. Withdraw Money Procedure
CREATE PROCEDURE usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL (18,4))
AS
  BEGIN TRANSACTION
  UPDATE Accounts
  SET Balance -= @MoneyAmount
  WHERE Id = @AccountId
  COMMIT

--05. Money Transfer
CREATE PROCEDURE usp_TransferMoney
(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(18,4)) 
AS 
BEGIN
	BEGIN TRANSACTION 
	EXECUTE dbo.usp_WithdrawMoney @SenderId, @Amount
	EXECUTE dbo.usp_DepositMoney @ReceiverId, @Amount

	IF ((SELECT Balance
         FROM Accounts
         WHERE Accounts.Id = @SenderId) < 0)
      BEGIN
        ROLLBACK
      END
    ELSE
      BEGIN
        COMMIT
      END
END

EXEC usp_TransferMoney 1, 2, 10
SELECT * FROM Accounts WHERE Id = 1
SELECT * FROM Accounts WHERE Id = 2

--07. *Massive Shopping
DECLARE @gameName NVARCHAR(50) = 'Safflower'
DECLARE @username NVARCHAR(50) = 'Stamat'

DECLARE @userGameId INT = (
  SELECT ug.Id
  FROM UsersGames AS ug
    JOIN Users AS u
      ON ug.UserId = u.Id
    JOIN Games AS g
      ON ug.GameId = g.Id
  WHERE u.Username = @username AND g.Name = @gameName)

DECLARE @userGameLevel INT = (SELECT Level
                              FROM UsersGames
                              WHERE Id = @userGameId)
DECLARE @itemsCost MONEY, @availableCash MONEY, @minLevel INT, @maxLevel INT

SET @minLevel = 11
SET @maxLevel = 12
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId
    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK;
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SET @minLevel = 19
SET @maxLevel = 21
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId

    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SELECT i.Name AS [Item Name]
FROM UserGameItems AS ugi
  JOIN Items AS i
    ON i.Id = ugi.ItemId
  JOIN UsersGames AS ug
    ON ug.Id = ugi.UserGameId
  JOIN Games AS g
    ON g.Id = ug.GameId
WHERE g.Name = @gameName
ORDER BY [Item Name]

--08. Employees with Three Projects
CREATE PROCEDURE usp_AssignProject(@employeeId INT, @projectID INT)
AS
  BEGIN
    BEGIN TRANSACTION
    INSERT INTO EmployeesProjects
    VALUES (@employeeId, @projectID)
    IF (SELECT COUNT(ProjectID)
        FROM EmployeesProjects
        WHERE EmployeeID = @employeeId) > 3
      BEGIN
        RAISERROR ('The employee has too many projects!', 16, 1)
        ROLLBACK
        RETURN
      END
    COMMIT
  END

  --09. Delete Employees
  CREATE TABLE Deleted_Employees
(
  EmployeeId INT PRIMARY KEY IDENTITY,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  MiddleName VARCHAR(50),
  JobTitle VARCHAR(50),
  DepartmentId INT,
  Salary DECIMAL(15, 2)
)

GO

CREATE TRIGGER tr_DeleteEmployees
  ON Employees
  AFTER DELETE
AS
  BEGIN
    INSERT INTO Deleted_Employees
      SELECT
        FirstName,
        LastName,
        MiddleName,
        JobTitle,
        DepartmentID,
        Salary
      FROM deleted
  END

--https://judge.softuni.org/Contests/Practice/Index/804#13
--01. Number of Users for Email Provider
SELECT
  substring(Email, charindex('@', Email) + 1, len(Email) - charindex('@', Email) + 1) AS [Email Provider],
  count(*)                                                                            AS [Number Of Users]
FROM Users
GROUP BY substring(Email, charindex('@', Email) + 1, len(Email) - charindex('@', Email) + 1)
ORDER BY [Number Of Users] DESC, [Email Provider] ASC

--02. All Users in Games
SELECT
  g.Name     AS [Game],
  gt.Name    AS [Game Type],
  u.Username AS [Username],
  ug.Level   AS [Level],
  ug.Cash    AS [Cash],
  c.Name     AS [Character]
FROM Games AS g
  INNER JOIN GameTypes AS gt
    ON g.GameTypeId = gt.Id
  INNER JOIN UsersGames AS ug
    ON g.Id = ug.GameId
  INNER JOIN Users AS u
    ON ug.UserId = u.Id
  INNER JOIN Characters AS c
    ON ug.CharacterId = c.Id
ORDER BY ug.Level DESC, u.Username ASC, g.Name ASC
--03. Users in Games with Their Items
SELECT
  u.Username   AS Username,
  g.Name       AS Game,
  COUNT(i.Id)  AS ItemsCount,
  SUM(i.Price) AS Cash
FROM Games AS g
  INNER JOIN UsersGames AS ug
    ON ug.GameId = g.Id
  INNER JOIN Users AS u
    ON u.Id = ug.UserId
  INNER JOIN UserGameItems AS ugt
    ON ugt.UserGameId = ug.Id
  INNER JOIN Items AS i
    ON i.Id = ugt.ItemId
GROUP BY u.Username, g.Name
HAVING COUNT(i.Id) >= 10
ORDER BY ItemsCount DESC, Cash DESC, u.Username
--04. *User in Games with Their Statistics
SELECT
  u.Username,
  g.Name                                                 AS Game,
  Max(c.Name)                                            AS Character,
  MAX(s1.Strength) + MAX(s2.Strength) + SUM(s3.Strength) AS Strength,
  MAX(s1.Defence) + MAX(s2.Defence) + SUM(s3.Defence)    AS Defence,
  MAX(s1.Speed) + MAX(s2.Speed) + SUM(s3.Speed)          AS Speed,
  MAX(s1.Mind) + MAX(s2.Mind) + SUM(s3.Mind)             AS Mind,
  MAX(s1.Luck) + MAX(s2.Luck) + SUM(s3.Luck)             AS Luck
FROM UsersGames AS ug
  INNER JOIN Users AS u
    ON ug.UserId = u.Id
  INNER JOIN Games AS g
    ON ug.GameId = g.Id
  INNER JOIN Characters AS c
    ON ug.CharacterId = c.Id
  INNER JOIN [Statistics] AS s1
    ON c.StatisticId = s1.Id
  INNER JOIN GameTypes AS gt
    ON g.GameTypeId = gt.Id
  INNER JOIN [Statistics] s2
    ON gt.BonusStatsId = s2.Id
  INNER JOIN UserGameItems AS ugi
    ON ug.Id = ugi.UserGameId
  INNER JOIN Items AS i
    ON ugi.ItemId = i.Id
  INNER JOIN [Statistics] AS s3
    ON i.StatisticId = s3.Id
GROUP BY u.Username, g.Name
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC
--05. All Items with Greater than Average Statistics
SELECT
  i.Name,
  i.Price,
  i.MinLevel,
  s.Strength,
  s.Defence,
  s.Speed,
  s.Luck,
  s.Mind
FROM (
       SELECT Id
       FROM [Statistics]
       WHERE Mind > (SELECT avg(Mind * 1.0)
                     FROM [Statistics]) AND
             Luck > (SELECT avg(Luck * 1.0)
                     FROM [Statistics]) AND
             Speed > (SELECT avg(Speed * 1.0)
                      FROM [Statistics])
     ) AS av
  INNER JOIN [Statistics] AS s
    ON av.Id = s.Id
  INNER JOIN Items AS i
    ON i.StatisticId = s.Id
ORDER BY Name
--06. Display All Items about Forbidden Game Type
SELECT
  i.Name  AS [Item Name],
  i.Price,
  i.MinLevel,
  gt.Name AS [Forbidden Game Type]
FROM Items AS i
  LEFT JOIN GameTypeForbiddenItems AS gtfi
    ON gtfi.ItemId = i.Id
  LEFT JOIN GameTypes AS gt
    ON gt.Id = gtfi.GameTypeId
ORDER BY [Forbidden Game Type] DESC, [Item Name]
--07. Buy Items for User in Game
DECLARE @gameName NVARCHAR(50) = 'Edinburgh'
DECLARE @username NVARCHAR(50) = 'Alex'

DECLARE @userGameId INT = (
  SELECT ug.Id
  FROM UsersGames AS ug
    JOIN Users AS u
      ON ug.UserId = u.Id
    JOIN Games AS g
      ON ug.GameId = g.Id
  WHERE u.Username = @username AND g.Name = @gameName
)

DECLARE @availableCash MONEY = (
  SELECT Cash
  FROM UsersGames
  WHERE Id = @userGameId
)

DECLARE @purchasePrice MONEY = (
  SELECT sum(Price)
  FROM Items
  WHERE Name IN (
    'Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)',
    'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'
  )
)

IF (@availableCash >= @purchasePrice)
  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @purchasePrice
    WHERE Id = @userGameId

    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make playment', 16, 1)
        RETURN
      END

    INSERT INTO UserGameItems (ItemId, UserGameId)
      (SELECT
         Id,
         @userGameId
       FROM Items
       WHERE Name IN
             ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)',
              'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))

    IF ((SELECT count(*)
         FROM Items
         WHERE Name IN (
           'Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)',
           'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'
         )) <> @@ROWCOUNT)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not buy items', 16, 1)
        RETURN
      END
    COMMIT
  END

SELECT
  u.Username,
  g.Name,
  ug.Cash,
  i.Name AS [Item Name]
FROM UsersGames AS ug
  JOIN Games AS g
    ON ug.GameId = g.Id
  JOIN Users AS u
    ON ug.UserId = u.Id
  JOIN UserGameItems AS item
    ON ug.Id = item.UserGameId
  JOIN Items AS i
    ON item.ItemId = i.Id
WHERE g.Name = @gameName
--08. Peaks and Mountains
SELECT
  p.PeakName      AS [PeakName],
  m.MountainRange AS [Mountain],
  p.Elevation     AS [Elevation]
FROM Peaks AS p
  JOIN Mountains AS m
    ON p.MountainId = m.Id
ORDER BY Elevation DESC, PeakName ASC
--09. Peaks with Mountain, Country and Continent
SELECT
  p.PeakName,
  m.MountainRange,
  c.CountryName,
  c2.ContinentName
FROM Peaks AS p
  JOIN Mountains AS m
    ON p.MountainId = m.Id
  JOIN MountainsCountries mc
    ON m.Id = mc.MountainId
  JOIN Countries c
    ON mc.CountryCode = c.CountryCode
  JOIN Continents c2
    ON c.ContinentCode = c2.ContinentCode
ORDER BY p.PeakName ASC, c.CountryName AS
--10. Rivers by Country
SELECT
  c.CountryName,
  c2.ContinentName,
  count(r.Id)              AS [RiverCount],
  isnull(SUM(r.Length), 0) AS [TotalLength]
FROM Countries AS c
  LEFT JOIN CountriesRivers AS cr
    ON c.CountryCode = cr.CountryCode
  LEFT JOIN Rivers r
    ON cr.RiverId = r.Id
  INNER JOIN Continents AS c2
    ON c.ContinentCode = c2.ContinentCode
GROUP BY c.CountryName, c2.ContinentName
ORDER BY RiverCount DESC, TotalLength DESC, CountryName ASC
--11. Count of Countries by Currency
SELECT
  c.CurrencyCode        AS [CurrencyCode],
  c.Description         AS [Currency],
  count(c2.CountryName) AS [NumberOfCountries]
FROM Currencies AS c
  LEFT JOIN Countries c2
    ON c.CurrencyCode = c2.CurrencyCode
GROUP BY c.CurrencyCode, c.Description
ORDER BY NumberOfCountries DESC, Currency AS
--12. Population and Area by Continent
SELECT
  c.ContinentName  AS [ContinentName],
  sum(c2.AreaInSqKm) AS [CountriesArea],
  sum(cast(c2.Population AS FLOAT) ) AS [CountriesPopulation]
FROM Continents AS c
  JOIN Countries AS c2
    ON c2.ContinentCode = c.ContinentCode
GROUP BY c.ContinentName
ORDER BY CountriesPopulation DESC
--13. Monasteries by Country
CREATE TABLE Monasteries (
  Id INT PRIMARY KEY IDENTITY,
  Name NVARCHAR(MAX) NOT NULL,
  CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries (CountryCode)
)

INSERT INTO Monasteries (Name, CountryCode) VALUES
  ('Rila Monastery “St. Ivan of Rila”', 'BG'),
  ('Bachkovo Monastery “Virgin Mary”', 'BG'),
  ('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
  ('Kopan Monastery', 'NP'),
  ('Thrangu Tashi Yangtse Monastery', 'NP'),
  ('Shechen Tennyi Dargyeling Monastery', 'NP'),
  ('Benchen Monastery', 'NP'),
  ('Southern Shaolin Monastery', 'CN'),
  ('Dabei Monastery', 'CN'),
  ('Wa Sau Toi', 'CN'),
  ('Lhunshigyia Monastery', 'CN'),
  ('Rakya Monastery', 'CN'),
  ('Monasteries of Meteora', 'GR'),
  ('The Holy Monastery of Stavronikita', 'GR'),
  ('Taung Kalat Monastery', 'MM'),
  ('Pa-Auk Forest Monastery', 'MM'),
  ('Taktsang Palphug Monastery', 'BT'),
  ('Sümela Monastery', 'TR')


ALTER TABLE Countries
  ADD IsDeleted BIT NOT NULL DEFAULT 0


UPDATE Countries
SET [IsDeleted] = 1
WHERE CountryCode IN (
  SELECT a.Code
  FROM (
         SELECT
           c.CountryCode     AS [Code],
           count(cr.RiverId) AS [CountryRiver]
         FROM Countries AS c
           JOIN CountriesRivers cr
             ON c.CountryCode = cr.CountryCode
         GROUP BY c.CountryCode
       ) AS a
  WHERE a.CountryRiver > 3
)

SELECT
  m.Name        AS [Monastery],
  c.CountryName AS [Country]
FROM Monasteries AS m
  JOIN Countries c
    ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted <> 1
ORDER BY Monastery ASC
--14. Monasteries by Continents and Countries
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'


INSERT INTO Monasteries (Name, CountryCode)
  (SELECT
     'Hanga Abbey',
     CountryCode
   FROM Countries
   WHERE CountryName = 'Tanzania')

INSERT INTO Monasteries (Name, CountryCode)
  (SELECT
     'Myin-Tin-Daik',
     CountryCode
   FROM Countries
   WHERE CountryName = 'Myanmar')


SELECT
  con.ContinentName AS [ContinentName],
  c.CountryName     AS [CountryName],
  count(m.Id)       AS [MonasteriesCount]
FROM Continents AS con
  JOIN Countries AS c
    ON c.ContinentCode = con.ContinentCode
  LEFT JOIN Monasteries AS m
    ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 0
GROUP BY c.CountryName, con.ContinentName
ORDER BY MonasteriesCount DESC, CountryName ASC
CREATE DATABASE Bitbucket
GO
USE Bitbucket
GO

--PROBLEM 1
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL, 
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
	PRIMARY KEY (RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus CHAR(6) NOT NULL,
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	Size DECIMAL(18,2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files(Id),
	CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
)

--PROBLEM 02
INSERT INTO Files([Name], Size, ParentId, CommitId)
VALUES
	  ('Trade.idk',	2598.0,	1,	1),
	  ('menu.net',	9238.31,	2,	2),
	  ('Administrate.soshy',	1246.93,	3,	3),
	  ('Controller.php',	7353.15,	4,	4),
	  ('Find.java',	9957.86,	5,	5),
	  ('Controller.json',	14034.87,	3,	6),
	  ('Operate.xix',	7662.92,	7,	7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES 
	  ('Critical Problem with HomeController.cs file',	'open',	1,	4),
	  ('Typo fix in Judge.html',	'open',	4,	3),
	  ('Implement documentation for UsersService.cs',	'closed',	8,	2),
	  ('Unreachable code in Index.cs',	'open',	9,	8)

--PROBLEM 3
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

--PROBLEM 4
DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3

DELETE FROM FILES 
WHERE CommitId = 36

DELETE FROM Commits
WHERE RepositoryId = 3

DELETE FROM Repositories
WHERE [Name] = 'Softuni-Teamwork'

--PROBLEM 5
SELECT 
	  Id,
	  [Message],
	  RepositoryId,
	  ContributorId
FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

-- PROBLEM 6
SELECT	
	  Id,
	  [Name],
	  Size
FROM Files
WHERE Size > 1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id, [Name]

--PROBLEM 7
SELECT 
	i.Id,
	CONCAT_WS(' : ', u.Username, i.Title)
FROM Issues AS i
JOIN Users AS u ON u.Id = i.AssigneeId
ORDER BY i.Id DESC, u.Username

--PROBLEM 8
SELECT 
	  f.Id,
	  f.Name,
	  CONCAT(f.Size, 'KB')
FROM Files AS f
LEFT JOIN Files AS fil ON fil.ParentId = f.Id
WHERE fil.Id IS NULL
ORDER BY f.Id, f.Name, f.Size DESC

--PROBLEM 9
SELECT TOP 5
	  r.Id,
	  r.Name,
	  COUNT(*) AS Commits
FROM Repositories AS r
LEFT JOIN Commits AS c ON c.RepositoryId = r.Id
LEFT JOIN RepositoriesContributors AS rc ON rc.RepositoryId = r.Id
GROUP BY r.Id, r.Name
ORDER BY Commits DESC, r.Id, r.Name

-- PROBLEM 10
SELECT 
	  u.Username,
	  AVG(f.Size) AS Size
FROM Users AS u
JOIN Commits AS c ON c.ContributorId = u.Id
JOIN Files AS f ON f.CommitId = c.Id
GROUP BY u.Username
ORDER BY Size DESC, u.Username

--PROBLEM 11
GO
CREATE FUNCTION udf_AllUserCommits(@username varchar(30)) 
RETURNS INT 
AS 
BEGIN 
		DECLARE @CountOfComits INT
		SELECT 
			  @CountOfComits = COUNT(*)
		FROM Users AS u
		JOIN Commits AS c ON c.ContributorId = u.Id
		WHERE u.Username = @username

		RETURN @CountOfComits
END 
GO
SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--PROBLEM 12
GO
CREATE PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(10))
AS 
BEGIN	
		SELECT 
			  Id,
			  [Name],
			  CONCAT(Size, 'KB') AS Size
		FROM Files
		WHERE [Name] LIKE '%' + @fileExtension + '%'
		ORDER BY Id, [Name], Size

END
GO

EXEC usp_SearchForFiles 'txt'
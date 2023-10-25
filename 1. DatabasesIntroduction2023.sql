--Problem 01
CREATE DATABASE [Minisons2023]

USE [Minisons2023]

--Problem 02
CREATE  TABLE [Minions](
[Id] INT PRIMARY KEY,
[Name] NVARCHAR(50) NOT NULL,
[Age] INT NOT NULL
)

ALTER TABLE [Minions]
ALTER COLUMN [Age] INT

CREATE  TABLE [Towns](
[Id] INT PRIMARY KEY,
[Name] NVARCHAR(50) NOT NULL
)

--Problem 03
ALTER TABLE [Minions]
ADD [TownId] INT FOREIGN KEY REFERENCES [Towns]([Id]) NOT NULL

--Problem 04

INSERT INTO [Towns] ([Id], [Name]) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO [Minions] ([Id], [Name], [Age], [TownId]) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

--Problem 05
TRUNCATE TABLE [Minions]

--Problem 06
--DROP TABLE [People]

--Problem 07
CREATE TABLE [People](
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(200) NOT NULL,
[Picture] VARBINARY(MAX),
CHECK (DATALENGTH ([Picture]) <= 2000000),
[Height] DECIMAL (3,2),
[Weight] DECIMAL(5,2),
[Gender] CHAR(1),
CHECK ([Gender] = 'm' OR [Gender] = 'f'),
[Birthdate] DATE,
[Biography] NVARCHAR(MAX)
)

INSERT INTO [People]([NAME], [Height], [Weight], [Gender], [Birthdate]) VALUES
('Petar', 1.83, 83.4, 'm', '1998-03-25'),
('Stosho', 1.73, 80.4, 'm', '1995-03-20'),
('Vanq', 1.68, 63.4, 'f', '1991-04-07'),
('Viki', 1.73, 60.4, 'f', '1995-03-21'),
('Ivan', 1.93, 89.4, 'm', '1996-05-21')

--Problem 08

CREATE TABLE [Users](
[Id] BIGINT PRIMARY KEY IDENTITY,
[Username] VARCHAR(30) NOT NULL,
[Password] VARCHAR(26),
[ProfilePicture] VARBINARY(MAX)
CHECK (DATALENGTH ([ProfilePicture]) <= 900000),
[LastLoginTime] TIME,
[IsDeleted] VARCHAR(5)
CHECK ([IsDeleted] = 'true' OR [IsDeleted] = 'false')
)

INSERT INTO [Users] ([Username], [Password], [IsDeleted], [LastLoginTime])
VALUES
('Petar', 'Stosho', 'false', '01:12:15'),
('Ivan', 'Delta', 'true', '11:10:10'),
('Sasho', 'Bravo', 'false', '11:15:10'),
('Gosho', 'Tango', 'false', '13:14:15'),
('Vanq', 'Oposum', 'true', '14:10:11')
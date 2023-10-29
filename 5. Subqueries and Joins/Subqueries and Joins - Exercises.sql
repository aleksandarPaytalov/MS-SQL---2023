--01. Employee Address
SELECT TOP 5
	   e.EmployeeId
	  ,e.JobTitle
	  ,e.AddressID
	  ,a.AddressText
FROM Employees AS e
JOIN Addresses AS a
ON e.AddressID = a.AddressID
ORDER BY AddressID

--02. Addresses with Towns 
SELECT TOP 50
		e.FirstName
	   ,e.LastName
	   ,t.[Name] AS Town
	   ,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON a.AddressID = e.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

--03. Sales Employees
SELECT 
	 e.EmployeeID
	,e.FirstName
	,e.LastName
	,d.[Name] AS DepartmentName 
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID

--04. Employee Departments
SELECT TOP 5
		   e.EmployeeID
		  ,e.FirstName
		  ,e.Salary
		  ,d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID

--05. Employees Without Projects
SELECT TOP 3
		   e.EmployeeID
		  ,e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY EmployeeID

--06. Employees Hired After
SELECT 
	 e.FirstName
	,e.LastName
	,e.HireDate
	,d.[Name] AS DeptName
FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE e.HireDate > '1999-01-01' AND d.[Name] IN ('Sales','Finance')
ORDER BY e.HireDate

--07. Employees With Project
SELECT TOP 5
		   e.EmployeeID
		  ,e.FirstName
		  ,p.[Name] AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > 2002-08-13 AND p.EndDate IS NULL
ORDER BY EmployeeID

--08. Employee 24
SELECT
	 e.EmployeeID
	,e.FirstName
	,CASE
     WHEN p.StartDate >= '2005-01-01' THEN NULL
	 ELSE p.[Name]
END AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

--09. Employee Manager
SELECT
	 e.EmployeeID
	,e.FirstName
	,e.ManagerID
	,m.FirstName AS ManagerName
FROM Employees AS e
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID


--10. Employees Summary
SELECT TOP 50 
		    e.EmployeeID
		   ,CONCAT_WS(' ', e.FirstName, e.LastName) AS EmployeeName
		   ,CONCAT_WS(' ', m.FirstName, m.LastName) AS ManagerName
		   ,d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Employees AS m ON m.EmployeeID = e.ManagerID
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID

--11. Min Average Salary
SELECT TOP 1 
           AVG(Salary) AS MinAverage
FROM Employees GROUP BY DepartmentID
ORDER BY MinAverage 

--12. Highest Peaks in Bulgaria 
SELECT 
     mc.CountryCode
	,m.MountainRange
	,p.PeakName
	,p.Elevation

FROM MountainsCountries AS mc
JOIN Mountains AS m ON m.Id = mc.MountainId
JOIN Peaks AS p ON p.MountainId = m.Id
WHERE CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

--13. Count Mountain Ranges
SELECT 
     mc.CountryCode
	,Count(m.MountainRange) AS MountainRanges
FROM MountainsCountries AS mc
JOIN Mountains AS m ON m.Id = mc.MountainId
WHERE mc.CountryCode IN ('US', 'BG', 'RU')
GROUP BY mc.CountryCode

--14. Countries With or Without Rivers
SELECT TOP 5
		   c.CountryName
		  ,r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName 

--15. Continents and Currencies
SELECT 
	 ContinentCode,
	 CurrencyCode,
	 CurrencyUsage
FROM 
(
	SELECT *,
	DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyUsage DESC)
	AS CurencyRank
	FROM 
	(
		SELECT 
			 ContinentCode
			,CurrencyCode
			,Count(*) AS CurrencyUsage
		FROM Countries
		GROUP BY [ContinentCode], [CurrencyCode]
		HAVING COUNT(*) > 1
	) AS CurrencyUsageSubQuery
)AS CurrencyRankingSubQuery
WHERE CurencyRank = 1

--16. Countries Without any Mountains
SELECT COUNT(*) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.CountryCode IS NULL

--17. Highest Peak and Longest River by Country
SELECT TOP 5
	 c.CountryName,
	 MAX(p.Elevation) AS HighestPeakElevation, 
	 MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
LEFT JOIN Mountains AS m ON m.Id = mc.MountainId
LEFT JOIN Peaks AS p ON p.MountainId = m.Id
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC,
		 CountryName ASC

--18. Highest Peak Name and Elevation by Country
SELECT TOP 5
CountryName AS Country,
ISNULL(PeakName, '(no highest peak)')
AS [Highest Peak Name],
ISNULL([Elevation], '0')
AS [Highest Peak Elevation],
ISNULL(MountainRange, '(no mountain)')
AS Mountain
FROM 
(
	SELECT 
		 c.CountryName,
		 p.PeakName,
		 p.Elevation,
		 m.MountainRange,
		 DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC)
		 AS PeakRank
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
	LEFT JOIN Mountains AS m ON m.Id = mc.MountainId
	LEFT JOIN Peaks AS p ON p.MountainId = mc.MountainId
) AS PeakRankingSubQuesry
WHERE PeakRank = 1
ORDER BY CountryName, [Highest Peak Name]



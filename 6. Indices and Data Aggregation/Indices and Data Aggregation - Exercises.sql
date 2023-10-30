--01. Records’ Count
SELECT Count(*) AS [Count]
FROM WizzardDeposits

--02. Longest Magic Wand
SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits

--03. Longest Magic Wand per Deposit Groups
SELECT DepositGroup, MAX(MagicWandSize)
FROM WizzardDeposits
GROUP BY DepositGroup

--04. Smallest Deposit Group per Magic Wand Size

SELECT TOP 2 DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--05. Deposits Sum
SELECT 
	  DepositGroup
	 ,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup

--06. Deposits Sum for Ollivander Family
SELECT 
	 DepositGroup
	,SUM(DepositAmount) AS TotalSum
FROM 
(
	SELECT 
		  DepositGroup
		 ,DepositAmount
		 ,MagicWandCreator
	FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family'
) AS NewSortedTable
GROUP BY DepositGroup

--07. Deposits Filter
SELECT 
	  DepositGroup
	 ,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--08. Deposit Charge
SELECT 
	 DepositGroup
	,MagicWandCreator
	,MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--09. Age Groups
SELECT 
	 AgeGroup
	,Count(*)
FROM
(
	SELECT 
		 CASE 
		 WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		 WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
		 WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
		 WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
		 WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
		 WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
		 ELSE '[61+]'
	END AS AgeGroup
	FROM WizzardDeposits
) AS SortedQuery
GROUP BY AgeGroup

--10. First Letter
SELECT 
    LEFT(FirstName, 1) AS FirstLetter
FROM 
    WizzardDeposits
WHERE 
    DepositGroup = 'Troll Chest'
GROUP BY 
    LEFT(FirstName, 1)
ORDER BY 
    LEFT(FirstName, 1) ASC;

--
SELECT DISTINCT
    LEFT(FirstName, 1) AS FirstLetter
FROM
    WizzardDeposits
WHERE
    DepositGroup = 'Troll Chest'
ORDER BY
    FirstLetter ASC;

--11. Average Interest
SELECT 
	 DepositGroup
	,IsDepositExpired
	,AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC

--12. *Rich Wizard, Poor Wizard
SELECT 
	 SUM([Difference]) AS SumDifference
FROM 
(
	SELECT 
		 FirstName AS [Host Wizard]
		,DepositAmount AS [Host Wizard Deposit]
		,LEAD(FirstName) OVER (ORDER BY Id) AS [Guest Wizard]
		,LEAD(DepositAmount) OVER (ORDER BY Id) AS [Guest Wizard Deposit]
		,DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id) AS [Difference]
	FROM WizzardDeposits
) AS [Difference]

--13. Departments Total Salaries
SELECT
	 DepartmentID
	,SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--14. Employees Minimum Salaries
SELECT
	 DepartmentID
	,MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '2000-01-01'
GROUP BY DepartmentID

--15. Employees Average Salaries
SELECT *
	 INTO [NewTable] 
FROM Employees
WHERE Salary > 30000

DELETE FROM NewTable
WHERE ManagerID = 42

UPDATE NewTable
SET Salary = Salary + 5000
WHERE DepartmentID = 1

SELECT DepartmentID,
	   AVG(Salary) AS AverageSalary
FROM NewTable
GROUP BY DepartmentID

--16. Employees Maximum Salaries
SELECT *
FROM 
(
	SELECT 
		 DepartmentID
		,MAX(Salary) AS MaxSalary
	FROM Employees
	GROUP BY DepartmentID
) AS SubQueryMaxSalary
WHERE MaxSalary < 30000 OR MaxSalary > 70000

--17. Employees Count Salaries
SELECT 
	 COUNT(Salary) AS [Count]
FROM Employees	
WHERE ManagerID IS NULL

--18. *3rd Highest Salary
SELECT
	 DISTINCT
     DepartmentID
	,Salary AS ThirdHighestSalary	
FROM
(
	SELECT
		DepartmentID,
        Salary,        
        DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
    FROM
        Employees
) AS RankedSalaries
WHERE SalaryRank = 3;

--19. **Salary Challenge
SELECT TOP 10
	 e.FirstName
	,e.LastName
	,e.DepartmentID
FROM Employees AS e
WHERE e.Salary >
(
	SELECT 
	   AVG(Salary)
	FROM Employees AS eAvarage
	WHERE eAvarage.DepartmentID = e.DepartmentID
	GROUP BY DepartmentID
)
ORDER BY DepartmentID



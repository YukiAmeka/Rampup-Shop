-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Employees]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

PRINT 'Populating data into [Master].[Employees]';

DROP TABLE IF EXISTS #Employees;

CREATE TABLE #Employees (
	EmployeeId INT IDENTITY PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	PasswordHash VARCHAR(50) DEFAULT(NULL),
	EmployeePositionId INT NOT NULL,
	DateHired DATE NOT NULL,
	DateFired DATE NOT NULL
);

INSERT INTO #Employees (FirstName, LastName, Email, EmployeePositionId, DateHired, DateFired)
VALUES ('Katrine', 'Burke', 'kburke@rampupshop.com', 1, '2020-01-02', '2999-12-31'),
	('Mason', 'Inoue', 'minoue@rampupshop.com', 2, '2020-08-14', '2999-12-31'),
	('Renata', 'Janusewycz', 'rjanusewycz@rampupshop.com', 2, '2020-05-22', '2999-12-31'),
	('Yannis', 'Aetos', 'yaetos@rampupshop.com', 2, '2020-04-12', '2020-05-22'),
	('Daina', 'Wilson', 'dwilson@rampupshop.com', 2, '2020-03-04', '2020-03-31'),
	('Linda', 'Holland', 'lholland@rampupshop.com', 2, '2020-02-18', '2020-08-10'),
	('Paul', 'Olsson', 'polsson@rampupshop.com', 2, '2020-01-02', '2020-03-05');

SET IDENTITY_INSERT [Master].[Employees] ON;
 
MERGE INTO [Master].[Employees] AS P
	USING #Employees AS S
	ON P.EmployeeId = S.EmployeeId
WHEN MATCHED THEN
	UPDATE SET P.FirstName = S.FirstName, P.LastName = S.LastName, P.Email = S.Email, P.EmployeePositionId = S.EmployeePositionId, P.DateHired = S.DateHired, P.DateFired = S.DateFired
WHEN NOT MATCHED THEN
	INSERT (EmployeeId, FirstName, LastName, Email, EmployeePositionId, DateHired, DateFired)
	VALUES (S.EmployeeId, S.FirstName, S.LastName, S.Email, S.EmployeePositionId, S.DateHired, S.DateFired)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
 
SET IDENTITY_INSERT [Master].[Employees] OFF;
 
DROP TABLE #Employees;
GO
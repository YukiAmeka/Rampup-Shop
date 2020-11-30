-- ===================================================================================================================================================
/*
	Table's data:		[Master].[EmployeePositions]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

PRINT 'Populating data into [Master].[EmployeePositions]';

DROP TABLE IF EXISTS #EmployeePositions;

CREATE TABLE #EmployeePositions (
	EmployeePositionId INT IDENTITY PRIMARY KEY,
	Title VARCHAR(50) NOT NULL,
	Description VARCHAR(200) NULL
);

INSERT INTO #EmployeePositions (Title, Description)
VALUES ('Head Manager', 'The employee in charge of the shop'),
	('Shop Assistant', 'The employee who helps customers, processes orders, and accepts deliveries');

SET IDENTITY_INSERT [Master].[EmployeePositions] ON;
 
MERGE INTO [Master].[EmployeePositions] AS P
	USING #EmployeePositions AS S
	ON P.EmployeePositionId = S.EmployeePositionId
WHEN MATCHED THEN
	UPDATE SET P.Title = S.Title, P.Description = S.Description
WHEN NOT MATCHED THEN
	INSERT (EmployeePositionId, Title, Description)
	VALUES (S.EmployeePositionId, S.Title, S.Description)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
 
SET IDENTITY_INSERT [Master].[EmployeePositions] OFF;
 
DROP TABLE #EmployeePositions;
GO
-- ===================================================================================================================================================
/*
	Table's data:		[Master].[EmployeePositions]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Modified on:		2020-12-02
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

PRINT 'Populating data into [Master].[EmployeePositions]';

IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[EmployeePositions])
BEGIN
	INSERT INTO [Master].[EmployeePositions] (Title, Description)
	VALUES ('Head Manager', 'The employee in charge of the shop'),
		('Shop Assistant', 'The employee who helps customers, processes orders, and accepts deliveries');
END
GO
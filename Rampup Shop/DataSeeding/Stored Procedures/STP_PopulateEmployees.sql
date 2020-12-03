-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Employees]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Modified on:		2020-12-03
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateEmployees]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Log the event
		EXEC [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = 'Populating data into [Master].[Employees]';

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[Employees])
		BEGIN
			INSERT INTO [Master].[Employees] (FirstName, LastName, Email, EmployeePositionId, DateHired, DateFired)
			VALUES ('Katrine', 'Burke', 'kburke@rampupshop.com', 1, '2020-01-02', DEFAULT),
				('Mason', 'Inoue', 'minoue@rampupshop.com', 2, '2020-08-14', DEFAULT),
				('Renata', 'Janusewycz', 'rjanusewycz@rampupshop.com', 2, '2020-05-22', DEFAULT),
				('Yannis', 'Aetos', 'yaetos@rampupshop.com', 2, '2020-04-12', '2020-05-22'),
				('Daina', 'Wilson', 'dwilson@rampupshop.com', 2, '2020-03-04', '2020-03-31'),
				('Linda', 'Holland', 'lholland@rampupshop.com', 2, '2020-02-18', '2020-08-10'),
				('Paul', 'Olsson', 'polsson@rampupshop.com', 2, '2020-01-02', '2020-03-05');
		END
		SET @AffectedRows = @@ROWCOUNT;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
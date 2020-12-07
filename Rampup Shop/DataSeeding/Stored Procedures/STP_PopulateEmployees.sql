-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Employees]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Modified on:		2020-12-07
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateEmployees]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[Employees]';

	BEGIN TRY
		-- Log the event
		DECLARE @Message VARCHAR(MAX) = 'Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;

		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);
			
		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

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
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE(), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		RETURN 1
	END CATCH
END;
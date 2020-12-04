-- ===================================================================================================================================================
/*
	Table's data:		[Master].[EmployeePositions]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-11-30
	Modified on:		2020-12-04
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateEmployeePositions]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[EmployeePositions]';

	BEGIN TRY
		-- Log the event
		DECLARE @Message VARCHAR(MAX) = 'Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[EmployeePositions])
		BEGIN
			INSERT INTO [Master].[EmployeePositions] (Title, Description)
			VALUES ('Head Manager', 'The employee in charge of the shop'),
				('Shop Assistant', 'The employee who helps customers, processes orders, and accepts deliveries');
		END
		SET @AffectedRows = @@ROWCOUNT;
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE(), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		RETURN 1
	END CATCH
END;
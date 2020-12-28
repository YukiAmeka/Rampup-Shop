-- ===================================================================================================================================================
/*
	Table's data:		[Master].[ShipMethods]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-07
	Modified on:		2020-12-24
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateShipMethods]
	@OperationRunId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@AffectedRows INT = 0,
		@TargetTable VARCHAR(100) = '[Master].[ShipMethods]';

	BEGIN TRY
		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[ShipMethods])
		BEGIN
			INSERT INTO [Master].[ShipMethods] (Name, Description)
			VALUES ('Home Delivery', 'Delivery within 3 hours. Extra delivery costs paid by the receiver'),
				('Collected by Client', 'Order can be collected within minutes at no extra charge');
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END

		-- Log the event
		DECLARE @Message VARCHAR(MAX) = '6) Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@AffectedRows = @AffectedRows,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);
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
		
		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
		RETURN 1
	END CATCH
END;

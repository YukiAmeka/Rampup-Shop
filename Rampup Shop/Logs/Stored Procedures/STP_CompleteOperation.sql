-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[OperationRuns]
	Short description:	Records a successful completion of a previously started operation
	Created on:			2020-12-02
	Modified on:		2020-12-24
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[STP_CompleteOperation]
	@OperationRunId INT = NULL,
	@Message VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @OperationRunId IS NULL
			RAISERROR('Cannot log the completion of the operation run, as no OperationRunId has been provided', 12, 20);
		
		-- Log successful operation completion
		UPDATE [Logs].[OperationRuns]
			SET EndTime = CURRENT_TIMESTAMP,
				Status = 'Success',
				Message = CONCAT(@Message, ' ', 'For more details, run SELECT * FROM [Logs].[Events] WHERE OperationRunId = ', CAST(@OperationRunId AS VARCHAR(6)))
			WHERE OperationRunId = @OperationRunId;
		
		-- Print runtime message to the user
		PRINT CONCAT('Operation run has been successfully completed. For more details, run SELECT * FROM [Logs].[Events] WHERE OperationRunId = ', CAST(@OperationRunId AS VARCHAR(6)));
		RETURN 0
	END TRY
	BEGIN CATCH
		-- Produce a qualified name of the calling procedure based on the record in [Logs].[OperationRuns]
		DECLARE @CallingProcFullName VARCHAR(255) = (SELECT Process FROM [Logs].[OperationRuns] WHERE OperationRunId = @OperationRunId);
		
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE() + ISNULL(' called from ' + @CallingProcFullName, ''), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		
		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
		RETURN 1
	END CATCH
END;
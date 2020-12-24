-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[Events]
	Short description:	Records an event as part of an operation
	Created on:			2020-12-02
	Modified on:		2020-12-23
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[STP_SetEvent]
	@OperationRunId INT = NULL,
	@CallingProc INT = NULL,
	@Process VARCHAR(MAX) = NULL,
	@Message VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Produce a qualified name of the calling procedure based on the passed in @@PROCID
	DECLARE @CallingProcFullName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@CallingProc)) + '.' + QUOTENAME(OBJECT_NAME(@CallingProc));
	
	BEGIN TRY
		IF @OperationRunId IS NULL
			RAISERROR('An event must be part of an operation run', 11, 10);

		-- Log the event
		INSERT INTO [Logs].[Events] (OperationRunId, CallingProc, Message, DateTime)
			VALUES (@OperationRunId, ISNULL(@Process, @CallingProcFullName), @Message, CURRENT_TIMESTAMP);

		-- Print runtime message to the user if any
		IF @Message IS NOT NULL
			PRINT @Message;
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE() + ISNULL(' called from ' + @CallingProcFullName, ''), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		RETURN 1
	END CATCH
END;
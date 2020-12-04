-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[Events]
	Short description:	Records an event as part of an operation
	Created on:			2020-12-02
	Modified on:		2020-12-04
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[STP_SetEvent]
	@OperationRunId INT = NULL,
	@CallingProc INT = NULL,
	@Message VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CallingProcFullName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@CallingProc)) + '.' + QUOTENAME(OBJECT_NAME(@CallingProc));
	BEGIN TRY
		IF @OperationRunId IS NULL
			RAISERROR('An event must be part of an operation run', 11, 10);
		INSERT INTO [Logs].[Events] (OperationRunId, CallingProc, Message, DateTime)
			VALUES (@OperationRunId, @CallingProcFullName, @Message, CURRENT_TIMESTAMP);
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
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		RETURN 1
	END CATCH
END;
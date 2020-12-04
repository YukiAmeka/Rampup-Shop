-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[OperationRuns]
	Short description:	Records an operation start
	Created on:			2020-12-02
	Modified on:		2020-12-04
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[STP_StartOperation]
	@OperationId INT = NULL,
	@CallingProc INT = NULL,
	@Message VARCHAR(MAX) = NULL,
	@OperationRunId INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CallingProcFullName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@CallingProc)) + '.' + QUOTENAME(OBJECT_NAME(@CallingProc));
	BEGIN TRY
		INSERT INTO [Logs].[OperationRuns] (OperationId, CallingUser, CallingProc, StartTime, Status, Message)
			VALUES (@OperationId, SYSTEM_USER, @CallingProcFullName, CURRENT_TIMESTAMP, 'Running', @Message);
		SET @OperationRunId = SCOPE_IDENTITY();
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
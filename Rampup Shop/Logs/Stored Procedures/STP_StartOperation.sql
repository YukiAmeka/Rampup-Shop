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

	-- Produce a qualified name of the calling procedure based on the passed in @@PROCID
	DECLARE @CallingProcFullName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@CallingProc)) + '.' + QUOTENAME(OBJECT_NAME(@CallingProc));
	
	BEGIN TRY
		-- Log operation start
		INSERT INTO [Logs].[OperationRuns] (OperationId, CallingUser, CallingProc, StartTime, Status, Message)
			VALUES (@OperationId, SYSTEM_USER, @CallingProcFullName, CURRENT_TIMESTAMP, 'Running', @Message);
		
		-- Output the generated OperationRunId
		SET @OperationRunId = SCOPE_IDENTITY();

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
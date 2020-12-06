-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[Errors]
	Short description:	Records error details
	Created on:			2020-12-02
	Modified on:		2020-12-04
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[STP_SetError]
	@OperationRunId INT = NULL,
	@Number INT = NULL,
	@Severity INT = NULL,
	@State INT = NULL,
	@CallingProc VARCHAR(255) = NULL,
	@Line INT = NULL,
	@Message NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Log the error
		INSERT INTO [Logs].[Errors] (OperationRunId, Number, Severity, State, CallingProc, Line, Message, DateTime)
			VALUES (@OperationRunId, @Number, @Severity, @State, @CallingProc, @Line, @Message, CURRENT_TIMESTAMP);
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE() + ISNULL(' called from ' + @CallingProc, ''), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		RETURN 1
	END CATCH
END;
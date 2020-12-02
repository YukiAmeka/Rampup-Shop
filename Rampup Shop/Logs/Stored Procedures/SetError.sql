-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[Errors]
	Short description:	Records error details
	Created on:			2020-12-02
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[SetError]
	@OperationRunId INT = NULL,
	@Number INT = NULL,
	@Severity TINYINT = NULL,
	@State TINYINT = NULL,
	@CallingProc VARCHAR(100) = NULL,
	@Line INT = NULL,
	@Message VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO [Logs].[Errors] (OperationRunId, Number, Severity, State, CallingProc, Line, Message, DateTime)
			VALUES (@OperationRunId, @Number, @Severity, @State, @CallingProc, @Line, @Message, CURRENT_TIMESTAMP);
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
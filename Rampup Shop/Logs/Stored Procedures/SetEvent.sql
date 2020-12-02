-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[Events]
	Short description:	Records an event as part of an operation
	Created on:			2020-12-02
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[SetEvent]
	@OperationRunId INT = NULL,
	@CallingProc VARCHAR(100) = NULL,
	@Message VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO [Logs].[Events] (OperationRunId, CallingProc, Message, DateTime)
			VALUES (@OperationRunId, @CallingProc, @Message, CURRENT_TIMESTAMP);
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
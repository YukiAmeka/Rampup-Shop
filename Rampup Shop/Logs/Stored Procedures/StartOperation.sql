-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[OperationRuns]
	Short description:	Records an operation start
	Created on:			2020-12-02
	Modified on:		2020-12-03
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[StartOperation]
	@OperationId INT = NULL,
	@CallingUser VARCHAR(50) = NULL,
	@CallingProc VARCHAR(100) = NULL,
	@Message VARCHAR(MAX) = NULL,
	@OperationRunId INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO [Logs].[OperationRuns] (OperationId, CallingUser, CallingProc, StartTime, Status, Message)
			VALUES (@OperationId, @CallingUser, @CallingProc, CURRENT_TIMESTAMP, 'Running', @Message);
		SET @OperationRunId = SCOPE_IDENTITY();
		IF @Message IS NOT NULL
			PRINT @Message;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
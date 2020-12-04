-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[OperationRuns]
	Short description:	Records an operation start
	Created on:			2020-12-02
	Modified on:		2020-12-03
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
	BEGIN TRY
		INSERT INTO [Logs].[OperationRuns] (OperationId, CallingUser, CallingProc, StartTime, Status, Message)
			VALUES (@OperationId, SYSTEM_USER, OBJECT_NAME(@CallingProc), CURRENT_TIMESTAMP, 'Running', @Message + CHAR(13) + CHAR(10));
		SET @OperationRunId = SCOPE_IDENTITY();
		IF @Message IS NOT NULL
			PRINT @Message;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
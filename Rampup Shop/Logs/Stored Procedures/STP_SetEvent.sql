-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[Events]
	Short description:	Records an event as part of an operation
	Created on:			2020-12-02
	Modified on:		2020-12-03
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
	BEGIN TRY
		INSERT INTO [Logs].[Events] (OperationRunId, CallingProc, Message, DateTime)
			VALUES (@OperationRunId, OBJECT_NAME(@CallingProc), @Message, CURRENT_TIMESTAMP);
		IF @Message IS NOT NULL
			PRINT @Message;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
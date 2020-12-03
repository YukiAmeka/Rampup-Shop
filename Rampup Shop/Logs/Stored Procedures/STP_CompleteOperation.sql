-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[OperationRuns]
	Short description:	Records a successful completion of a previously started operation
	Created on:			2020-12-02
	Modified on:		2020-12-03
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[STP_CompleteOperation]
	@OperationRunId INT = NULL,
	@AffectedRows INT = NULL,
	@Message VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE [Logs].[OperationRuns]
			SET EndTime = CURRENT_TIMESTAMP,
				Status = 'Success',
				AffectedRows = @AffectedRows,
				Message = CONCAT(@Message, ' ', 'For more details, run SELECT * FROM [Logs].[Events] WHERE OperationRunId = ', CAST(@OperationRunId AS VARCHAR(10)))
			WHERE OperationRunId = @OperationRunId;
		IF @Message IS NOT NULL
			PRINT @Message;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
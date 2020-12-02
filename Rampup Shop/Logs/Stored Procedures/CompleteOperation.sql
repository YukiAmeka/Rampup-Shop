-- ===================================================================================================================================================
/*
	Table's data:		[Logs].[OperationRuns]
	Short description:	Records a successful completion of a previously started operation
	Created on:			2020-12-02
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Logs].[CompleteOperation]
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
				Message = CONCAT(Message, @Message)
			WHERE OperationRunId = @OperationRunId;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
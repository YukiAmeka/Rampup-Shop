CREATE PROCEDURE [Logs].[CompleteOperation]
	@OperationRunId INT,
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
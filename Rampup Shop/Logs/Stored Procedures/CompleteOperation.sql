CREATE PROCEDURE [Logs].[CompleteOperation]
	@OperationRunId INT,
	@AffectedRows INT,
	@Message VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @EndTime DATETIME = CURRENT_TIMESTAMP,
			@Status VARCHAR(10) = 'Success';
		UPDATE [Logs].[OperationRuns]
			SET EndTime = @EndTime,
				Status = @Status,
				AffectedRows = @AffectedRows,
				Message = @Message
			WHERE OperationRunId = @OperationRunId;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
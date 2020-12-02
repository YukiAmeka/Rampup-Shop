CREATE PROCEDURE [Logs].[StartOperation]
	@OperationId INT = NULL,
	@CallingUser VARCHAR(50) = NULL,
	@CallingProc VARCHAR(50) = NULL,
	@OperationRunId INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO [Logs].[OperationRuns] (OperationId, CallingUser, CallingProc, StartTime, Status)
			VALUES (@OperationId, @CallingUser, @CallingProc, CURRENT_TIMESTAMP, 'Running');
		SET @OperationRunId = SCOPE_IDENTITY;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
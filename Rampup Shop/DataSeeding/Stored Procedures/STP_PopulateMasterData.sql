-- ===================================================================================================================================================
/*
	Table's data:		[Master] schema, [Logs] schema
	Short description:	Launches procedures for seeding data into tables, logging & error handling of the operation
	Created on:			2020-12-03
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateMasterData]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @OperationRunId INT,
			@AffectedRows INT,
			@TotalAffectedRows INT = 0;

		-- Log operation start
		EXEC [Logs].[STP_StartOperation] @CallingProc = @@PROCID,
			@Message = 'Data seeding is in progress.', 
			@OperationRunId = @OperationRunId OUTPUT

		-- Populate data into [Master].[EmployeePositions]
		EXEC [DataSeeding].[STP_PopulateEmployeePositions] @OperationRunId = @OperationRunId,
			@AffectedRows = @AffectedRows OUTPUT;
		SET @TotalAffectedRows += @AffectedRows;

		-- Populate data into [Master].[Employees]
		EXEC [DataSeeding].[STP_PopulateEmployees] @OperationRunId = @OperationRunId,
			@AffectedRows = @AffectedRows OUTPUT;
		SET @TotalAffectedRows += @AffectedRows;

		-- Populate data into [Master].[Customers]
		EXEC [DataSeeding].[STP_PopulateCustomers] @OperationRunId = @OperationRunId,
			@AffectedRows = @AffectedRows OUTPUT;
		SET @TotalAffectedRows += @AffectedRows;

		-- Populate data into [Master].[Addresses]
		EXEC [DataSeeding].[STP_PopulateAddresses] @OperationRunId = @OperationRunId,
			@AffectedRows = @AffectedRows OUTPUT;
		SET @TotalAffectedRows += @AffectedRows;

		-- Populate data into [Master].[CustomerAddresses]
		EXEC [DataSeeding].[STP_PopulateCustomerAddresses] @OperationRunId = @OperationRunId,
			@AffectedRows = @AffectedRows OUTPUT;
		SET @TotalAffectedRows += @AffectedRows;

		-- Log successful operation completion
		EXEC [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
			@AffectedRows = @TotalAffectedRows,
			@Message = 'Tables have been succefully populated with dummy data.';
		RETURN 0
	END TRY
	BEGIN CATCH
	
	END CATCH
END;
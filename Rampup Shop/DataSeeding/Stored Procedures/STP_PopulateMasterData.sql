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
			@TotalAffectedRows INT = 0,
			@ProcExecString NVARCHAR(MAX),
			@ProcName VARCHAR(100),
			@Counter INT = 1,
			@NumberOfProcs INT;

		-- Log operation start
		EXEC [Logs].[STP_StartOperation] @CallingProc = @@PROCID,
			@Message = 'Data seeding is in progress.', 
			@OperationRunId = @OperationRunId OUTPUT;

		-- Record a temporary list of data seeding procedures in the order of execution
		DROP TABLE IF EXISTS #SeedingProcedures;
		CREATE TABLE #SeedingProcedures (
			SeedingProcedureId INT IDENTITY(1,1) NOT NULL,
			ProcName VARCHAR(100) NOT NULL
		);
		INSERT INTO #SeedingProcedures
			VALUES ('STP_PopulateEmployeePositions'),
				('STP_PopulateEmployees'),
				('STP_PopulateCustomers'),
				('STP_PopulateAddresses'),
				('STP_PopulateCustomerAddresses');
		SET @NumberOfProcs = (SELECT COUNT(ProcName) FROM #SeedingProcedures);

		-- Run data seeding procedures one by one to populate tables with dummy data
		WHILE @Counter <= @NumberOfProcs
		BEGIN
			SET @ProcName = (SELECT ProcName FROM #SeedingProcedures WHERE SeedingProcedureId = @Counter);
			SET @ProcExecString = N'EXEC [DataSeeding].' + QUOTENAME(@ProcName) + ' @OperationRunId, @AffectedRows OUTPUT;'

			EXEC sp_executesql @ProcExecString,
				N'@OperationRunId INT, @AffectedRows INT OUTPUT',
				@OperationRunId = @OperationRunId,
				@AffectedRows = @AffectedRows OUTPUT;
		
			SET @TotalAffectedRows += @AffectedRows;
			SET @Counter += 1;
		END;

		-- Drop the temporary list of data seeding procedures
		DROP TABLE #SeedingProcedures;

		-- Log successful operation completion
		EXEC [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
			@AffectedRows = @TotalAffectedRows,
			@Message = 'Tables have been succefully populated with dummy data.';
		RETURN 0
	END TRY
	BEGIN CATCH
	
	END CATCH
END;
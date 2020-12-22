-- ===================================================================================================================================================
/*
	Table's data:		[Master] schema, [Logs] schema
	Short description:	Launches procedures for seeding data into tables, logging & error handling of the operation
	Created on:			2020-12-03
	Modified on:		2020-12-17
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateMasterData]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OperationRunId INT,
		@AffectedRows INT,
		@TotalAffectedRows INT = 0,
		@ProcExecString NVARCHAR(MAX),
		@ProcName VARCHAR(255),
		@Counter INT = 1,
		@NumberOfProcs INT,
		@SuccessStatus INT;

	BEGIN TRY
		-- Fill in types of operations for logging purposes
		INSERT INTO [Logs].[Operations] (Name, Description)
			VALUES ('Data seeding', 'Initial population of the DB at creation'),
				('New order', 'Customer adds a new order'),
				('Upload from file', 'New data is uploaded from file via the Staging schema (prices update, resupply, etc)');

		-- Log operation start
		EXEC @SuccessStatus = [Logs].[STP_StartOperation] @OperationId = 1,
			@CallingProc = @@PROCID,
			@Message = 'Data seeding is in progress.', 
			@OperationRunId = @OperationRunId OUTPUT;

		IF @SuccessStatus = 1
			RAISERROR('Operation start could not be logged. Data seeding has been interrupted', 12, 15);

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
				('STP_PopulateCustomerAddresses'),
				('STP_PopulateShipMethods'),
				('STP_PopulateOrderStatuses'),
				('STP_PopulateOrders'),
				('STP_PopulateProductTypes'),
				('STP_PopulateProductDetails'),
				('STP_PopulateVersions'),
				('STP_PopulateProductStocks'),
				('STP_PopulateOrderedProducts'),
				('STP_UpdateEndVersions');
		SET @NumberOfProcs = (SELECT COUNT(ProcName) FROM #SeedingProcedures);

		BEGIN TRAN
			-- Run data seeding procedures one by one to populate tables with dummy data
			WHILE @Counter <= @NumberOfProcs
			BEGIN
				SET @ProcName = (SELECT ProcName FROM #SeedingProcedures WHERE SeedingProcedureId = @Counter);
				SET @ProcExecString = N'EXEC @SuccessStatus = [DataSeeding].' + QUOTENAME(@ProcName) + ' @OperationRunId, @AffectedRows OUTPUT;'

				EXEC sp_executesql @ProcExecString,
					N'@SuccessStatus INT OUTPUT, @OperationRunId INT, @AffectedRows INT OUTPUT',
					@SuccessStatus = @SuccessStatus OUTPUT,
					@OperationRunId = @OperationRunId,
					@AffectedRows = @AffectedRows OUTPUT;

				IF @SuccessStatus = 1
					RAISERROR('Procedure [DataSeeding].%s failed. Operation has been interrupted', 12, 30, @ProcName);
		
				SET @TotalAffectedRows += ISNULL(@AffectedRows, 0);
				SET @Counter += 1;
			END;

			-- Drop the temporary list of data seeding procedures
			DROP TABLE #SeedingProcedures;

			-- Log successful operation completion
			EXEC @SuccessStatus = [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
				@AffectedRows = @TotalAffectedRows,
				@Message = 'Tables have been succefully populated with dummy data.';
		
			IF @SuccessStatus = 1
				RAISERROR('Operation completion could not be logged', 9, 15);
		COMMIT TRAN
		RETURN 0
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE(), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();

		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		
		-- Log operation failure
		EXEC [Logs].[STP_FailOperation] @OperationRunId, 'Data seeding has failed';

		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

		RETURN 1
	END CATCH
END;
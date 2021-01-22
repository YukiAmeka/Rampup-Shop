-- ===================================================================================================================================================
/*
	Table's data:		[Config].[ImportFields], [Config].[UploadParameters]
	Short description:	Post-deployment data seeding into the table
	Created on:			2021-01-12
	Modified on:		2021-01-19
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateConfig]
	@OperationRunId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@AffectedRows INT = 0,
		@Message VARCHAR(MAX),
		@TargetTable1 VARCHAR(100) = '[Config].[ImportFields]',
		@TargetTable2 VARCHAR(100) = '[Config].[UploadParameters]';

	BEGIN TRY
		/* Populate table [Config].[ImportFields] */

		-- Check if table exists
		IF OBJECT_ID(@TargetTable1) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable1);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Config].[ImportFields])
		BEGIN
			INSERT INTO [Config].[ImportFields] (TargetTable, TargetFieldName, SourceFieldName) 
			VALUES('[Staging].[ProductPrices]', 'ProductPriceId', 'id'),
				('[Staging].[ProductPrices]', 'Name', 'name'),
				('[Staging].[ProductPrices]', 'Price', 'price');

			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END

		-- Log the event
		SET @Message = '16) Populating data into ' + @TargetTable1;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@AffectedRows = @AffectedRows,
			@Message = @Message;

		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable1);


		/* Populate table [Config].[UploadParameters] */

		-- Check if table exists
		IF OBJECT_ID(@TargetTable2) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable2);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Config].[UploadParameters])
		BEGIN
			INSERT INTO [Config].[UploadParameters] (TargetTable, 
				FileNameBeginning, 
				SourceFilePath, 
				ArchiveFilePath,
				FormatFilePath,
				FieldTerminator,
				RowTerminator) 
			VALUES ('[Staging].[ProductPrices]', 
				'ProductPrices', 
				'C:\Users\alevc\source\repos\Rumpup Shop SSIS\Sources\',
				'C:\Users\alevc\source\repos\Rumpup Shop SSIS\Archive\',
				'C:\Users\alevc\source\repos\Rumpup Shop SSIS\Formats\ProductPrices.fmt',
				',',
				'\n');

			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END

		-- Log the event
		SET @Message = '17) Populating data into ' + @TargetTable2;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@AffectedRows = @AffectedRows,
			@Message = @Message;

		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable2);
		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER(), 
			@ErrorSeverity INT = ERROR_SEVERITY(), 
			@ErrorState INT = ERROR_STATE(), 
			@ErrorProcedure VARCHAR(255) = ERROR_PROCEDURE(), 
			@ErrorLine INT = ERROR_LINE(), 
			@ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		
		-- Log the error
		EXEC [Logs].[STP_SetError] @OperationRunId, @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;
		
		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
		RETURN 1
	END CATCH
END;

-- ===================================================================================================================================================
/*
	Table's data:		[Staging].[ProductPrices], [Master].[Versions], [Master].[ProductStocks]
	Short description:	Update prices for unsold product items from csv file
	Created on:			2020-12-20
	Modified on:		2020-12-24
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Staging].[STP_UpdatePrices]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@OperationRunId INT,
		@NewVersion INT,
		@AffectedRows INT,
		@Message VARCHAR(MAX),
		@CMDcommand VARCHAR(1000),
		@SourceFilePath VARCHAR(255) = 'C:\Users\alevc\source\repos\Rumpup Shop SSIS\Sources\',
		@ArchiveFilePath VARCHAR(255) = 'C:\Users\alevc\source\repos\Rumpup Shop SSIS\Archive\',
		@FileName VARCHAR(255) = 'ProductPrices.csv',
		@DBName VARCHAR(255) = '"' + db_name() + '"',
		@TableName VARCHAR(255) = '[Staging].[ProductPrices]';

	BEGIN TRY
		-- Log operation start
		EXEC @SuccessStatus = [Logs].[STP_StartOperation] @OperationId = 3,
			@CallingProc = @@PROCID,
			@Message = 'Prices update has started.', 
			@OperationRunId = @OperationRunId OUTPUT;

		IF @SuccessStatus = 1
			RAISERROR('Operation start could not be logged. Prices update has been interrupted', 12, 60);

		-- Log the event
		SET @Message = 'Prepping table ' + @TableName + ' to upload';
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;

		-- Clear the staging table
		TRUNCATE TABLE [Staging].[ProductPrices];

		-- Log the event
		SET @Message = 'Uploading new prices from file ' + @SourceFilePath + @FileName + ' into table ' + @TableName;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;

		-- Upload new prices from a csv file
		SET @CMDcommand = 'BCP "' + @TableName + '" in "' + @SourceFilePath + @FileName + '" -c -t "," -r "\n" -T -d ' + @DBName;
		EXEC master..xp_cmdshell @CMDcommand, no_output;
			
		-- Update prices for unsold product items from table [Staging].[ProductPrices]
		EXEC @SuccessStatus = [Staging].[STP_UpdatePricesFromStaging] @OperationRunId = @OperationRunId,
			@Message = @Message OUTPUT;

		IF @SuccessStatus = 1
			RAISERROR('Updating prices from table [Staging].[ProductPrices] has failed', 16, 60);

		-- Log the event
		SET @Message = 'Moving file ' + @SourceFilePath + @FileName + ' to the archive folder';
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;

		-- Move the csv file to the archive folder
		SET @CMDcommand = 'move "' + @SourceFilePath + @FileName + '" "' + @ArchiveFilePath + '"';
		EXEC master..xp_cmdshell @CMDcommand, no_output;

		-- Log successful operation completion
		EXEC @SuccessStatus = [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
			@AffectedRows = @AffectedRows,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Operation completion could not be logged', 9, 60);
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
		
		-- Log operation failure
		EXEC [Logs].[STP_FailOperation] @OperationRunId, 'Prices update has failed';

		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

		RETURN 1
	END CATCH
END;
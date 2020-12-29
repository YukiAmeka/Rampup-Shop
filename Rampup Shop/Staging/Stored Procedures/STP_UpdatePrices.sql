-- ===================================================================================================================================================
/*
	Table's data:		[Staging].[ProductPrices], [Master].[Versions], [Master].[ProductStocks]
	Short description:	Update prices for unsold product items from csv file
	Created on:			2020-12-20
	Modified on:		2020-12-28
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
		@FilesNumber INT,
		@Counter INT = 1,
		@Path VARCHAR(255) = 'C:\Users\alevc\source\repos\Rumpup Shop SSIS\',
		@FileName VARCHAR(255),
		@DBName VARCHAR(255) = '"' + db_name() + '"',
		@TableName VARCHAR(255) = '[Staging].[ProductPrices]';

	DECLARE @Output TABLE (
		FullFileStr VARCHAR(MAX)
	);

	DECLARE @SourceFilePath VARCHAR(255) = CONCAT(@Path, 'Sources\'),
		@ArchiveFilePath VARCHAR(255) = CONCAT(@Path, 'Archive\'),
		@FormatFile VARCHAR(255) = CONCAT(@Path, 'Formats\ProductPrices.fmt');

	BEGIN TRY
		-- Log operation start
		EXEC @SuccessStatus = [Logs].[STP_StartOperation] @OperationId = 3,
			@CallingProc = @@PROCID,
			@Message = 'Prices update has started.', 
			@OperationRunId = @OperationRunId OUTPUT;
		IF @SuccessStatus = 1
			RAISERROR('Operation start could not be logged. Prices update has been interrupted', 12, 60);

		-- Log the event
		SET @Message = CONCAT('Preparation to operation run No ', CAST(@OperationRunId AS VARCHAR(6)), ' has been completed; starting operation run');
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

		-- Clear the staging table
		SET @AffectedRows = (SELECT COUNT(*) FROM [Staging].[ProductPrices]);
		TRUNCATE TABLE [Staging].[ProductPrices];

		-- Log the event
		SET @Message = '1) Prepping table ' + @TableName + ' to upload';
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@AffectedRows = @AffectedRows,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

		-- Retrieve a list of files that are currently in the source folder
		SET @CMDcommand = 'dir "' + @SourceFilePath + '"';
		INSERT INTO @Output
		EXEC master..xp_cmdshell @CMDcommand;

		-- Save file names and modification datetimes in a temp table
		DROP TABLE IF EXISTS #DirFiles;
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS DirFileId,
			RIGHT(FullFileStr, CHARINDEX(' ', REVERSE(FullFileStr)) - 1) AS FileName,
			CONVERT(DATETIME, LEFT(FullFileStr, 10), 104) + CONVERT(DATETIME, SUBSTRING(FullFileStr, 13, 5), 108) AS ModifiedDateTime
		INTO #DirFiles
		FROM @Output
		WHERE FullFileStr IS NOT NULL
			AND LEFT(FullFileStr, 1) <> ' '
			AND FullFileStr NOT LIKE '%<DIR>%';
		SET @FilesNumber = (SELECT ISNULL(MAX(DirFileId), 0) FROM #DirFiles);

		-- Log the event
		SET @Message = '2) Retrieving a list of files in folder ' + @SourceFilePath + '. ' + CAST(@FilesNumber AS VARCHAR(3)) + ' files found';
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

		-- Upload new prices from csv files into [Staging].[ProductPrices] one by one
		WHILE @Counter <= @FilesNumber
		BEGIN
			SET @FileName = (SELECT FileName FROM #DirFiles
				WHERE DirFileId = @Counter);

			SET @CMDcommand = 'BCP "' + @TableName + '" in "' + @SourceFilePath + @FileName + '" -c -t "," -r "\n" -T -d ' + @DBName + ' -f "' + @FormatFile + '"';
			EXEC master..xp_cmdshell @CMDcommand, no_output;

			-- Mark each record with the file's modification date
			UPDATE [Staging].[ProductPrices]
			SET ModifiedDateTime = (SELECT ModifiedDateTime FROM #DirFiles
				WHERE DirFileId = @Counter)
			WHERE ModifiedDateTime IS NULL;

			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;

			-- Log the event
			SET @Message = '-- Uploading new prices from file ' + @SourceFilePath + @FileName + ' into table ' + @TableName;
			EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
				@CallingProc = @@PROCID,
				@AffectedRows = @AffectedRows,
				@Message = @Message;
			IF @SuccessStatus = 1
				RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

			SET @Counter += 1;
		END;
			
		-- Log the event
		SET @Message = '3) Updating prices from table ' + @TableName;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

		-- Update prices for unsold product items from table [Staging].[ProductPrices]
		EXEC @SuccessStatus = [Staging].[STP_UpdatePricesFromStaging] @OperationRunId = @OperationRunId,
			@Message = @Message OUTPUT,
			@NewVersion = @NewVersion OUTPUT;
		IF @SuccessStatus = 1
			RAISERROR('Updating prices from table [Staging].[ProductPrices] has failed', 16, 60);

		-- Log the event
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

		-- Move csv files to the archive folder one by one
		SET @Counter = 1;
		WHILE @Counter <= @FilesNumber
		BEGIN
			SET @FileName = (SELECT FileName FROM #DirFiles
				WHERE DirFileId = @Counter);

			IF @FileName IS NOT NULL
			BEGIN
				SET @CMDcommand = 'move "' + @SourceFilePath + @FileName + '" "' + @ArchiveFilePath + '"';
				EXEC master..xp_cmdshell @CMDcommand, no_output;

				-- Log the event
				SET @Message = '-- Moving file ' + @FileName + ' to folder ' + @ArchiveFilePath;
				EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
					@CallingProc = @@PROCID,
					@Message = @Message;
				IF @SuccessStatus = 1
					RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);
			END	

			SET @Counter += 1;
		END;

		-- Drop the temporary list of files
		DROP TABLE #DirFiles;

		-- Log the event
		SET @Message = CONCAT('Operation run No ', CAST(@OperationRunId AS VARCHAR(6)), ' has been completed');
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);

		-- Log successful operation completion
		EXEC @SuccessStatus = [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
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
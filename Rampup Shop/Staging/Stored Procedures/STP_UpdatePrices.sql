-- ===================================================================================================================================================
/*
	Table's data:		[Staging].[ProductPrices], [Master].[Versions], [Master].[ProductStocks]
	Short description:	Update prices for unsold product items from csv file
	Created on:			2020-12-20
	Modified on:		2021-01-21
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
		@SourceFilePath VARCHAR(255),
		@ArchiveFilePath VARCHAR(255),
		@FormatFilePath VARCHAR(255),
		@FileName VARCHAR(255),
		@FileNameBeginning VARCHAR(255),
		@FieldTerminator VARCHAR(5),
		@RowTerminator VARCHAR(5),
		@SourceColumnNames VARCHAR(255),
		@ColumnNumber INT,
		@TargetColumnNames VARCHAR(255),
		@OpenRowSet NVARCHAR(MAX),
		@Columns VARCHAR(MAX),
		@Unpivot NVARCHAR(MAX),
		@HeaderRow INT,
		@CleanTable NVARCHAR(MAX),
		@DBName VARCHAR(255) = '"' + db_name() + '"',
		@TableName VARCHAR(255) = '[Staging].[ProductPrices]';

	DECLARE @Output TABLE (
		FullFileStr VARCHAR(MAX)
	);

	DECLARE @DataCells TABLE (
		RowNumber INT, 
		ColumnName VARCHAR(255), 
		ColumnValue VARCHAR(MAX)
	);

	-- Retrieve bcp parameters from a config table
	SELECT @FileNameBeginning = FileNameBeginning, 
		@SourceFilePath = SourceFilePath, 
		@ArchiveFilePath = ArchiveFilePath, 
		@FormatFilePath = FormatFilePath, 
		@FieldTerminator = FieldTerminator,
		@RowTerminator = RowTerminator
	FROM [Config].[UploadParameters]
	WHERE TargetTable = @TableName;

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
		WITH AllFiles
		AS (
			SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS DirFileId,
				RIGHT(FullFileStr, CHARINDEX(' ', REVERSE(FullFileStr)) - 1) AS FileName,
				CONVERT(DATETIME, LEFT(FullFileStr, 10), 104) + CONVERT(DATETIME, SUBSTRING(FullFileStr, 13, 5), 108) AS ModifiedDateTime
			FROM @Output
			WHERE FullFileStr IS NOT NULL
				AND LEFT(FullFileStr, 1) <> ' '
				AND FullFileStr NOT LIKE '%<DIR>%'
		)
		SELECT DirFileId, FileName, ModifiedDateTime
		INTO #DirFiles
		FROM AllFiles
			WHERE FileName LIKE @FileNameBeginning + '%';
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

			-- Read a csv flat file
			IF RIGHT(@FileName, CHARINDEX('.', REVERSE(@FileName)) - 1) = 'csv'
			BEGIN
				SET @CMDcommand = 'BCP "' + @TableName + '" in "' + @SourceFilePath + @FileName 
					+ '" -c -t "' + @FieldTerminator + '" -r "' + @RowTerminator + '" -T -d ' 
					+ @DBName + ' -f "' + @FormatFilePath + '"';
				INSERT INTO @Output
				EXEC master..xp_cmdshell @CMDcommand;

				-- Check bcp output for errors
				IF (SELECT COUNT(FullFileStr) 
					FROM @Output
					WHERE FullFileStr LIKE 'Error%'
				) > 0
				BEGIN
					SET @Message = (SELECT TOP 1 FullFileStr 
						FROM @Output
						WHERE FullFileStr LIKE 'Error%'
					)
					RAISERROR(@Message, 16, 60);
				END
			END

			-- Read an excel file
			IF RIGHT(@FileName, CHARINDEX('.', REVERSE(@FileName)) - 1) = 'xlsx'
			BEGIN
				-- Upload all the contents of an xlsx file's sheet 1 into a temp table
				DROP TABLE IF EXISTS [Staging].[DirtyPrices];
				SET @OpenRowSet = N'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber,
					* INTO [Staging].[DirtyPrices]
					FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
						''Excel 12.0;
						HDR=NO;
						Database=' + @SourceFilePath + @FileName + ''', 
						[Sheet1$])';
				EXEC (@OpenRowSet);

				-- Add a row of NULL values to frame any table at the bottom of the file
				INSERT INTO [Staging].[DirtyPrices] (RowNumber)
				SELECT MAX(RowNumber) + 1 FROM [Staging].[DirtyPrices];

				-- Retrieve a list of all columns in the temp table from system table
				SET @Columns = (SELECT STRING_AGG(name, ', ') 
						WITHIN GROUP (ORDER BY column_id)
					FROM sys.columns
					WHERE object_id = object_id('[Staging].[DirtyPrices]')
						AND name <> 'RowNumber');

				-- Unpivot all non-null cells into a table variable
				SET @Unpivot = N'SELECT RowNumber, ColumnName, ColumnValue
					FROM (SELECT * 
						FROM [Staging].[DirtyPrices]) AS DP
					UNPIVOT
						(ColumnValue FOR ColumnName IN
							(' + @Columns + N')
						) AS Unpvt';
				INSERT INTO @DataCells
				EXEC (@Unpivot);

				-- Find the number of columns to be imported
				SET @ColumnNumber = (SELECT COUNT(SourceFieldName)
					FROM [Config].[ImportFields]
						WHERE TargetTable = @TableName
				);

				-- Locate RowNumber with the header row for the table we need
				SET @HeaderRow = (SELECT RowNumber
					FROM @DataCells
					WHERE ColumnValue IN (SELECT SourceFieldName
						FROM [Config].[ImportFields]
							WHERE TargetTable = @TableName
					)
					GROUP BY RowNumber
					HAVING COUNT(DISTINCT ColumnValue) = @ColumnNumber
				);

				-- Extract source column names for the table we need
				SET @SourceColumnNames = (SELECT STRING_AGG(ColumnName, ', ')
					FROM @DataCells
					WHERE ColumnValue IN (SELECT SourceFieldName
						FROM [Config].[ImportFields]
							WHERE TargetTable = @TableName
					)
					AND RowNumber = @HeaderRow
				);

				-- Extract target column names for the table we need from config table
				SET @TargetColumnNames = (SELECT STRING_AGG(TargetFieldName, ', ')
						WITHIN GROUP (ORDER BY ImportFieldId)
					FROM [Config].[ImportFields]
						WHERE TargetTable = @TableName
				);

				-- Extract the located columns and rows from dirty data table and insert them into the staging table
				SET @CleanTable = N'INSERT INTO' + @TableName + N'(' + @TargetColumnNames + N')
					SELECT ' + @SourceColumnNames + N' FROM [Staging].[DirtyPrices]
					WHERE RowNumber > ' + CAST(@HeaderRow AS NVARCHAR(4)) +
					N' AND RowNumber < (SELECT MIN(RowNumber) FROM [Staging].[DirtyPrices]
						WHERE COALESCE(' + @SourceColumnNames + N') IS NULL
						AND RowNumber > ' + CAST(@HeaderRow AS NVARCHAR(4)) + N')';
				EXEC (@CleanTable);

				-- Compensate for the collation difference
				UPDATE [Staging].[ProductPrices]
				SET Price = REPLACE(Price, ',', '.');
			END

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

		-- Create new archive folder
		IF @FilesNumber > 0
		BEGIN
			SET @ArchiveFilePath += 'Prices_' + CAST(ISNULL(@NewVersion, 0) AS VARCHAR(10)) + '_' 
				+ CAST(CAST(CURRENT_TIMESTAMP AS DATE) AS VARCHAR(10)) + '\';
			SET @CMDcommand = 'mkdir "' + @ArchiveFilePath + '"';
			EXEC master..xp_cmdshell @CMDcommand, no_output;

			-- Log the event
			SET @Message = '4) Archive folder ' + @ArchiveFilePath + ' has been created';
			EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
				@CallingProc = @@PROCID,
				@Message = @Message;
			IF @SuccessStatus = 1
				RAISERROR('Event logging has failed. Prices update has been interrupted', 12, 60);
		END

		-- Move the uploaded files to the archive folder one by one
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
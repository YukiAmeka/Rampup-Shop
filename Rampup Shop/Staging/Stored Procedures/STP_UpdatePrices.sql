-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Versions], [Master].[ProductStocks]
	Short description:	Update prices for unsold product items from table [Staging].[ProductPrices]
	Created on:			2020-12-20
	Modified on:		2020-12-21
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Master].[STP_UpdatePrices]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@OperationRunId INT,
		@NewVersion INT,
		@AffectedRows INT,
		@Message VARCHAR(MAX);

	BEGIN TRY
		-- Log operation start
		EXEC @SuccessStatus = [Logs].[STP_StartOperation] @OperationId = 3,
			@CallingProc = @@PROCID,
			@Message = 'Prices update has started.', 
			@OperationRunId = @OperationRunId OUTPUT;

		IF @SuccessStatus = 1
			RAISERROR('Operation start could not be logged. Prices update has been interrupted', 12, 60);

		BEGIN TRAN
			IF EXISTS (SELECT TOP 1 * FROM [Staging].[ProductPrices])
			BEGIN
				-- Log the event
				SET @Message = 'Creating a new version';
				EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
					@CallingProc = @@PROCID,
					@Message = @Message;
		
				IF @SuccessStatus = 1
					RAISERROR('Event logging has failed. Prices have not been updated', 12, 60);

				-- Create new version
				INSERT INTO [Master].[Versions] (OperationRunId, VersionDate, VersionDetails)
					VALUES (@OperationRunId, CAST (CURRENT_TIMESTAMP AS DATE), 'Product price change');
				SET @NewVersion = SCOPE_IDENTITY();

				-- Init the number of affected rows
				SET @AffectedRows = @@ROWCOUNT;

				-- Log the event
				SET @Message = 'Creating records with new prices in [Master].[ProductStocks]';
				EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
					@CallingProc = @@PROCID,
					@Message = @Message;
		
				IF @SuccessStatus = 1
					RAISERROR('Event logging has failed. Prices have not been updated', 12, 60);

				-- Copy records for unsold items with new prices and start version
				INSERT INTO [Master].[ProductStocks] (ProductDetailId, Price, StartVersion, EndVersion)
				SELECT PS.ProductDetailId, PP.Price, @NewVersion, 999999999 
				FROM [Master].[ProductStocks] AS PS
				JOIN [Staging].[ProductPrices] AS PP ON PS.ProductDetailId = PP.ProductPriceId
					WHERE PS.Price <> PP.Price
					AND PS.EndVersion = 999999999

				-- Increment the number of affected rows
				SET @AffectedRows += @@ROWCOUNT;

				-- Log the event
				SET @Message = 'Closing end version for retired records in [Master].[ProductStocks]';
				EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
					@CallingProc = @@PROCID,
					@Message = @Message;
		
				IF @SuccessStatus = 1
					RAISERROR('Event logging has failed. Prices have not been updated', 12, 60);

				-- Close end version for retired records of unsold items
				UPDATE [Master].[ProductStocks]
				SET EndVersion = @NewVersion
				FROM [Master].[ProductStocks] AS PS
				JOIN [Staging].[ProductPrices] AS PP ON PS.ProductDetailId = PP.ProductPriceId
					WHERE PS.Price <> PP.Price
					AND PS.EndVersion = 999999999

				-- Increment the number of affected rows
				SET @AffectedRows += @@ROWCOUNT;

				-- Set operation message
				SET @Message = IIF(@AffectedRows > 0, 
					'Prices have been successfully updated.', 
					'Prices contained in table [Staging].[ProductPrices] are no different from ones on record');
			END
			ELSE
			BEGIN
				-- Set operation message
				SET @Message = 'Table [Staging].[ProductPrices] is empty.';
			END;

			-- Log successful operation completion
			EXEC @SuccessStatus = [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
				@AffectedRows = @AffectedRows,
				@Message = @Message;
		
			IF @SuccessStatus = 1
				RAISERROR('Operation completion could not be logged', 9, 60);
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
		EXEC [Logs].[STP_FailOperation] @OperationRunId, 'Prices update has failed';

		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

		RETURN 1
	END CATCH
END;
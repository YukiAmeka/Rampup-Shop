-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Versions], [Master].[ProductStocks]
	Short description:	Update prices for unsold product items from table [Staging].[ProductPrices]
	Created on:			2020-12-22
	Modified on:		2020-12-28
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Staging].[STP_UpdatePricesFromStaging]
	@OperationRunId INT = NULL,
	@Message VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@NewVersion INT,
		@AffectedRows INT;

	BEGIN TRY
		IF @OperationRunId IS NULL
			RAISERROR('An event must be part of an operation run', 11, 60);

		IF NOT EXISTS (SELECT TOP 1 * FROM [Staging].[ProductPrices])
		BEGIN
			-- Set operation message
			SET @Message = 'Table [Staging].[ProductPrices] is empty.';
			RETURN 0
		END;

		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[ProductStocks] AS PS
		JOIN [Staging].[ProductPrices] AS PP ON PS.ProductDetailId = PP.ProductPriceId
			WHERE PS.Price <> PP.Price
			AND PS.EndVersion = 999999999)
		BEGIN
			-- Set operation message
			SET @Message = 'Prices contained in table [Staging].[ProductPrices] are no different from ones on record';
			RETURN 0
		END;

		BEGIN TRAN
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

			--SELECT TOP (1000) [ProductPriceId]
			--  ,[Name]
			--  ,[Price]
			--  ,[ModifiedDateTime]
			--  ,MAX([ModifiedDateTime]) OVER (PARTITION BY [ProductPriceId], [Name]) AS LatestEntry
		 -- FROM [Ramp Shop].[Staging].[ProductPrices]

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
			SET @Message = 'Prices have been successfully updated.';
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
		
		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

		RETURN 1
	END CATCH
END;
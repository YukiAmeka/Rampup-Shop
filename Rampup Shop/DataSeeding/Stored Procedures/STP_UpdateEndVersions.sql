-- ===================================================================================================================================================
/*
	Table's data:		[Master].[ProductStocks], [Master].[Versions]
	Short description:	Update of the tables during post-deployment data seeding
	Created on:			2020-12-16
	Modified on:		2020-12-16
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_UpdateEndVersions]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@Message VARCHAR(MAX),
		@TargetTable1 VARCHAR(100) = '[Master].[ProductStocks]',
		@TargetTable2 VARCHAR(100) = '[Master].[Versions]';

	BEGIN TRY		
		DROP TABLE IF EXISTS #OrderVersion;
		WITH OO
		AS (
			-- Add a field to [Master].[Orders] table to join on
			SELECT CustomerId,
				OrderId, 
				OrderDate, 
				ROW_NUMBER() OVER (PARTITION BY OrderDate ORDER BY OrderId) AS OrderedOrders
			FROM [Master].[Orders]
		), OV
		AS (
			-- Add a field to [Master].[Versions] table to join on
			SELECT VersionId, 
				VersionDate, 
				ROW_NUMBER() OVER (PARTITION BY VersionDate ORDER BY VersionId) AS OrderedVersions
			FROM [Master].[Versions]
		)
		-- Create a temporary table that puts together OrderId-VersionId pairs 
		SELECT OO.CustomerId, OO.OrderId, OV.VersionId 
		INTO #OrderVersion
		FROM OO
		JOIN OV ON OO.OrderedOrders = OV.OrderedVersions
			AND OO.OrderDate = OV.VersionDate;

		-- Log the 1st event
		SET @Message = 'Updating ' + @TargetTable1;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been updated', 12, 25, @TargetTable1);

		-- Check if table exists
		IF OBJECT_ID(@TargetTable1) IS NULL
			RAISERROR('Table %s cannot be updated, as it does not exist in this DB', 16, 25, @TargetTable1);

		-- Update EndVersion field for the product items that have been sold based on their OrderId
		UPDATE [Master].[ProductStocks]
			SET EndVersion = OVP.VersionId
		FROM #OrderVersion AS OVP
		JOIN [Master].[OrderedProducts] AS OP ON OVP.OrderId = OP.OrderId
		JOIN [Master].[ProductStocks] AS PS ON OP.ProductStockId = PS.ProductStockId
			WHERE OP.ProductStockId = PS.ProductStockId;

		-- Log the 2nd event
		SET @Message = 'Updating ' + @TargetTable2;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been updated', 12, 25, @TargetTable2);

		-- Check if table exists
		IF OBJECT_ID(@TargetTable2) IS NULL
			RAISERROR('Table %s cannot be updated, as it does not exist in this DB', 16, 25, @TargetTable2);

		-- Update VersionDetails field to reflect the nature & details of the purchase operation
		UPDATE [Master].[Versions]
			SET VersionDetails = CONCAT('Order No ', OrderId, ' by Customer No ', CustomerId)
		FROM #OrderVersion AS OVP
		JOIN [Master].[Versions] AS V ON OVP.VersionId = V.VersionId
			WHERE OVP.VersionId = V.VersionId;

		-- Drop the temporary table
		DROP TABLE #OrderVersion;
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
		RETURN 1
	END CATCH
END;
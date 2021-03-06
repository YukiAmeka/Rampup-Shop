﻿-- ===================================================================================================================================================
/*
	Table's data:		[Master].[ProductStocks]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-09
	Modified on:		2020-12-10
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateProductStocks]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[ProductStocks]';

	BEGIN TRY
		-- Log the event
		DECLARE @Message VARCHAR(MAX) = 'Populating data into ' + @TargetTable;
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Table %s has not been populated', 12, 25, @TargetTable);

		-- Check if table exists
		IF OBJECT_ID(@TargetTable) IS NULL
			RAISERROR('Table %s cannot be populated, as it does not exist in this DB', 16, 25, @TargetTable);

		-- Populate only an empty table:
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[ProductStocks])
		BEGIN
			-- Generate a numbers table for multiplying duplicates (24025 rows)
			WITH Numbers 
			AS (
				SELECT TOP (155) [object_id] FROM sys.all_objects
			), NumSqr
			AS (
				SELECT ROW_NUMBER() OVER (ORDER BY Numbers.[object_id]) AS n
				FROM Numbers CROSS JOIN Numbers AS N 
			), Items
			AS (
				-- Generate an annual supply of product items according to how many are sold per week
				SELECT ProductDetailId, Price	
				FROM NumSqr CROSS JOIN ##ProductDetails AS PD
				WHERE n <= 50 * (SELECT SoldPerWeek FROM ##ProductDetails
					WHERE ProductDetailId = PD.ProductDetailId)
			)
			-- Add version numbers that correspond to weekly deliveries
			INSERT INTO [Master].[ProductStocks] (ProductDetailId, Price, StartVersion)
			SELECT ProductDetailId, 
				Price,
				(NTILE(50) OVER(PARTITION BY ProductDetailId ORDER BY (SELECT NULL)) - 1) * 9010000 + 10000
			FROM Items;
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END
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
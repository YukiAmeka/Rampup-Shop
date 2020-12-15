-- ===================================================================================================================================================
/*
	Table's data:		[Master].[OrderedProducts]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-13
	Modified on:		2020-12-15
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateOrderedProducts]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[OrderedProducts]';

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
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[OrderedProducts])
		BEGIN
			WITH Schedule
			AS (
				SELECT ProductDetailId, 
					CASE
						WHEN Customer = 'G1_days' THEN 1
						WHEN Customer = 'G2_days' THEN 51
						WHEN Customer = 'G3_days' THEN 76
						WHEN Customer = 'G4_days' THEN 126
					END AS FirstCustomerId,
					CASE
						WHEN Customer = 'G1_days' THEN 50
						WHEN Customer = 'G2_days' THEN 75
						WHEN Customer = 'G3_days' THEN 125
						WHEN Customer = 'G4_days' THEN 150
					END AS LastCustomerId, 
					CustomerDays 
				FROM (SELECT ProductDetailId, G1_days, G2_days, G3_days, G4_days 
					FROM ##ProductDetails) AS PD
				UNPIVOT
					(CustomerDays FOR Customer IN
						(G1_days, G2_days, G3_days, G4_days)
				) AS Unpvt
			), OPD
			AS (
				SELECT O.OrderId, O.OrderDate, S.ProductDetailId,
					ROW_NUMBER() OVER (PARTITION BY ProductDetailId ORDER BY OrderDate) AS ProductOrder
				FROM Schedule AS S
				JOIN Master.Customers AS C ON C.CustomerId BETWEEN S.FirstCustomerId AND S.LastCustomerId
				CROSS APPLY STRING_SPLIT(CustomerDays, ',')
				JOIN Master.Orders AS O ON DATENAME(dw, OrderDate) = value
					AND C.CustomerId = O.CustomerId
			)
			INSERT INTO [Master].[OrderedProducts] (OrderId, ProductStockId)
			SELECT OrderId, ProductStockId FROM OPD
			JOIN (SELECT ProductStockId, 
				ProductDetailId,
				ROW_NUMBER() OVER (PARTITION BY ProductDetailId ORDER BY StartVersion) AS ProductOrder
			FROM Master.ProductStocks
			) AS Stock ON OPD.ProductOrder = Stock.ProductOrder
				AND OPD.ProductDetailId = Stock.ProductDetailId
			ORDER BY OrderId;
			
			-- Output the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		END

		-- Drop temporary dataset created during product details generation
		DROP TABLE ##ProductDetails;
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
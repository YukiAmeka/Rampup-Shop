-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Orders], [Master].[OrderedProducts], [Master].[Versions], [Master].[ProductStocks]
	Short description:	Record a customer order
	Created on:			2020-12-11
	Modified on:		2020-12-14
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Master].[STP_SubmitOrder]
	@OperationRunId INT = NULL,
	@CustomerId INT = NULL,
	@AddressId INT = NULL,
	@EmployeeId INT = NULL,
	@OrderedProducts VARCHAR(MAX) = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@OrderId INT,
		@NewVersion INT;

	BEGIN TRY
		-- Log the event
		DECLARE @Message VARCHAR(MAX) = 'Submitting a new customer order';
		EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = @Message;
		
		IF @SuccessStatus = 1
			RAISERROR('Event logging has failed. Order has not been recorded', 12, 50);

		-- Check if tables exists
		IF OBJECT_ID('[Master].[Orders]') IS NULL
			RAISERROR('Cannot write in table [Master].[Orders], as it does not exist in this DB', 16, 50);
		IF OBJECT_ID('[Master].[OrderedProducts]') IS NULL
			RAISERROR('Cannot write in table [Master].[OrderedProducts], as it does not exist in this DB', 16, 50);
		IF OBJECT_ID('[Master].[Versions]') IS NULL
			RAISERROR('Cannot write in table [Master].[Versions], as it does not exist in this DB', 16, 50);
		IF OBJECT_ID('[Master].[ProductStocks]') IS NULL
			RAISERROR('Cannot write in table [Master].[ProductStocks], as it does not exist in this DB', 16, 50);

		-- Check if all necessary data have been input
		IF @CustomerId IS NULL
			RAISERROR('CustomerId has not been provided', 16, 50);
		IF @EmployeeId IS NULL
			RAISERROR('EmployeeId has not been provided', 16, 50);
		IF @OrderedProducts IS NULL
			RAISERROR('The shopping cart is empty. Order must contain at least one item', 16, 50);

		-- Record the input order:
		INSERT INTO [Master].[Orders] (OrderDate, ShipDate, CustomerId, AddressId, OrderStatusId, ShipMethodId, EmployeeId)
			VALUES (CAST (CURRENT_TIMESTAMP AS DATE), NULL, @CustomerId, @AddressId, 1, IIF(@AddressId IS NULL, 2, 1), @EmployeeId);
		SET @OrderId = SCOPE_IDENTITY();

		-- Init the number of affected rows
		SET @AffectedRows = @@ROWCOUNT;
				
		-- Record the items that belong to the order
		INSERT INTO [Master].[OrderedProducts] (OrderId, ProductStockId)
			SELECT @OrderId, 
				(SELECT TOP 1 ProductStockId FROM [Master].[ProductStocks]
					WHERE ProductDetailId = CAST(value AS INT)
					AND EndVersion IS NULL
					ORDER BY StartVersion
				)
			FROM STRING_SPLIT(@OrderedProducts, ',');
		
		-- Increment the number of affected rows
		SET @AffectedRows += @@ROWCOUNT;

		-- Create new version
		INSERT INTO [Master].[Versions] (OperationRunId, VersionDate, VersionDetails)
			VALUES (@OperationRunId, CAST (CURRENT_TIMESTAMP AS DATE), CONCAT('Order No ', @OrderId, ' received from customer No ', @CustomerId));
		SET @NewVersion = SCOPE_IDENTITY();

		-- Increment the number of affected rows
		SET @AffectedRows += @@ROWCOUNT;

		-- Mark product items as sold
		UPDATE [Master].[ProductStocks]
			SET EndVersion = @NewVersion
			WHERE ProductStockId IN (SELECT ProductStockId 
				FROM OrderedProducts
				WHERE OrderId = @OrderId);

		-- Increment the number of affected rows
		SET @AffectedRows += @@ROWCOUNT;

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

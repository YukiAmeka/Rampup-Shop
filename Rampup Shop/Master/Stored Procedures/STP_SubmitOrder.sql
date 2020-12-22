-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Orders], [Master].[OrderedProducts], [Master].[Versions], [Master].[ProductStocks]
	Short description:	Record a customer order
	Created on:			2020-12-11
	Modified on:		2020-12-17
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [Master].[STP_SubmitOrder]
	@CustomerId INT = NULL,
	@AddressId INT = NULL,
	@EmployeeId INT = NULL,
	@OrderedProducts VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@OperationRunId INT,
		@OrderId INT,
		@NewVersion INT,
		@AffectedRows INT,
		@Message VARCHAR(MAX),
		@UnavailableProducts VARCHAR(MAX);

	BEGIN TRY
		-- Log operation start
		EXEC @SuccessStatus = [Logs].[STP_StartOperation] @OperationId = 2,
			@CallingProc = @@PROCID,
			@Message = 'Order creation has started.', 
			@OperationRunId = @OperationRunId OUTPUT;

		IF @SuccessStatus = 1
			RAISERROR('Operation start could not be logged. Order creation has been interrupted', 12, 50);

		-- Check if all necessary data have been input
		IF @CustomerId IS NULL
			RAISERROR('CustomerId has not been provided', 16, 50);
		IF @EmployeeId IS NULL
			RAISERROR('EmployeeId has not been provided', 16, 50);
		IF @OrderedProducts IS NULL OR LEN(@OrderedProducts) = 0
			RAISERROR('The shopping cart is empty. Order must contain at least one item', 16, 50);

		-- Check input data for validity
		IF @CustomerId NOT IN (SELECT CustomerId FROM [Master].[Customers])
			RAISERROR('Customer No %i is not in the database', 12, 50, @CustomerId);
		IF @AddressId NOT IN (SELECT AddressId FROM [Master].[CustomerAddresses]
			WHERE CustomerId = @CustomerId)
			RAISERROR('Input address is not part of Customer No %i profile', 12, 50, @CustomerId);
		IF @EmployeeId NOT IN (SELECT EmployeeId FROM [Master].[Employees]
			WHERE DateFired = '2999-12-31')
			RAISERROR('Employee No %i is not one we currently employ', 12, 50, @EmployeeId);
		IF (SELECT COUNT(value) FROM STRING_SPLIT(@OrderedProducts, ',')
			) <> (SELECT COUNT(value) FROM STRING_SPLIT(@OrderedProducts, ',')
			JOIN Master.ProductDetails AS PD ON value = ProductDetailId)
			RAISERROR('The cart contains invalid products', 12, 50);

		-- Check availability of ordered products
		WITH NotFound
		AS (
			SELECT value FROM STRING_SPLIT(@OrderedProducts, ',')
				EXCEPT
			SELECT ProductDetailId FROM [Master].[ProductStocks]
			CROSS APPLY STRING_SPLIT(@OrderedProducts, ',')
				WHERE ProductDetailId = CAST(value AS INT)
				AND EndVersion = 999999999
		)
		SELECT @UnavailableProducts = STRING_AGG (Name, ', ') FROM NotFound
		JOIN Master.ProductDetails AS PD ON value = ProductDetailId;

		IF @UnavailableProducts IS NOT NULL
			RAISERROR('The order cannot be completed, as %s are unavailable', 12, 50, @UnavailableProducts);

		BEGIN TRAN
			-- Log the event
			SET @Message = 'Recording the input order';
			EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
				@CallingProc = @@PROCID,
				@Message = @Message;
		
			IF @SuccessStatus = 1
				RAISERROR('Event logging has failed. Order has not been recorded', 12, 50);

			-- Record the input order
			INSERT INTO [Master].[Orders] (OrderDate, ShipDate, CustomerId, AddressId, OrderStatusId, ShipMethodId, EmployeeId)
				VALUES (CAST (CURRENT_TIMESTAMP AS DATE), NULL, @CustomerId, @AddressId, 1, IIF(@AddressId IS NULL, 2, 1), @EmployeeId);
			SET @OrderId = SCOPE_IDENTITY();

			-- Init the number of affected rows
			SET @AffectedRows = @@ROWCOUNT;
		
			-- Log the event
			SET @Message = 'Recording the items that belong to the order';
			EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
				@CallingProc = @@PROCID,
				@Message = @Message;
		
			IF @SuccessStatus = 1
				RAISERROR('Event logging has failed. Order has not been recorded', 12, 50);

			-- Record the items that belong to the order
			INSERT INTO [Master].[OrderedProducts] (OrderId, ProductStockId)
				SELECT @OrderId, 
					(SELECT TOP 1 ProductStockId FROM [Master].[ProductStocks]
						WHERE ProductDetailId = CAST(value AS INT)
						AND EndVersion = 999999999
						ORDER BY StartVersion
					)
				FROM STRING_SPLIT(@OrderedProducts, ',');
		
			-- Increment the number of affected rows
			SET @AffectedRows += @@ROWCOUNT;

			-- Log the event
			SET @Message = 'Creating a new version';
			EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
				@CallingProc = @@PROCID,
				@Message = @Message;
		
			IF @SuccessStatus = 1
				RAISERROR('Event logging has failed. Order has not been recorded', 12, 50);

			-- Create a new version
			INSERT INTO [Master].[Versions] (OperationRunId, VersionDate, VersionDetails)
				VALUES (@OperationRunId, CAST (CURRENT_TIMESTAMP AS DATE), CONCAT('Order No ', @OrderId, ' received from customer No ', @CustomerId));
			SET @NewVersion = SCOPE_IDENTITY();

			-- Increment the number of affected rows
			SET @AffectedRows += @@ROWCOUNT;

			-- Log the event
			SET @Message = 'Marking product items as sold';
			EXEC @SuccessStatus = [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
				@CallingProc = @@PROCID,
				@Message = @Message;
		
			IF @SuccessStatus = 1
				RAISERROR('Event logging has failed. Order has not been recorded', 12, 50);

			-- Mark product items as sold
			UPDATE [Master].[ProductStocks]
				SET EndVersion = @NewVersion
				WHERE ProductStockId IN (SELECT ProductStockId 
					FROM OrderedProducts
					WHERE OrderId = @OrderId);

			-- Increment the number of affected rows
			SET @AffectedRows += @@ROWCOUNT;

			-- Log successful operation completion
			EXEC @SuccessStatus = [Logs].[STP_CompleteOperation] @OperationRunId = @OperationRunId,
				@AffectedRows = @AffectedRows,
				@Message = 'New customer order has been successfully created.';
		
			IF @SuccessStatus = 1
				RAISERROR('Operation completion could not be logged', 9, 50);
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
		EXEC [Logs].[STP_FailOperation] @OperationRunId, 'Order creation has failed';

		-- Raiserror to the application
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

		RETURN 1
	END CATCH
END;

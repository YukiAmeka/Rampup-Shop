-- ===================================================================================================================================================
/*
	Table's data:		[Master].[CustomerAddresses]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-02
	Modified on:		2020-12-07
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateCustomerAddresses]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[CustomerAddresses]';

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
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[CustomerAddresses])
		BEGIN
			-- Connect every 3rd and 4th customer with an address until run out of customers or addresses. Every 12th customer gets 2 addresses
			WITH CWA
			AS (
				SELECT CustomerId, 
					ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Num 
				FROM (
					SELECT CustomerId FROM Master.Customers
					WHERE CustomerId % 3 = 0
					UNION ALL
					SELECT CustomerId FROM Master.Customers
					WHERE CustomerId % 4 = 0
				) AS PickedCustomers
			)
			INSERT INTO Master.CustomerAddresses
			SELECT CustomerId, AddressId FROM CWA
			JOIN Master.Addresses AS MA ON CWA.Num = MA.AddressId;

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
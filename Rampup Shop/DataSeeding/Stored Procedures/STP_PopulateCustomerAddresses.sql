-- ===================================================================================================================================================
/*
	Table's data:		[Master].[CustomerAddresses]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-02
	Modified on:		2020-12-03
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateCustomerAddresses]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Log the event
		EXEC [Logs].[STP_SetEvent] @OperationRunId = @OperationRunId,
			@CallingProc = @@PROCID,
			@Message = 'Populating data into [Master].[CustomerAddresses]';

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
		END
		SET @AffectedRows = @@ROWCOUNT;
		RETURN 0
	END TRY
	BEGIN CATCH

	END CATCH
END;
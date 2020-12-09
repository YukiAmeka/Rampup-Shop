-- ===================================================================================================================================================
/*
	Table's data:		[Master].[Orders]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-07
	Modified on:		2020-12-09
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

CREATE PROCEDURE [DataSeeding].[STP_PopulateOrders]
	@OperationRunId INT = NULL,
	@AffectedRows INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SuccessStatus INT,
		@TargetTable VARCHAR(100) = '[Master].[Orders]';

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
		IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[Orders])
		BEGIN
			DECLARE @StartDate DATE = '2020-01-02', 
				@EndDate DATE = DATEADD(d, -1, CAST(CURRENT_TIMESTAMP AS DATE));

			WITH Calendar 
			AS (
				SELECT DATEADD(d, n-1, @StartDate) AS OrderDate
				FROM (
					SELECT TOP (DATEDIFF(d, @StartDate, @EndDate) + 1)
						ROW_NUMBER() OVER (ORDER BY [object_id]) AS n
					FROM sys.all_objects) AS Numbers
			), PickedCustomers
			AS (
				SELECT MC.CustomerId, MAX(MCA.AddressId) AS AddressId
				FROM Master.Customers AS MC
				LEFT JOIN Master.CustomerAddresses AS MCA ON MC.CustomerId = MCA.CustomerId
				LEFT JOIN Master.Addresses AS MA ON MCA.AddressId = MA.AddressId
				GROUP BY MC.CustomerId
			)
			INSERT INTO [Master].[Orders] (OrderDate, ShipDate, CustomerId, AddressId, OrderStatusId, ShipMethodId, EmployeeId)
			SELECT OrderDate, 
				IIF(PC.AddressId IS NULL, OrderDate, DATEADD(d, 1, OrderDate)) AS ShipDate,
				PC.CustomerId, 
				PC.AddressId,
				3 AS OrderStatusId,
				IIF(PC.AddressId IS NULL, 2, 1) AS ShipMethodId,
				(SELECT TOP 1 EmployeeId FROM Master.Employees
					WHERE EmployeePositionId = 2
					AND Calendar.OrderDate BETWEEN DateHired AND DateFired) AS EmployeeId
			FROM Calendar
			CROSS JOIN Master.Customers AS MC
			LEFT JOIN PickedCustomers AS PC ON MC.CustomerId = PC.CustomerId
			WHERE DATENAME(dw, OrderDate) <> 'Sunday';
			
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
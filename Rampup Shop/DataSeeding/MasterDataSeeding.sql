-- ===================================================================================================================================================
/*
	Table's data:		[Master] schema, [Logs] schema
	Short description:	Launches procedures for seeding data into tables, logging & error handling of the operation
	Created on:			2020-12-03
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================

SET NOCOUNT ON;

DECLARE @OperationRunId INT,
	@AffectedRows INT,
	@TotalAffectedRows INT = 0;

-- Log operation start
EXEC [Logs].[StartOperation] @Message = 'Data seeding is in progress', 
	@OperationRunId = @OperationRunId OUTPUT

-- Populate data into [Master].[EmployeePositions]
EXEC [DataSeeding].[PopulateEmployeePositions] @AffectedRows = @AffectedRows OUTPUT;
SET @TotalAffectedRows += @AffectedRows;

-- Populate data into [Master].[Employees]
EXEC [DataSeeding].[PopulateEmployees] @AffectedRows = @AffectedRows OUTPUT;
SET @TotalAffectedRows += @AffectedRows;

-- Populate data into [Master].[Customers]
EXEC [DataSeeding].[PopulateCustomers] @AffectedRows = @AffectedRows OUTPUT;
SET @TotalAffectedRows += @AffectedRows;

-- Populate data into [Master].[Addresses]
EXEC [DataSeeding].[PopulateAddresses] @AffectedRows = @AffectedRows OUTPUT;
SET @TotalAffectedRows += @AffectedRows;

-- Populate data into [Master].[CustomerAddresses]
EXEC [DataSeeding].[PopulateCustomerAddresses] @AffectedRows = @AffectedRows OUTPUT;
SET @TotalAffectedRows += @AffectedRows;

-- Log successful operation completion
EXEC [Logs].[CompleteOperation] @OperationRunId = @OperationRunId,
	@AffectedRows = @TotalAffectedRows,
	@Message = 'Tables have been succefully populated with dummy data';

GO
-- ===================================================================================================================================================
/*
	Table's data:		[Master].[CustomerAddresses]
	Short description:	Post-deployment data seeding into the table
	Created on:			2020-12-02
	Scripted by:		SOFTSERVE\alevc
*/
-- ===================================================================================================================================================
SET NOCOUNT ON;
PRINT 'Populating data into [Master].[CustomerAddresses]';
IF NOT EXISTS (SELECT TOP 1 * FROM [Master].[CustomerAddresses])
BEGIN
	DECLARE @AddressesNumber INT = (SELECT MAX(AddressId) FROM [Master].[Addresses]),
		@AddressCounter INT = (SELECT MIN(AddressId) FROM [Master].[Addresses]),
		@CustomersNumber INT = (SELECT MAX(CustomerId) FROM [Master].[Customers]),
		@CustomersCounter INT = (SELECT MIN(CustomerId) FROM [Master].[Customers])
	WHILE @AddressCounter <= @AddressesNumber AND @CustomersCounter <= @CustomersNumber
	BEGIN
		IF @CustomersCounter % 3 = 0 
			AND EXISTS (SELECT * FROM [Master].[Customers] WHERE CustomerId = @CustomersCounter)
			AND EXISTS (SELECT * FROM [Master].[Addresses] WHERE AddressId = @AddressCounter)
		BEGIN
			INSERT INTO [Master].[CustomerAddresses] (CustomerId, AddressId)
				VALUES (@CustomersCounter, @AddressCounter);
			SET @AddressCounter += 1;
		END
		IF @CustomersCounter % 4 = 0 
			AND EXISTS (SELECT * FROM [Master].[Customers] WHERE CustomerId = @CustomersCounter)
			AND EXISTS (SELECT * FROM [Master].[Addresses] WHERE AddressId = @AddressCounter)
		BEGIN
			INSERT INTO [Master].[CustomerAddresses] (CustomerId, AddressId)
				VALUES (@CustomersCounter, @AddressCounter);
			SET @AddressCounter += 1;
		END
		SET @CustomersCounter += 1;
	END
	DELETE FROM [Master].[Addresses]
		WHERE AddressId >= @AddressCounter;
END
GO
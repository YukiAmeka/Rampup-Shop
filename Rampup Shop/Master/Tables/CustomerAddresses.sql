CREATE TABLE [Master].[CustomerAddresses]
(
	[CustomerAddressId] INT IDENTITY NOT NULL PRIMARY KEY, 
    [CustomerId] INT NOT NULL, 
    [AddressId] INT NOT NULL
)

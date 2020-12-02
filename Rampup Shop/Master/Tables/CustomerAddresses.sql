CREATE TABLE [Master].[CustomerAddresses]
(
	[CustomerAddressId] INT NOT NULL IDENTITY CONSTRAINT PK_Master_CustomerAddressId PRIMARY KEY, 
    [CustomerId] INT NOT NULL CONSTRAINT FK_CustomerAddresses_Customers_CustomerId FOREIGN KEY REFERENCES [Master].[Customers] ([CustomerId]), 
    [AddressId] INT NOT NULL CONSTRAINT FK_CustomerAddresses_Addresses_AddressId FOREIGN KEY REFERENCES [Master].[Addresses] ([AddressId])
)

CREATE TABLE [Master].[Addresses]
(
	[AddressId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_Addresses_AddressId PRIMARY KEY,
    [Country] VARCHAR(50) NOT NULL, 
    [City] VARCHAR(50) NOT NULL, 
    [Zip] VARCHAR(20) NULL, 
    [StreetAddress] VARCHAR(50) NOT NULL
)

CREATE TABLE [Master].[Addresses]
(
	[AddressId] INT NOT NULL IDENTITY CONSTRAINT PK_Master_AddressId PRIMARY KEY,
    [Country] VARCHAR(50) NOT NULL, 
    [City] VARCHAR(50) NOT NULL, 
    [Zip] VARCHAR(20) NULL, 
    [StreetAddress] VARCHAR(50) NOT NULL
)

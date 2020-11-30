CREATE TABLE [Master].[Addresses]
(
	[AddressId] INT IDENTITY NOT NULL PRIMARY KEY, 
    [Country] VARCHAR(50) NOT NULL, 
    [City] VARCHAR(50) NOT NULL, 
    [Zip] VARCHAR(10) NULL, 
    [StreetAddress] VARCHAR(50) NOT NULL
)

CREATE TABLE [Master].[ShipMethods]
(
	[ShipMethodId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_ShipMethods_ShipMethodId PRIMARY KEY, 
    [Name] VARCHAR(50) NOT NULL, 
    [Description] VARCHAR(255) NULL
)

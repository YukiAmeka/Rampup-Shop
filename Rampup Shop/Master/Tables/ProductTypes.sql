CREATE TABLE [Master].[ProductTypes]
(
	[ProductTypeId] INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Master_ProductTypes_ProductTypeId PRIMARY KEY, 
    [Name] VARCHAR(50) NOT NULL, 
    [Description] VARCHAR(255) NULL
)
